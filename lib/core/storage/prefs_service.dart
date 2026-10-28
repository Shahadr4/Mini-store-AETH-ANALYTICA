import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences]. Only local data sources use it;
/// UI and state classes never touch it directly.
class PrefsService {
  PrefsService(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}
