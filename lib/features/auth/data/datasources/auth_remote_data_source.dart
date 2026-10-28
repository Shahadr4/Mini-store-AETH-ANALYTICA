import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
        'expiresInMins': ApiConstants.tokenLifetimeMinutes,
      },
    );
    return AuthResponseModel.fromJson(response.data!);
  }
}
