class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);
}

class UnknownException implements Exception {
  final String message;

  UnknownException(this.message);
}

class RateLimitedException implements Exception {
  final String message;

  RateLimitedException(this.message);
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);
}
