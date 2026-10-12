import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';
import 'package:taskflow_mobile/features/auth/providers/signup_request_provider.dart';
import 'package:taskflow_mobile/features/auth/widgets/auth_step_header.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// "Request an account", step 1: name, email and a password. A code is
/// emailed, then step 2 (SignupVerifyScreen) opens.
class SignupRequestScreen extends ConsumerStatefulWidget {
  const SignupRequestScreen({super.key});

  @override
  ConsumerState<SignupRequestScreen> createState() =>
      _SignupRequestScreenState();
}

class _SignupRequestScreenState extends ConsumerState<SignupRequestScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  bool _obscure = true;
  bool _sending = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _formError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final email = _email.text.trim();
    setState(() {
      _nameError = name.length >= 2 ? null : l10n.nameTooShort;
      _emailError = _emailPattern.hasMatch(email) ? null : l10n.invalidEmail;
      _passwordError = _password.text.length >= 8
          ? null
          : l10n.resetPasswordShort;
      _confirmError = _confirm.text == _password.text
          ? null
          : l10n.resetPasswordMismatch;
      _formError = null;
    });
    if ([
      _nameError,
      _emailError,
      _passwordError,
      _confirmError,
    ].any((e) => e != null)) {
      return;
    }

    final draft = SignupDraft(
      fullName: name,
      email: email,
      password: _password.text,
    );
    setState(() => _sending = true);
    try {
      await ref
          .read(signupRequestProvider)
          .requestCode(
            draft,
            languageCode: Localizations.localeOf(context).languageCode,
          );
      if (mounted) context.push(RouteNames.signupVerify, extra: draft);
    } on ApiException catch (error) {
      if (mounted) setState(() => _formError = error.localized(l10n));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.space6),
            children: [
              AuthStepHeader(
                icon: Icons.person_add_alt_1_rounded,
                title: l10n.signupTitle,
                message: l10n.signupSubtitle,
              ),
              const SizedBox(height: AppDimensions.space6),
              TextField(
                controller: _name,
                enabled: !_sending,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: AppDimensions.space3),
              TextField(
                controller: _email,
                enabled: !_sending,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: AppDimensions.space3),
              TextField(
                controller: _password,
                enabled: !_sending,
                obscureText: _obscure,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: l10n.resetNewPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space3),
              TextField(
                controller: _confirm,
                enabled: !_sending,
                obscureText: _obscure,
                textInputAction: TextInputAction.send,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  labelText: l10n.resetConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  errorText: _confirmError,
                ),
              ),
              if (_formError != null) ...[
                const SizedBox(height: AppDimensions.space3),
                Text(_formError!, style: TextStyle(color: colors.error)),
              ],
              const SizedBox(height: AppDimensions.space6),
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
                  child: Text(l10n.signupHaveAccount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
