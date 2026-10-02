import 'package:dio/dio.dart';
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

      return _parseArticles(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
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

      return _parseArticles(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (_) {
      throw ServerException('Failed to search news');
    }
  }

  Exception _mapDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedException('Unauthorized news request');
    }
    if (statusCode == 429) {
      return RateLimitedException('News request rate limited');
    }
    if (statusCode == 408 || statusCode == 504 ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return TimeoutException('News request timed out');
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return NetworkException('News service is unavailable');
    }
    return ServerException('News service returned an error');
  }

  List<NewsModel> _parseArticles(Object? data) {
    if (data is! Map) {
      throw ServerException('News service returned an invalid response');
    }

    final rawArticles = data['articles'];
    if (rawArticles is! List) {
      throw ServerException('News service returned an invalid response');
    }

    final articles = <NewsModel>[];
    for (final article in rawArticles) {
      if (article is! Map) {
        throw ServerException('News service returned an invalid article');
      }

      try {
        articles.add(NewsModel.fromJson(Map<String, dynamic>.from(article)));
      } on TypeError {
        throw ServerException('News service returned an invalid article');
      } on FormatException {
        throw ServerException('News service returned an invalid article');
      }
    }
    return articles;
  }
}
