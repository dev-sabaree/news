class AuthErrorMapper {
  const AuthErrorMapper._();

  static String getErrorCode(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('invalid_credentials') ||
        message.contains('invalid login credentials')) {
      return 'invalid_credentials';
    }
    if (message.contains('email_not_confirmed')) {
      return 'email_not_confirmed';
    }
    if (message.contains('user_not_found')) {
      return 'user_not_found';
    }
    if (message.contains('too_many_requests') ||
        message.contains('rate limit')) {
      return 'too_many_requests';
    }
    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return 'network_error';
    }
    if (message.contains('email_address_invalid') ||
        message.contains('invalid email')) {
      return 'invalid_email';
    }
    if (message.contains('weak_password') ||
        message.contains('password should be')) {
      return 'weak_password';
    }
    if (message.contains('email_exists') ||
        message.contains('user_already_exists') ||
        message.contains('already registered')) {
      return 'email_exists';
    }

    return 'unknown_error';
  }
}
