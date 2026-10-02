import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:newsapp/core/connectivity/connectivity_cubit.dart';
import 'package:newsapp/core/connectivity/connectivity_state.dart';
import 'package:newsapp/core/localization/localization_service.dart';
import 'package:newsapp/core/services/connectivity_service.dart';
import 'package:newsapp/core/services/local_storage_service.dart';
import 'package:newsapp/core/utils/article_url.dart';
import 'package:newsapp/dependency_injection/injection.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:newsapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:newsapp/features/news/data/datasource/news_remote_datasource.dart';
import 'package:newsapp/features/news/data/repositories/news_repository_impl.dart';
import 'package:newsapp/features/news/domain/entities/news_entity.dart';
import 'package:newsapp/features/news/domain/usecases/get_cached_news_usecase.dart';
import 'package:newsapp/features/news/domain/usecases/get_top_headlines_usecase.dart';
import 'package:newsapp/features/news/domain/usecases/search_news_usecase.dart';
import 'package:newsapp/features/news/presentation/bloc/news_bloc.dart';
import 'package:newsapp/features/news/presentation/bloc/news_event.dart';
import 'package:newsapp/features/news/presentation/bloc/news_state.dart';
import 'package:newsapp/features/news/presentation/pages/news_list_page.dart';
import 'package:newsapp/l10n/app_localizations.dart';
import 'package:newsapp/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:newsapp/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:newsapp/features/auth/domain/usecases/logout_usecase.dart';

class MockGetTopHeadlinesUseCase extends Mock
    implements GetTopHeadlinesUseCase {}

class MockSearchNewsUseCase extends Mock implements SearchNewsUseCase {}

class MockGetCachedNewsUseCase extends Mock implements GetCachedNewsUseCase {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockNewsRemoteDataSource extends Mock implements NewsRemoteDataSource {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockIsLoggedInUseCase extends Mock implements IsLoggedInUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}

class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}

class MockNewsBloc extends Mock implements NewsBloc {}

class MockAuthBloc extends Mock implements AuthBloc {}

class MockConnectivityCubit extends Mock implements ConnectivityCubit {}

class MockLocalizationService extends Mock implements LocalizationService {}

const article = NewsEntity(
  title: 'Title',
  description: 'Description',
  content: 'Content',
  imageUrl: '',
  author: 'Author',
  source: 'Source',
  publishedAt: '2026-01-01T00:00:00Z',
  articleUrl: 'https://example.com',
);

List<NewsEntity> articlesForPage(int page) => List.generate(
  20,
  (index) => NewsEntity(
    title: 'Title $page-$index',
    description: 'Description',
    content: 'Content',
    imageUrl: '',
    author: 'Author',
    source: 'Source',
    publishedAt: '2026-01-01T00:00:00Z',
    articleUrl: 'https://example.com/$page/$index',
  ),
);

