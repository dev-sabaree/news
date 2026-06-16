// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'News App';

  @override
  String get search => 'Search news...';

  @override
  String get noArticlesFound => 'No articles found';

  @override
  String get noInternet => 'No internet — showing cached news';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get failedToLoad => 'Failed to load news';

  @override
  String get refresh => 'Refresh';

  @override
  String get readMore => 'Read Full Article';

  @override
  String get author => 'Author';

  @override
  String get publishedAt => 'Published At';

  @override
  String get source => 'Source';

  @override
  String get unknownAuthor => 'Unknown Author';

  @override
  String get unknownSource => 'Unknown Source';

  @override
  String get noDescription => 'No description available';

  @override
  String get noContent => 'No content available';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get logout => 'Logout';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidPhone => 'Enter a valid phone number';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get signupSuccess => 'Account created successfully!';

  @override
  String get errorInvalidCredentials =>
      'Invalid email or password. Please try again.';

  @override
  String get errorEmailNotConfirmed =>
      'Please verify your email before logging in.';

  @override
  String get errorUserNotFound => 'No account found with this email.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get errorNetworkError =>
      'No internet connection. Please check your network.';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get errorWeakPassword =>
      'Password is too weak. Use at least 6 characters.';

  @override
  String get errorEmailExists => 'An account with this email already exists.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';
}
