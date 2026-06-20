import 'package:newsapp/features/news/domain/entities/news_entity.dart';
import 'package:newsapp/features/news/domain/repositories/news_repository.dart';
import 'package:newsapp/features/news/data/datasource/news_remote_datasource.dart';
import 'dart:convert';
import 'package:newsapp/core/services/local_storage_service.dart';
import 'package:newsapp/features/news/data/models/news_model.dart';

class NewsRepositoryImpl implements NewsRepository {
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
    } catch (e) {
      try {
        final cachedNews = localStorageService.getNews();

        if (cachedNews.isNotEmpty) {
          final mapped = cachedNews
              .map((e) => NewsModel.fromJson(jsonDecode(e)).toEntity())
              .toList();

          return mapped;
        }

        rethrow;
      } catch (cacheError) {
        rethrow;
      }
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

    if (cachedNews.isEmpty) return [];

    return cachedNews
        .map((e) => NewsModel.fromJson(jsonDecode(e)).toEntity())
        .toList();
  }
}