void main() {
  group('NewsBloc hardening', () {
    late MockGetTopHeadlinesUseCase headlines;
    late MockSearchNewsUseCase search;
    late MockGetCachedNewsUseCase cache;

    setUp(() {
      headlines = MockGetTopHeadlinesUseCase();
      search = MockSearchNewsUseCase();
      cache = MockGetCachedNewsUseCase();
      when(() => cache()).thenAnswer((_) async => []);
    });

    NewsBloc buildBloc() => NewsBloc(
          getTopHeadlinesUseCase: headlines,
          searchNewsUseCase: search,
          getCachedNewsUseCase: cache,
        );

    blocTest<NewsBloc, NewsState>(
      'retries the same page after a pagination failure',
      build: () {
        var attempts = 0;
        when(() => headlines(page: 2)).thenAnswer((_) async {
          if (attempts++ == 0) {
            throw Exception('temporary failure');
          }
          return [article];
        });
        return buildBloc();
      },
      seed: () => const NewsLoaded(articles: [article]),
      act: (bloc) async {
        bloc.add(LoadMoreNews());
        await Future<void>.delayed(Duration.zero);
        bloc.add(LoadMoreNews());
      },
      expect: () => [
        const NewsLoaded(articles: [article], isLoadingMore: true),
        const NewsLoaded(articles: [article], paginationFailed: true),
        const NewsLoaded(articles: [article], isLoadingMore: true),
        const NewsLoaded(articles: [article], hasReachedMax: true),
      ],
      verify: (_) => verify(() => headlines(page: 2)).called(2),
    );

    blocTest<NewsBloc, NewsState>(
      'paginates an active search using the next page',
      build: () {
        when(() => search(query: 'flutter', page: 1))
            .thenAnswer((_) async => articlesForPage(1));
        when(() => search(query: 'flutter', page: 2))
            .thenAnswer((_) async => articlesForPage(2));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const SearchNews('flutter'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(LoadMoreNews());
      },
      expect: () => [
        NewsLoading(),
        NewsLoaded(articles: articlesForPage(1)),
        NewsLoaded(articles: articlesForPage(1), isLoadingMore: true),
        NewsLoaded(articles: [...articlesForPage(1), ...articlesForPage(2)]),
      ],
    );

    test('completes a refresh completer after a failure', () async {
      when(() => headlines(page: 1)).thenThrow(Exception('offline'));
      final bloc = buildBloc();
      final completer = Completer<void>();
      bloc.add(RefreshNews(completer: completer));

      await completer.future.timeout(const Duration(seconds: 1));
      await bloc.close();
    });

    test('new headline request wins over a stale search result', () async {
      final pendingSearch = Completer<List<NewsEntity>>();
      when(() => search(query: 'old query', page: 1))
          .thenAnswer((_) => pendingSearch.future);
      when(() => headlines(page: 1)).thenAnswer((_) async => [article]);
      final bloc = buildBloc();
      bloc.add(const SearchNews('old query'));
      bloc.add(FetchTopHeadlines());
      pendingSearch.complete([article]);

      await expectLater(
        bloc.stream,
        emitsInOrder([
          NewsLoading(),
          const NewsLoaded(articles: [article], hasReachedMax: true),
        ]),
      );
      await bloc.close();
    });
  });

  test('ConnectivityCubit never emits online from a stale internet check', () async {
    final service = MockConnectivityService();
    final changes = StreamController<List<ConnectivityResult>>.broadcast(sync: true);
    final initialCheck = Completer<bool>();
    final pendingCheck = Completer<bool>();
    when(() => service.isConnected()).thenAnswer((_) => initialCheck.future);
    when(() => service.onConnectivityChanged).thenAnswer((_) => changes.stream);
    when(() => service.hasInternetAccess()).thenAnswer((_) => pendingCheck.future);
    final cubit = ConnectivityCubit(connectivityService: service);
    final states = <ConnectivityState>[];
    final subscription = cubit.stream.listen(states.add);

    changes.add([ConnectivityResult.wifi]);
    changes.add([ConnectivityResult.none]);
    pendingCheck.complete(true);
    await Future<void>.delayed(Duration.zero);

    expect(states, [ConnectivityOffline()]);
    expect(cubit.state, ConnectivityOffline());
    initialCheck.complete(false);
    await Future<void>.delayed(Duration.zero);
    expect(states, [ConnectivityOffline()]);
    await subscription.cancel();
    await cubit.close();
    await changes.close();
  });

  testWidgets('closing search cancels its pending debounce', (tester) async {
    final news = MockNewsBloc();
    final auth = MockAuthBloc();
    final connectivity = MockConnectivityCubit();
    final localization = MockLocalizationService();
    when(() => news.state).thenReturn(NewsInitial());
    when(() => news.stream).thenAnswer((_) => const Stream<NewsState>.empty());
    when(() => auth.state).thenReturn(AuthInitial());
    when(() => auth.stream).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => connectivity.state).thenReturn(ConnectivityOnline());
    when(() => connectivity.stream)
        .thenAnswer((_) => const Stream<ConnectivityState>.empty());
    when(() => localization.currentLocale).thenReturn(const Locale('en'));
    sl.registerSingleton<LocalizationService>(localization);
    addTearDown(sl.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<NewsBloc>.value(value: news),
            BlocProvider<AuthBloc>.value(value: auth),
            BlocProvider<ConnectivityCubit>.value(value: connectivity),
          ],
          child: const NewsListPage(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.search_rounded).first);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'flutter');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump(const Duration(milliseconds: 600));

    verifyNever(() => news.add(const SearchNews('flutter')));
    verify(() => news.add(FetchTopHeadlines())).called(1);
  });

  test('AuthBloc handles a signed-out session event', () async {
    final logout = MockLogoutUseCase();
    final isLoggedIn = MockIsLoggedInUseCase();
    final currentUser = MockGetCurrentUserUseCase();
    final client = MockSupabaseClient();
    final auth = MockGoTrueClient();
    final authStates = StreamController<supabase.AuthState>();
    when(() => client.auth).thenReturn(auth);
    when(() => auth.onAuthStateChange).thenAnswer((_) => authStates.stream);
    when(() => isLoggedIn()).thenReturn(false);

    final bloc = AuthBloc(
      logoutUseCase: logout,
      isLoggedInUseCase: isLoggedIn,
      getCurrentUserUseCase: currentUser,
      supabaseClient: client,
    );
    final expectation = expectLater(bloc.stream, emits(isA<AuthUnauthenticated>()));
    authStates.add(const supabase.AuthState(supabase.AuthChangeEvent.signedOut, null));

    await expectation;
    await bloc.close();
    await authStates.close();
  });

  test('cache parsing skips malformed entries and rejects expired or future cache', () async {
    final remote = MockNewsRemoteDataSource();
    final storage = MockLocalStorageService();
    final repository = NewsRepositoryImpl(remote, storage);
    when(() => storage.getNews()).thenReturn([
      '{bad json',
      '{"title":"Valid","description":"","content":"","urlToImage":"","author":"","url":"","publishedAt":"","source":{"name":""}}',
    ]);
    when(() => storage.getNewsCacheTimestamp()).thenReturn(DateTime.now());

    expect(await repository.getCachedNews(), hasLength(1));

    when(() => storage.getNewsCacheTimestamp()).thenReturn(
      DateTime.now().subtract(const Duration(hours: 7)),
    );
    expect(await repository.getCachedNews(), isEmpty);

    when(() => storage.getNewsCacheTimestamp()).thenReturn(
      DateTime.now().add(const Duration(minutes: 1)),
    );
    expect(await repository.getCachedNews(), isEmpty);
  });

  test('headline cache is read only by the presentation fallback', () async {
    final remote = MockNewsRemoteDataSource();
    final storage = MockLocalStorageService();
    final repository = NewsRepositoryImpl(remote, storage);
    when(() => storage.getNews()).thenReturn([
      '{"title":"Cached","description":"","content":"","urlToImage":"","author":"","url":"","publishedAt":"","source":{"name":""}}',
    ]);
    when(() => storage.getNewsCacheTimestamp()).thenReturn(DateTime.now());
    when(() => remote.getTopHeadlines(page: 1)).thenThrow(Exception('offline'));
    await expectLater(
      repository.getTopHeadlines(page: 1),
      throwsA(isA<Exception>()),
    );
    verifyNever(() => storage.getNews());
  });

  test('article URLs accept only absolute HTTP(S) URLs with a host', () {
    expect(validatedArticleUrl('https://example.com/article'), isNotNull);
    expect(validatedArticleUrl('http://example.com'), isNotNull);
    expect(validatedArticleUrl('mailto:test@example.com'), isNull);
    expect(validatedArticleUrl('javascript:alert(1)'), isNull);
    expect(validatedArticleUrl('https:///missing-host'), isNull);
    expect(validatedArticleUrl(''), isNull);
  });
}
