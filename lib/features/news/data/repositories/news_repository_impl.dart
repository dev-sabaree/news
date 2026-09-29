import 'package:newsapp/features/news/domain/entities/news_entity.dart';
import 'package:newsapp/features/news/domain/repositories/news_repository.dart';
import 'package:newsapp/features/news/data/datasource/news_remote_datasource.dart';
import 'dart:convert';
import 'package:newsapp/core/services/local_storage_service.dart';
import 'package:newsapp/features/news/data/models/news_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  static const _cacheTtl = Duration(hours: 6);
  final NewsRemoteDataSource remoteDataSource;
  final LocalStorageService localStorageService;

  NewsRepositoryImpl(this.remoteDataSource, this.localStorageService);

  @override
  Future<List<NewsEntity>> getTopHeadlines({required int page}) async {
    try {
      final articles = await remoteDataSource.getTopHeadlines(page: page);

      if (page == 1) {
        await localStorageService.saveNews(
          articles.map((e) => jsonEncode(e.toJson())).toList(),
        );
      }

      return articles.map((e) => e.toEntity()).toList();
    } catch (_) {
      if (page != 1) {
        rethrow;
      }

      final cachedNews = await getCachedNews();
      if (cachedNews.isNotEmpty) {
        return cachedNews;
      }

      rethrow;
    }
  }

  @override
  Future<List<NewsEntity>> searchNews({
    required String query,
    required int page,
  }) async {
    final articles = await remoteDataSource.searchNews(
      query: query,
      page: page,
    );

    return articles.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<NewsEntity>> getCachedNews() async {
    final cachedNews = localStorageService.getNews();

    final cachedAt = localStorageService.getNewsCacheTimestamp();
    final now = DateTime.now();
    if (cachedNews.isEmpty ||
        cachedAt == null ||
        cachedAt.isAfter(now) ||
        now.difference(cachedAt) > _cacheTtl) {
      return [];
    }

    final articles = <NewsEntity>[];
    for (final cachedArticle in cachedNews) {
      try {
        final decoded = jsonDecode(cachedArticle);
        if (decoded is! Map<String, dynamic>) {
          continue;
        }
        articles.add(NewsModel.fromJson(decoded).toEntity());
      } catch (_) {
        // A corrupt entry should not prevent valid cached articles from loading.
      }
    }

    return articles;
  }
}
