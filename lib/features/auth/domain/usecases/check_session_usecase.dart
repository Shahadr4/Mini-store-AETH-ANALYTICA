import '../repositories/auth_repository.dart';

/// True when a token is saved on the device (used by auto-login).
class CheckSessionUseCase {
  const CheckSessionUseCase(this._repository);

  final AuthRepository _repository;

  bool call() => _repository.hasSession;
}
