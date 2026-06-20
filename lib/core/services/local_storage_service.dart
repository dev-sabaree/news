import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsapp/core/constants/storage_keys.dart';

abstract class LocalStorageService {
  Future<void> saveLanguage(String language);
  Future<String?> getLanguage();

  Future<void> saveNews(List<String> articles);
  List<String> getNews();
}

class LocalStorageServiceImpl implements LocalStorageService {
  final SharedPreferences prefs;

  LocalStorageServiceImpl(this.prefs);

  @override
  Future<void> saveLanguage(String language) async {
    await prefs.setString(StorageKeys.language, language);
  }

  @override
  Future<String?> getLanguage() async {
    return prefs.getString(StorageKeys.language);
  }

  @override
  Future<void> saveNews(List<String> articles) async {
    await prefs.setStringList(StorageKeys.cachedNews, articles);
  }

  @override
  List<String> getNews() {
    return prefs.getStringList(StorageKeys.cachedNews) ?? [];
  }
}
