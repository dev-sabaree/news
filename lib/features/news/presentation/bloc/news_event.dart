import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class FetchTopHeadlines extends NewsEvent {}

class RefreshNews extends NewsEvent {
  final Completer<void> completer;

  const RefreshNews({
    required this.completer,
  });

  @override
  List<Object?> get props => [completer];
}

class SearchNews extends NewsEvent {
  final String query;

  const SearchNews(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadMoreNews extends NewsEvent {}