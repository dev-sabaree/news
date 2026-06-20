import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsapp/core/constants/storage_keys.dart';

class LocalizationService extends ChangeNotifier {
  final SharedPreferences _prefs;

  LocalizationService(this._prefs);

  // 👇 check if user already selected a language
  bool get isLanguageSelected =>
      _prefs.containsKey(StorageKeys.language);

  Locale get currentLocale {
    final code = _prefs.getString(StorageKeys.language) ?? 'en';
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(StorageKeys.language, locale.languageCode);
    notifyListeners();
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];
}