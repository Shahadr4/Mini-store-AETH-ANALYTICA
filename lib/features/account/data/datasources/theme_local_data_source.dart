import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/prefs_service.dart';

abstract class ThemeLocalDataSource {
  bool get isDarkMode;
  Future<void> setDarkMode(bool isDark);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  const ThemeLocalDataSourceImpl(this._prefs);

  final PrefsService _prefs;

  @override
  bool get isDarkMode => _prefs.getString(StorageKeys.themeMode) == 'dark';

  @override
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setString(StorageKeys.themeMode, isDark ? 'dark' : 'light');
  }
}
