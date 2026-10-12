import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/auth/data/repositories/auth_repository_impl.dart';

/// "Forgot password" actions for the two reset screens. Errors are
/// [ApiException]s so the screens can show a translated message.
final passwordResetProvider = Provider<PasswordResetActions>(
  (ref) => PasswordResetActions(ref),
);

class PasswordResetActions {
  PasswordResetActions(this._ref);
  final Ref _ref;

  /// How long to wait before offering "Resend code" (matches the server).
  static const resendAfter = Duration(seconds: 60);

  Future<void> requestCode(String email, {required String languageCode}) => _ref
      .read(authRepositoryProvider)
      .requestPasswordReset(email: email, languageCode: languageCode);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _ref
      .read(authRepositoryProvider)
      .resetPassword(email: email, code: code, newPassword: newPassword);
}
