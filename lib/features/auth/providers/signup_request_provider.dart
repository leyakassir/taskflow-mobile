import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/auth/data/repositories/auth_repository_impl.dart';

/// What the person typed on the first "Request an account" screen, kept in
/// memory for the code step (and for resending the code).
class SignupDraft {
  const SignupDraft({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final String password;
}

/// "Request an account" actions. Errors are ApiExceptions.
final signupRequestProvider = Provider<SignupRequestActions>(
  (ref) => SignupRequestActions(ref),
);

class SignupRequestActions {
  SignupRequestActions(this._ref);
  final Ref _ref;

  /// Matches the server's resend window.
  static const resendAfter = Duration(seconds: 60);

  Future<void> requestCode(SignupDraft draft, {required String languageCode}) =>
      _ref
          .read(authRepositoryProvider)
          .requestSignup(
            fullName: draft.fullName,
            email: draft.email,
            password: draft.password,
            languageCode: languageCode,
          );

  Future<void> verify(String email, String code) =>
      _ref.read(authRepositoryProvider).verifySignup(email: email, code: code);
}
