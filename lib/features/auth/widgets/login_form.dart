import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';
import 'package:taskflow_mobile/core/widgets/app_text_field.dart';
import 'package:taskflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';
import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    final password = _password.text;

    setState(() => _errorMessage = null);

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = l10n.fieldsRequired);
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = l10n.invalidEmail);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(email: email, password: password);
      // Success: router will redirect based on auth state. No manual nav here.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.localized(l10n));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.genericError);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _email,
          labelText: l10n.email,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.alternate_email_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppDimensions.space3),
        AppTextField(
          controller: _password,
          labelText: l10n.password,
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_rounded,
          suffixIcon: IconButton(
            tooltip: _obscurePassword
                ? AppLocalizations.of(context).showPassword
                : AppLocalizations.of(context).hidePassword,
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppDimensions.space2),
          Text(
            _errorMessage!,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.space6),
        AppButton(
          label: l10n.signIn,
          height: 52,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submit,
        ),
        const SizedBox(height: AppDimensions.space2),
        Center(
          child: TextButton(
            onPressed: () => context.push(RouteNames.forgotPassword),
            child: Text(AppLocalizations.of(context).forgotPassword),
          ),
        ),
      ],
    );
  }
}
