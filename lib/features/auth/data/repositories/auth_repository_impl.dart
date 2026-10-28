import '../../../../core/error/error_handler.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) => guard(() async {
    final session = await _remote.login(username: username, password: password);
    await _local.saveSession(session);
    return session.user;
  });

  @override
  Future<Result<void>> logout() => guard(_local.clearSession);

  @override
  Future<Result<User?>> getSavedUser() async =>
      guard(() async => _local.getUser());

  @override
  bool get hasSession => (_local.accessToken ?? '').isNotEmpty;
}
