import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/token_provider.dart';
import '../../../../core/storage/prefs_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource implements TokenProvider {
  Future<void> saveSession(AuthResponseModel session);
  UserModel? getUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._prefs);

  final PrefsService _prefs;

  @override
  String? get accessToken => _prefs.getString(StorageKeys.accessToken);

  @override
  String? get refreshToken => _prefs.getString(StorageKeys.refreshToken);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(StorageKeys.accessToken, accessToken);
    await _prefs.setString(StorageKeys.refreshToken, refreshToken);
  }

  @override
  Future<void> saveSession(AuthResponseModel session) async {
    await saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await _prefs.setString(StorageKeys.user, jsonEncode(session.user.toJson()));
  }

  @override
  UserModel? getUser() {
    final raw = _prefs.getString(StorageKeys.user);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      throw const CacheException('Saved user data is corrupted.');
    }
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove(StorageKeys.accessToken);
    await _prefs.remove(StorageKeys.refreshToken);
    await _prefs.remove(StorageKeys.user);
  }
}
