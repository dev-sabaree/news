import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsapp/features/news/domain/usecases/get_cached_news_usecase.dart';
import 'package:newsapp/features/news/domain/usecases/get_top_headlines_usecase.dart';
import 'package:newsapp/features/news/domain/usecases/search_news_usecase.dart';
import 'package:newsapp/features/news/presentation/bloc/news_event.dart';
import 'package:newsapp/features/news/presentation/bloc/news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetTopHeadlinesUseCase getTopHeadlinesUseCase;
  final SearchNewsUseCase searchNewsUseCase;
  final GetCachedNewsUseCase getCachedNewsUseCase;

  int currentPage = 1;
  bool isLoadingMore = false;

  NewsBloc({
    required this.getTopHeadlinesUseCase,
    required this.searchNewsUseCase,
    required this.getCachedNewsUseCase,
  }) : super(NewsInitial()) {
    on<FetchTopHeadlines>(_onFetchTopHeadlines);
    on<RefreshNews>(_onRefreshNews);
    on<SearchNews>(_onSearchNews);
    on<LoadMoreNews>(_onLoadMoreNews);
  }

  Future<void> _onFetchTopHeadlines(
    FetchTopHeadlines event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());

    try {
      currentPage = 1;
      final articles = await getTopHeadlinesUseCase(page: currentPage);
      emit(NewsLoaded(articles: articles, hasReachedMax: articles.isEmpty));
    } catch (e) {
      try {
        final cachedNews = await getCachedNewsUseCase();
        emit(
          NewsError(
            e.toString(),
            cachedArticles: cachedNews.isNotEmpty ? cachedNews : null,
          ),
        );
      } catch (_) {
        emit(NewsError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshNews(
    RefreshNews event,
    Emitter<NewsState> emit,
  ) async {
    currentPage = 1;
    add(FetchTopHeadlines());
  }

  Future<void> _onSearchNews(
    SearchNews event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());

    try {
      currentPage = 1;
      final articles = await searchNewsUseCase(
        query: event.query,
        page: currentPage,
      );
      emit(NewsLoaded(articles: articles, hasReachedMax: articles.isEmpty));
    } catch (e) {
      try {
        final cachedNews = await getCachedNewsUseCase();
        emit(
          NewsError(
            e.toString(),
            cachedArticles: cachedNews.isNotEmpty ? cachedNews : null,
          ),
        );
      } catch (_) {
        emit(NewsError(e.toString()));
      }
    }
  }

  Future<void> _onLoadMoreNews(
    LoadMoreNews event,
    Emitter<NewsState> emit,
  ) async {
    if (state is! NewsLoaded || isLoadingMore) return;

    final currentState = state as NewsLoaded;

    if (currentState.hasReachedMax) return;

    try {
      currentPage++;
      isLoadingMore = true;

      final articles = await getTopHeadlinesUseCase(page: currentPage);

      emit(
        NewsLoaded(
          articles: [...currentState.articles, ...articles],
          hasReachedMax: articles.isEmpty,
        ),
      );
      isLoadingMore = false;
    } catch (e) {
      isLoadingMore = false;
      currentPage--;

      if (state is NewsLoaded) {
        final current = state as NewsLoaded;
        emit(
          NewsLoaded(
            articles: current.articles,
            hasReachedMax: current.hasReachedMax,
          ),
        );
        return;
      }
      emit(const NewsError('Failed to load more news'));
    }
  }
}
