import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';
import 'result.dart';

/// The single place where exceptions become [Failure]s.
///
/// Repositories wrap every data-source call in [guard].
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Success(await body());
  } catch (error) {
    return Fail(failureFrom(error));
  }
}

Failure failureFrom(Object error) {
  final exception = error is DioException ? _fromDio(error) : error;
  return switch (exception) {
    NetworkException(:final message) => NetworkFailure(message),
    UnauthorizedException(:final message) => UnauthorizedFailure(message),
    ServerException(:final message) => ServerFailure(message),
    CacheException(:final message) => CacheFailure(message),
    FormatException() || TypeError() => const ServerFailure(
      'We received an unexpected response from the server.',
    ),
    _ => const UnknownFailure(),
  };
}

AppException _fromDio(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException(
        'Could not reach the server. Please check your internet connection.',
      );
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode;
      final message = _messageFrom(error.response?.data);
      if (status == 401) {
        return UnauthorizedException(
          message ?? 'Your session has expired. Please log in again.',
        );
      }
      return ServerException(
        message ?? 'The server returned an error ($status).',
        statusCode: status,
      );
    case DioExceptionType.cancel:
      return const ServerException('The request was cancelled.');
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return const NetworkException(
        'Something went wrong while connecting. Please try again.',
      );
  }
}

String? _messageFrom(Object? data) {
  if (data is Map && data['message'] is String) {
    return data['message'] as String;
  }
  return null;
}
