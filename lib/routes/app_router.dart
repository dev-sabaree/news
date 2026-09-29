import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:newsapp/dependency_injection/injection.dart';
import 'package:newsapp/features/auth/presentation/pages/login_page.dart';
import 'package:newsapp/features/auth/presentation/pages/signup_page.dart';
import 'package:newsapp/features/auth/presentation/pages/splash_page.dart';
import 'package:newsapp/features/news/domain/entities/news_entity.dart';
import 'package:newsapp/features/news/presentation/bloc/news_bloc.dart';
import 'package:newsapp/features/news/presentation/bloc/news_event.dart';
import 'package:newsapp/features/news/presentation/pages/news_detail_page.dart';
import 'package:newsapp/features/news/presentation/pages/news_list_page.dart';
import 'package:newsapp/features/settings/pages/language_select_page.dart';
import 'package:newsapp/routes/route_names.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  StreamSubscription<AuthState>? _authStateSubscription;

  void startListening() {
    if (_authStateSubscription != null) {
      return;
    }

    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((_) {
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    super.dispose();
  }
}

GoRouter? _appRouter;

GoRouter get appRouter {
  return _appRouter ??= _createAppRouter();
}

GoRouter _createAppRouter() {
  final authRefreshNotifier = _AuthRefreshNotifier();
  authRefreshNotifier.startListening();

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authRefreshNotifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final location = state.matchedLocation;

      const protectedRoutes = {RouteNames.news, RouteNames.newsDetail};

      if (protectedRoutes.contains(location) && !isLoggedIn) {
        return RouteNames.login;
      }

      if (isLoggedIn &&
          (location == RouteNames.login || location == RouteNames.signup)) {
        return RouteNames.news;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: RouteNames.news,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<NewsBloc>()..add(FetchTopHeadlines()),
          child: const NewsListPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.newsDetail,
        builder: (context, state) =>
            NewsDetailPage(article: state.extra as NewsEntity),
      ),
      GoRoute(
        path: RouteNames.languageSelect,
        builder: (context, state) => const LanguageSelectPage(),
      ),
    ],
  );
}
