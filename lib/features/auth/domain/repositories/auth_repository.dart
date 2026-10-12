import 'package:taskflow_mobile/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> login({required String email, required String password});
  Future<bool> validateSession();
  Future<void> logout();
  Future<void> requestPasswordReset({
    required String email,
    required String languageCode,
  });
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
