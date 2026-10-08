import 'package:taskflow_mobile/features/auth/data/models/user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({required this.accessToken, this.user});

  final String accessToken;
  final UserModel? user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      user: userJson is Map<String, dynamic>
          ? UserModel.fromJson(userJson)
          : null,
    );
  }
}
