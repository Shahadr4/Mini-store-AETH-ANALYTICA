import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({
    required String username,
    required String password,
  }) => _repository.login(username: username.trim(), password: password);
}
