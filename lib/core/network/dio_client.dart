import 'package:dio/dio.dart';

import 'package:newsapp/core/constants/api_constants.dart';
import 'package:newsapp/core/constants/env_constants.dart';
import 'api_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'X-Api-Key': EnvConstants.newsApiKey,
        },
      ),
    );

    dio.interceptors.add(
      ApiInterceptor(),
    );
  }
}
