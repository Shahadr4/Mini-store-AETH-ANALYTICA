import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../session/session_expired_notifier.dart';
import 'token_provider.dart';

/// Adds the Bearer token to every request and handles expired tokens:
/// on a 401 it refreshes the token and retries the request once.
/// If that is impossible the session is cleared and the app is told to
/// show the Login screen.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenProvider tokens,
    required Dio plainDio,
    required SessionExpiredNotifier sessionNotifier,
  }) : _tokens = tokens,
       _plainDio = plainDio,
       _sessionNotifier = sessionNotifier;

  static const _retriedKey = 'auth_retried';
  static const _expiredMessage =
      'Your session has expired. Please log in again.';

  final TokenProvider _tokens;

  /// A Dio without interceptors, used for the refresh call and the retry so
  /// they cannot recurse into this interceptor.
  final Dio _plainDio;
  final SessionExpiredNotifier _sessionNotifier;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokens.accessToken;
    if (token != null && !_isAuthPath(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 || _isAuthPath(options.path)) {
      return handler.next(err);
    }

    // No saved session: nothing to refresh (e.g. already logged out).
    final current = _tokens.accessToken;
    if (current == null) return handler.next(err);

    if (options.extra[_retriedKey] == true) {
      await _expireSession();
      return handler.next(err);
    }

    // If another request already refreshed the token, just retry with it.
    final alreadyRefreshed =
        options.headers['Authorization'] != 'Bearer $current';
    if (!alreadyRefreshed && !await _refreshTokens()) {
      await _expireSession();
      return handler.next(err);
    }

    try {
      options.headers['Authorization'] = 'Bearer ${_tokens.accessToken}';
      options.extra[_retriedKey] = true;
      handler.resolve(await _plainDio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) await _expireSession();
      handler.next(retryError);
    }
  }

  bool _isAuthPath(String path) =>
      path == ApiConstants.login || path == ApiConstants.refresh;

  Future<bool> _refreshTokens() async {
    final refreshToken = _tokens.refreshToken;
    if (refreshToken == null) return false;
    try {
      final response = await _plainDio.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': ApiConstants.tokenLifetimeMinutes,
        },
      );
      final data = response.data;
      final access = data?['accessToken'];
      final refresh = data?['refreshToken'];
      if (access is! String || refresh is! String) return false;
      await _tokens.saveTokens(accessToken: access, refreshToken: refresh);
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> _expireSession() async {
    await _tokens.clearSession();
    _sessionNotifier.notify(_expiredMessage);
  }
}
