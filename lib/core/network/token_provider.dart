/// Gives the network layer access to the saved session without
/// depending on any feature.
abstract class TokenProvider {
  String? get accessToken;
  String? get refreshToken;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Removes tokens and user data.
  Future<void> clearSession();
}
