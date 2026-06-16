import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/news_repository.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository newsRepository;

  int currentPage = 1;
  bool isLoadingMore = false;

  NewsBloc({required this.newsRepository}) : super(NewsInitial()) {
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
      final articles = await newsRepository.getTopHeadlines(page: currentPage);
      emit(NewsLoaded(articles: articles, hasReachedMax: articles.isEmpty));
    } catch (e) {
      try {
        final cachedNews = await newsRepository.getCachedNews();
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
    currentPage = 1; // 👈 hasReachedMax line remove ചെയ്തു
    add(FetchTopHeadlines());
  }

  Future<void> _onSearchNews(
    SearchNews event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());

    try {
      currentPage = 1;
      final articles = await newsRepository.searchNews(
        query: event.query,
        page: currentPage,
      );
      emit(NewsLoaded(articles: articles, hasReachedMax: articles.isEmpty));
    } catch (e) {
      try {
        final cachedNews = await newsRepository.getCachedNews();
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

      final articles = await newsRepository.getTopHeadlines(page: currentPage);

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