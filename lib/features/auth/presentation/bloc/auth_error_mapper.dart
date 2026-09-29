import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorMapper {
  const AuthErrorMapper._();

  static String getErrorCode(Object error) {
    if (error is SocketException) {
      return 'network_error';
    }

    if (error is AuthException) {
      final code = error.code?.toLowerCase() ?? '';
      final message = error.message.toLowerCase();
      final statusCode = error.statusCode;

      if (code == 'invalid_credentials' ||
          message.contains('invalid login credentials')) {
        return 'invalid_credentials';
      }

      if (code == 'email_not_confirmed' ||
          message.contains('email not confirmed')) {
        return 'email_not_confirmed';
      }

      if (code == 'user_not_found' ||
          message.contains('user not found')) {
        return 'user_not_found';
      }

      if (code == 'too_many_requests' ||
          message.contains('too many requests') ||
          message.contains('rate limit')) {
        return 'too_many_requests';
      }

      if (code == 'email_address_invalid' ||
          message.contains('invalid email')) {
        return 'invalid_email';
      }

      if (code == 'weak_password' ||
          message.contains('password should be')) {
        return 'weak_password';
      }

      if (code == 'email_exists' ||
          code == 'user_already_exists' ||
          message.contains('already registered') ||
          message.contains('user already registered')) {
        return 'email_exists';
      }

      if (statusCode != null &&
          (statusCode == '500' ||
              statusCode == '502' ||
              statusCode == '503' ||
              statusCode == '504')) {
        return 'server_error';
      }

      return 'unknown_error';
    }

    return 'unknown_error';
  }
}
