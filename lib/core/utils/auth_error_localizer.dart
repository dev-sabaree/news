import 'package:newsapp/l10n/app_localizations.dart';

class AuthErrorLocalizer {
  static String localize(AppLocalizations l10n, String errorCode) {
    switch (errorCode) {
      case 'invalid_credentials':
        return l10n.errorInvalidCredentials;
      case 'email_not_confirmed':
        return l10n.errorEmailNotConfirmed;
      case 'user_not_found':
        return l10n.errorUserNotFound;
      case 'too_many_requests':
        return l10n.errorTooManyRequests;
      case 'network_error':
        return l10n.errorNetworkError;
      case 'invalid_email':
        return l10n.errorInvalidEmail;
      case 'weak_password':
        return l10n.errorWeakPassword;
      case 'email_exists':
        return l10n.errorEmailExists;
      case 'signup_success':
        return l10n.signupSuccess;
      default:
        return l10n.errorUnknown;
    }
  }
}