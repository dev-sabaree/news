import 'package:newsapp/core/errors/exceptions.dart';
import 'package:newsapp/core/network/dio_client.dart';
import 'package:newsapp/features/news/data/models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getTopHeadlines({required int page});

  Future<List<NewsModel>> searchNews({
    required String query,
    required int page,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final DioClient dioClient;

  NewsRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<NewsModel>> getTopHeadlines({required int page}) async {
    try {
      final response = await dioClient.dio.get(
        '/top-headlines',
        queryParameters: {'country': 'us', 'page': page, 'pageSize': 20},
      );

      final articles = response.data['articles'] as List;

      return articles.map((article) => NewsModel.fromJson(article)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch news');
    }
  }

  @override
  Future<List<NewsModel>> searchNews({
    required String query,
    required int page,
  }) async {
    try {
      final response = await dioClient.dio.get(
        '/everything',
        queryParameters: {'q': query, 'page': page, 'pageSize': 20},
      );

      final articles = response.data['articles'] as List;

      return articles.map((article) => NewsModel.fromJson(article)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
