import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

/// Builds Dio instances. Only this file knows the base options.
class DioFactory {
  const DioFactory._();

  static BaseOptions get _baseOptions => BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    headers: const {'Content-Type': 'application/json'},
  );

  /// Dio without interceptors (token refresh and request retry).
  static Dio plain() => Dio(_baseOptions);

  /// Dio used by every remote data source.
  static Dio create({required Interceptor authInterceptor}) =>
      Dio(_baseOptions)..interceptors.add(authInterceptor);
}
