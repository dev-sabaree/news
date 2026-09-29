import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:newsapp/features/news/domain/entities/news_entity.dart';
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

  // Empty = normal top-headlines mode.
  // Non-empty = search mode.
  String _activeQuery = '';

  // Used to ignore results from older requests.
  int _requestId = 0;

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

  // ---------------------------------------------------------------------------
  // Fetch top headlines
  // ---------------------------------------------------------------------------

  Future<void> _onFetchTopHeadlines(
    FetchTopHeadlines event,
    Emitter<NewsState> emit,
  ) async {
    final requestId = ++_requestId;

    emit(NewsLoading());

    _activeQuery = '';
    currentPage = 1;
    isLoadingMore = false;

    try {
      final articles = await getTopHeadlinesUseCase(
        page: currentPage,
      );

      // Ignore stale result.
      if (requestId != _requestId) {
        return;
      }

      emit(
        NewsLoaded(
          articles: articles,
          hasReachedMax: articles.isEmpty,
        ),
      );
    } catch (_) {
      // Ignore stale result.
      if (requestId != _requestId) {
        return;
      }

      try {
        final cachedNews = await getCachedNewsUseCase();

        if (requestId != _requestId) {
          return;
        }

        emit(
          NewsError(
            'failed_to_load',
            cachedArticles:
                cachedNews.isNotEmpty ? cachedNews : null,
          ),
        );
      } catch (_) {
        if (requestId != _requestId) {
          return;
        }

        emit(
          const NewsError('failed_to_load'),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Pull-to-refresh
  // ---------------------------------------------------------------------------

  Future<void> _onRefreshNews(
    RefreshNews event,
    Emitter<NewsState> emit,
  ) async {
    final requestId = ++_requestId;

    final query = _activeQuery.trim();

    currentPage = 1;
    isLoadingMore = false;

    try {
      // -----------------------------------------------------------------------
      // Refresh active search
      // -----------------------------------------------------------------------

      if (query.isNotEmpty) {
        final articles = await searchNewsUseCase(
          query: query,
          page: 1,
        );

        if (requestId != _requestId) {
          return;
        }

        emit(
          NewsLoaded(
            articles: articles,
            hasReachedMax: articles.isEmpty,
          ),
        );

        return;
      }

      // -----------------------------------------------------------------------
      // Refresh top headlines
      // -----------------------------------------------------------------------

      final articles = await getTopHeadlinesUseCase(
        page: 1,
      );

      if (requestId != _requestId) {
        return;
      }

      emit(
        NewsLoaded(
          articles: articles,
          hasReachedMax: articles.isEmpty,
        ),
      );
    } catch (_) {
      if (requestId != _requestId) {
        return;
      }

      // Search refresh should not show unrelated cached headlines.
      if (query.isNotEmpty) {
        emit(
          const NewsError('failed_to_load'),
        );

        return;
      }

      // Top headlines can fall back to cache.
      try {
        final cachedNews = await getCachedNewsUseCase();

        if (requestId != _requestId) {
          return;
        }

        emit(
          NewsError(
            'failed_to_load',
            cachedArticles:
                cachedNews.isNotEmpty ? cachedNews : null,
          ),
        );
      } catch (_) {
        if (requestId != _requestId) {
          return;
        }

        emit(
          const NewsError('failed_to_load'),
        );
      }
    } finally {
      // Always complete the RefreshIndicator future.
      if (!event.completer.isCompleted) {
        event.completer.complete();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Search news
  // ---------------------------------------------------------------------------

  Future<void> _onSearchNews(
    SearchNews event,
    Emitter<NewsState> emit,
  ) async {
    final requestId = ++_requestId;

    final query = event.query.trim();

    _activeQuery = query;
    currentPage = 1;
    isLoadingMore = false;

    // Empty search = normal headlines.
    if (query.isEmpty) {
      _activeQuery = '';

      emit(NewsLoading());

      try {
        final articles = await getTopHeadlinesUseCase(
          page: 1,
        );

        if (requestId != _requestId) {
          return;
        }

        emit(
          NewsLoaded(
            articles: articles,
            hasReachedMax: articles.isEmpty,
          ),
        );
      } catch (_) {
        if (requestId != _requestId) {
          return;
        }

        try {
          final cachedNews = await getCachedNewsUseCase();

          if (requestId != _requestId) {
            return;
          }

          emit(
            NewsError(
              'failed_to_load',
              cachedArticles:
                  cachedNews.isNotEmpty ? cachedNews : null,
            ),
          );
        } catch (_) {
          if (requestId != _requestId) {
            return;
          }

          emit(
            const NewsError('failed_to_load'),
          );
        }
      }

      return;
    }

    emit(NewsLoading());

    try {
      final articles = await searchNewsUseCase(
        query: query,
        page: currentPage,
      );

      // Ignore stale search result.
      if (requestId != _requestId) {
        return;
      }

      emit(
        NewsLoaded(
          articles: articles,
          hasReachedMax: articles.isEmpty,
        ),
      );
    } catch (_) {
      // Do not show unrelated cached top headlines.
      if (requestId != _requestId) {
        return;
      }

      emit(
        const NewsError('failed_to_load'),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Load more news
  // ---------------------------------------------------------------------------

  Future<void> _onLoadMoreNews(
    LoadMoreNews event,
    Emitter<NewsState> emit,
  ) async {
    if (state is! NewsLoaded || isLoadingMore) {
      return;
    }

    final currentState = state as NewsLoaded;

    if (currentState.hasReachedMax) {
      return;
    }

    final requestId = _requestId;

    isLoadingMore = true;

    final nextPage = currentPage + 1;

    try {
      late final List<NewsEntity> articles;

      // -----------------------------------------------------------------------
      // Search pagination
      // -----------------------------------------------------------------------

      if (_activeQuery.isNotEmpty) {
        articles = await searchNewsUseCase(
          query: _activeQuery,
          page: nextPage,
        );
      }

      // -----------------------------------------------------------------------
      // Top headlines pagination
      // -----------------------------------------------------------------------

      else {
        articles = await getTopHeadlinesUseCase(
          page: nextPage,
        );
      }

      // A newer request/search/refresh has started.
      if (requestId != _requestId) {
        return;
      }

      currentPage = nextPage;

      emit(
        NewsLoaded(
          articles: [
            ...currentState.articles,
            ...articles,
          ],
          hasReachedMax: articles.isEmpty,
        ),
      );
    } catch (_) {
      // Ignore stale pagination result.
      if (requestId != _requestId) {
        return;
      }

      // Roll back page number if loading failed.
      if (currentPage > 1) {
        currentPage--;
      }

      // Keep existing articles visible.
      emit(
        NewsLoaded(
          articles: currentState.articles,
          hasReachedMax: currentState.hasReachedMax,
        ),
      );
    } finally {
      isLoadingMore = false;
    }
  }
}