import '../../../../core/error/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Logs in and persists the session (tokens + user).
  Future<Result<User>> login({
    required String username,
    required String password,
  });

  /// Clears the saved session.
  Future<Result<void>> logout();

  /// The user saved at login, or null when there is no session.
  Future<Result<User?>> getSavedUser();

  /// Whether a token is saved on the device.
  bool get hasSession;
}
