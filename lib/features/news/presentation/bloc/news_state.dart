import 'package:equatable/equatable.dart';
import 'package:newsapp/features/news/domain/entities/news_entity.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsEntity> articles;
  final bool hasReachedMax;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool paginationFailed;
  final bool isFromCache;

  const NewsLoaded({
    required this.articles,
    this.hasReachedMax = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.paginationFailed = false,
    this.isFromCache = false,
  });

  NewsLoaded copyWith({
    List<NewsEntity>? articles,
    bool? hasReachedMax,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? paginationFailed,
    bool? isFromCache,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationFailed: paginationFailed ?? this.paginationFailed,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    articles,
    hasReachedMax,
    isRefreshing,
    isLoadingMore,
    paginationFailed,
    isFromCache,
  ];
}

class NewsError extends NewsState {
  final String message;
  final List<NewsEntity>? cachedArticles;

  const NewsError(this.message, {this.cachedArticles});

  @override
  List<Object?> get props => [message, cachedArticles];
}
