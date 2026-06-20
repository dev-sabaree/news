import 'package:newsapp/features/news/domain/entities/news_entity.dart';

abstract class NewsRepository {
  Future<List<NewsEntity>> getTopHeadlines({
    required int page,
  });

  Future<List<NewsEntity>> searchNews({
    required String query,
    required int page,
  });

  Future<List<NewsEntity>> getCachedNews();
}
