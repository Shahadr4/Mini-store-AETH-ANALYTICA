import 'dart:async';

import '../../../../core/session/session_expired_notifier.dart';
import '../../../../core/state/safe_change_notifier.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/check_session_usecase.dart';
import '../../domain/usecases/get_saved_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Keeps the login session. The router listens to it and redirects.
class AuthProvider extends SafeChangeNotifier {
  AuthProvider({
    required CheckSessionUseCase checkSession,
    required GetSavedUserUseCase getSavedUser,
    required LogoutUseCase logout,
    required SessionExpiredNotifier sessionNotifier,
    this.splashDuration = const Duration(milliseconds: 1500),
  }) : _checkSession = checkSession,
       _getSavedUser = getSavedUser,
       _logout = logout {
    _expiredSub = sessionNotifier.stream.listen(_onSessionExpired);
  }

  final CheckSessionUseCase _checkSession;
  final GetSavedUserUseCase _getSavedUser;
  final LogoutUseCase _logout;
  final Duration splashDuration;
  late final StreamSubscription<String> _expiredSub;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;

  /// Shown once on the Login screen, e.g. "session expired".
  String? _message;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get message => _message;

  /// Auto-login: goes to Home if a token is saved, to Login if not.
  Future<void> checkSession() async {
    if (_status != AuthStatus.unknown) return;
    final minimumSplash = Future<void>.delayed(splashDuration);

    User? savedUser;
    if (_checkSession()) {
      savedUser = (await _getSavedUser()).dataOrNull;
    }
    await minimumSplash;

    if (savedUser != null) {
      _setState(AuthStatus.authenticated, user: savedUser);
    } else {
      await _logout(); // remove a half-saved session
      _setState(AuthStatus.unauthenticated);
    }
  }

  void loggedIn(User user) => _setState(AuthStatus.authenticated, user: user);

  Future<void> logout() async {
    await _logout();
    _setState(AuthStatus.unauthenticated);
  }

  /// Called after the Login screen has shown the message.
  void clearMessage() {
    if (_message == null) return;
    _message = null;
    notifyListeners();
  }

  void _onSessionExpired(String message) {
    if (_status == AuthStatus.unauthenticated) return;
    _setState(AuthStatus.unauthenticated, message: message);
  }

  void _setState(AuthStatus status, {User? user, String? message}) {
    _status = status;
    _user = user;
    _message = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _expiredSub.cancel();
    super.dispose();
  }
}
