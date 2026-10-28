import '../../../../core/state/safe_change_notifier.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginProvider extends SafeChangeNotifier {
  LoginProvider(this._login);

  final LoginUseCase _login;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns the user when the login worked, otherwise null
  /// (the reason is then in [errorMessage]).
  Future<User?> login({
    required String username,
    required String password,
  }) async {
    if (_isLoading) return null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _login(username: username, password: password);

    User? user;
    result.when(
      success: (loggedInUser) => user = loggedInUser,
      failure: (failure) => _errorMessage = failure.message,
    );
    _isLoading = false;
    notifyListeners();
    return user;
  }
}
