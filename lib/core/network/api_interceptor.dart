import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('REQUEST[${options.method}] => ${options.path}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        'RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
      );
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        'ERROR[${err.response?.statusCode}] => ${err.requestOptions.path}',
      );
    }
    super.onError(err, handler);
  }
}
