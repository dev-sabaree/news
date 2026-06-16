import 'package:equatable/equatable.dart';
import '../../domain/entities/news_entity.dart';

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

  const NewsLoaded({
    required this.articles,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [articles, hasReachedMax];
}

class NewsError extends NewsState {
  final String message;
  final List<NewsEntity>? cachedArticles;

  const NewsError(this.message, {this.cachedArticles});

  @override
  List<Object?> get props => [message, cachedArticles];
}