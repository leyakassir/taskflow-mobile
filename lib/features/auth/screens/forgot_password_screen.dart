import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';
import 'package:taskflow_mobile/features/auth/providers/password_reset_provider.dart';
import 'package:taskflow_mobile/features/auth/widgets/auth_step_header.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Step 1 of "Forgot password": enter the account email; a 6-digit code is
/// emailed, then step 2 (ResetPasswordScreen) opens.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = l10n.invalidEmail);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(passwordResetProvider)
          .requestCode(
            email,
            languageCode: Localizations.localeOf(context).languageCode,
          );
      if (mounted) context.push(RouteNames.resetPassword, extra: email);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.localized(l10n));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.space6),
          children: [
            AuthStepHeader(
              icon: Icons.lock_reset_rounded,
              title: l10n.forgotTitle,
              message: l10n.forgotSubtitle,
            ),
            const SizedBox(height: AppDimensions.space6),
            AutofillGroup(
              child: TextField(
                controller: _email,
                enabled: !_sending,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                autofillHints: const [AutofillHints.email],
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  errorText: _error,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space5),
            AppButton(
              label: l10n.forgotSendCode,
              icon: Icons.send_rounded,
              isLoading: _sending,
              onPressed: _sending ? null : _send,
            ),
            const SizedBox(height: AppDimensions.space2),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.forgotBackToLogin),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
