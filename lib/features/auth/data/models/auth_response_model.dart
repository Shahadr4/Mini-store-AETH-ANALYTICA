import 'user_model.dart';

/// Login response: the user plus the tokens.
class AuthResponseModel {
  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserModel user;
  final String accessToken;
  final String refreshToken;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        user: UserModel.fromJson(json),
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}
