import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';
import 'package:taskflow_mobile/features/auth/providers/password_reset_provider.dart';
import 'package:taskflow_mobile/features/auth/widgets/auth_step_header.dart';
import 'package:taskflow_mobile/features/auth/widgets/otp_code_field.dart';
import 'package:taskflow_mobile/features/auth/widgets/resend_code_button.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Step 2 of "Forgot password": the emailed 6-digit code and a new
/// password. On success, back to sign-in with a confirmation.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  bool _saving = false;
  String? _codeError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final code = _code.text.trim();
    setState(() {
      _codeError = code.length == OtpCodeField.length
          ? null
          : l10n.resetCodeInvalid;
      _passwordError = _password.text.length >= 8
          ? null
          : l10n.resetPasswordShort;
      _confirmError = _confirm.text == _password.text
          ? null
          : l10n.resetPasswordMismatch;
    });
    if (_codeError != null || _passwordError != null || _confirmError != null) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(passwordResetProvider)
          .resetPassword(
            email: widget.email,
            code: code,
            newPassword: _password.text,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      context.go(RouteNames.login);
      messenger.showSnackBar(SnackBar(content: Text(l10n.resetDone)));
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        // 400 = wrong, expired or used-up code.
        _codeError = error.statusCode == 400
            ? l10n.resetCodeWrong
            : error.localized(l10n);
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(passwordResetProvider)
          .requestCode(
            widget.email,
            languageCode: Localizations.localeOf(context).languageCode,
          );
      _code.clear();
      setState(() => _codeError = null);
      messenger.showSnackBar(SnackBar(content: Text(l10n.resetCodeSent)));
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.localized(l10n))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final visibility = IconButton(
      tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
      onPressed: () => setState(() => _obscure = !_obscure),
      icon: Icon(
        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.space6),
            children: [
              AuthStepHeader(
                icon: Icons.mark_email_read_outlined,
                title: l10n.resetTitle,
                message: l10n.resetSubtitle(widget.email),
              ),
              const SizedBox(height: AppDimensions.space6),
              OtpCodeField(
                controller: _code,
                label: l10n.resetCodeLabel,
                errorText: _codeError,
                enabled: !_saving,
                onCompleted: () => _passwordFocus.requestFocus(),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ResendCodeButton(
                  cooldown: PasswordResetActions.resendAfter,
                  onResend: _resend,
                ),
              ),
              Text(
                l10n.resetCheckSpam,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.space5),
              TextField(
                controller: _password,
                focusNode: _passwordFocus,
                enabled: !_saving,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.resetNewPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: visibility,
                  errorText: _passwordError,
                ),
              ),
              const SizedBox(height: AppDimensions.space3),
              TextField(
                controller: _confirm,
                enabled: !_saving,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.resetConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  errorText: _confirmError,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              AppButton(
                label: l10n.resetSubmit,
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _saving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
