import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';
import 'package:taskflow_mobile/features/auth/providers/signup_request_provider.dart';
import 'package:taskflow_mobile/features/auth/widgets/auth_step_header.dart';
import 'package:taskflow_mobile/features/auth/widgets/otp_code_field.dart';
import 'package:taskflow_mobile/features/auth/widgets/resend_code_button.dart';
import 'package:taskflow_mobile/features/auth/widgets/signup_result_view.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

enum _Outcome { none, sent, notSent }

/// "Request an account", step 2: the emailed code. A correct code sends
/// the request to the admins; a wrong or expired one means it was not sent.
class SignupVerifyScreen extends ConsumerStatefulWidget {
  const SignupVerifyScreen({super.key, required this.draft});

  final SignupDraft draft;

  @override
  ConsumerState<SignupVerifyScreen> createState() => _SignupVerifyScreenState();
}

class _SignupVerifyScreenState extends ConsumerState<SignupVerifyScreen> {
  final _code = TextEditingController();
  bool _sending = false;
  String? _codeError;
  _Outcome _outcome = _Outcome.none;
  String? _notSentReason;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context);
    final code = _code.text.trim();
    if (code.length != OtpCodeField.length) {
      setState(() => _codeError = l10n.resetCodeInvalid);
      return;
    }
    setState(() {
      _sending = true;
      _codeError = null;
    });
    try {
      await ref.read(signupRequestProvider).verify(widget.draft.email, code);
      if (mounted) setState(() => _outcome = _Outcome.sent);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _outcome = _Outcome.notSent;
        _notSentReason = switch (error.statusCode) {
          400 => l10n.signupNotSentCode,
          409 => l10n.signupNotSentExists,
          _ => error.localized(l10n),
        };
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(signupRequestProvider)
          .requestCode(
            widget.draft,
            languageCode: Localizations.localeOf(context).languageCode,
          );
      _code.clear();
      setState(() {
        _codeError = null;
        _outcome = _Outcome.none;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.resetCodeSent)));
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.localized(l10n))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: switch (_outcome) {
          _Outcome.sent => SignupResultView(
            success: true,
            title: l10n.signupSentTitle,
            message: l10n.signupSentMessage(widget.draft.email),
            buttonLabel: l10n.forgotBackToLogin,
            onPressed: () => context.go(RouteNames.login),
          ),
          _Outcome.notSent => SignupResultView(
            success: false,
            title: l10n.signupNotSentTitle,
            message: _notSentReason ?? l10n.signupNotSentCode,
            buttonLabel: l10n.signupTryAgain,
            onPressed: () => setState(() {
              _outcome = _Outcome.none;
              _code.clear();
            }),
          ),
          _Outcome.none => ListView(
            padding: const EdgeInsets.all(AppDimensions.space6),
            children: [
              AuthStepHeader(
                icon: Icons.mark_email_read_outlined,
                title: l10n.resetTitle,
                message: l10n.signupVerifySubtitle(widget.draft.email),
              ),
              const SizedBox(height: AppDimensions.space6),
              OtpCodeField(
                controller: _code,
                label: l10n.resetCodeLabel,
                errorText: _codeError,
                enabled: !_sending,
                onCompleted: _verify,
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ResendCodeButton(
                  cooldown: SignupRequestActions.resendAfter,
                  onResend: _resend,
                ),
              ),
              Text(
                l10n.resetCheckSpam,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              AppButton(
                label: l10n.signupSendRequest,
                icon: Icons.send_rounded,
                isLoading: _sending,
                onPressed: _sending ? null : _verify,
              ),
            ],
          ),
        },
      ),
    );
  }
}
