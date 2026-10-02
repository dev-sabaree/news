import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:newsapp/features/news/domain/entities/news_entity.dart';
import 'package:newsapp/features/news/domain/usecases/get_cached_news_usecase.dart';
import 'package:newsapp/features/news/domain/usecases/get_top_headlines_usecase.dart';
import 'package:newsapp/features/news/domain/usecases/search_news_usecase.dart';
import 'package:newsapp/features/news/presentation/bloc/news_event.dart';
import 'package:newsapp/features/news/presentation/bloc/news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  static const _pageSize = 20;

  final GetTopHeadlinesUseCase getTopHeadlinesUseCase;
  final SearchNewsUseCase searchNewsUseCase;
  final GetCachedNewsUseCase getCachedNewsUseCase;

  int _currentPage = 1;
  int _requestGeneration = 0;
  String _activeQuery = '';

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
    final generation = ++_requestGeneration;
    final previous = state is NewsLoaded ? state as NewsLoaded : null;
    final canPreserve = previous != null && _activeQuery.isEmpty;
    _activeQuery = '';
    _currentPage = 1;

    if (canPreserve) {
      emit(previous.copyWith(isRefreshing: true, paginationFailed: false));
    } else {
      emit(NewsLoading());
    }

    await _loadHeadlinesFirstPage(
      generation: generation,
      emit: emit,
      previous: canPreserve ? previous : null,
    );
  }

  Future<void> _onRefreshNews(
    RefreshNews event,
    Emitter<NewsState> emit,
  ) async {
    final generation = ++_requestGeneration;
    final previous = state is NewsLoaded ? state as NewsLoaded : null;
    final query = _activeQuery;
    _currentPage = 1;

    if (previous != null) {
      emit(previous.copyWith(isRefreshing: true, paginationFailed: false));
    } else {
      emit(NewsLoading());
    }

    try {
      final articles = query.isEmpty
          ? await getTopHeadlinesUseCase(page: 1)
          : await searchNewsUseCase(query: query, page: 1);
      if (generation != _requestGeneration) return;
      emit(_loadedFirstPage(articles));
    } catch (_) {
      if (generation != _requestGeneration) return;
      if (previous != null) {
        emit(previous.copyWith(isRefreshing: false, paginationFailed: false));
      } else if (query.isEmpty) {
        await _emitCachedOrError(generation, emit);
      } else {
        emit(const NewsError('failed_to_load'));
      }
    } finally {
      if (!event.completer.isCompleted) event.completer.complete();
    }
  }

  Future<void> _onSearchNews(
    SearchNews event,
    Emitter<NewsState> emit,
  ) async {
    final generation = ++_requestGeneration;
    final query = event.query.trim();
    _activeQuery = query;
    _currentPage = 1;
    emit(NewsLoading());

    if (query.isEmpty) {
      await _loadHeadlinesFirstPage(generation: generation, emit: emit);
      return;
    }

    try {
      final articles = await searchNewsUseCase(query: query, page: 1);
      if (generation != _requestGeneration) return;
      emit(_loadedFirstPage(articles));
    } catch (_) {
      if (generation == _requestGeneration) {
        emit(const NewsError('failed_to_load'));
      }
    }
  }

  Future<void> _onLoadMoreNews(
    LoadMoreNews event,
    Emitter<NewsState> emit,
  ) async {
    final current = state;
    if (current is! NewsLoaded ||
        current.hasReachedMax ||
        current.isLoadingMore ||
        current.isRefreshing) {
      return;
    }

    final generation = _requestGeneration;
    final query = _activeQuery;
    final nextPage = _currentPage + 1;
    emit(current.copyWith(isLoadingMore: true, paginationFailed: false));

    try {
      final articles = query.isEmpty
          ? await getTopHeadlinesUseCase(page: nextPage)
          : await searchNewsUseCase(query: query, page: nextPage);
      if (generation != _requestGeneration) return;

      _currentPage = nextPage;
      final combined = _deduplicate([...current.articles, ...articles]);
      emit(
        current.copyWith(
          articles: combined,
          hasReachedMax: articles.length < _pageSize,
          isLoadingMore: false,
          paginationFailed: false,
        ),
      );
    } catch (_) {
      if (generation == _requestGeneration) {
        emit(current.copyWith(isLoadingMore: false, paginationFailed: true));
      }
    }
  }

  Future<void> _loadHeadlinesFirstPage({
    required int generation,
    required Emitter<NewsState> emit,
    NewsLoaded? previous,
  }) async {
    try {
      final articles = await getTopHeadlinesUseCase(page: 1);
      if (generation == _requestGeneration) emit(_loadedFirstPage(articles));
    } catch (_) {
      if (generation != _requestGeneration) return;
      if (previous != null) {
        emit(previous.copyWith(isRefreshing: false, paginationFailed: false));
      } else {
        await _emitCachedOrError(generation, emit);
      }
    }
  }

  Future<void> _emitCachedOrError(
    int generation,
    Emitter<NewsState> emit,
  ) async {
    try {
      final cachedArticles = await getCachedNewsUseCase();
      if (generation != _requestGeneration) return;
      if (cachedArticles.isNotEmpty) {
        emit(
          NewsLoaded(
            articles: cachedArticles,
            hasReachedMax: true,
            isFromCache: true,
          ),
        );
      } else {
        emit(const NewsError('failed_to_load'));
      }
    } catch (_) {
      if (generation == _requestGeneration) {
        emit(const NewsError('failed_to_load'));
      }
    }
  }

  NewsLoaded _loadedFirstPage(List<NewsEntity> articles) {
    return NewsLoaded(
      articles: _deduplicate(articles),
      hasReachedMax: articles.length < _pageSize,
    );
  }

  List<NewsEntity> _deduplicate(List<NewsEntity> articles) {
    final seen = <String>{};
    return articles.where((article) {
      final key = article.articleUrl.isNotEmpty
          ? article.articleUrl
          : '${article.source}|${article.title}|${article.publishedAt}';
      return seen.add(key);
    }).toList(growable: false);
  }
}
