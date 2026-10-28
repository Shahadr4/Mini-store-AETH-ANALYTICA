import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetSavedUserUseCase {
  const GetSavedUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User?>> call() => _repository.getSavedUser();
}
