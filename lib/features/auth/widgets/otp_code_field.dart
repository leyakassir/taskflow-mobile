import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:taskflow_mobile/app/theme/app_text_styles.dart';

/// One field for the 6-digit emailed code: digits only, large spaced
/// numbers, and the system's one-time-code autofill (so the keyboard can
/// offer the code from the email). Always left-to-right, even in Arabic.
class OtpCodeField extends StatelessWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.enabled = true,
    this.onCompleted,
  });

  static const length = 6;

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool enabled;
  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: controller,
        enabled: enabled,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(length),
        ],
        textAlign: TextAlign.center,
        style: AppTextStyles.displaySmall.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 12,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onChanged: (value) {
          if (value.length == length) onCompleted?.call();
        },
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          counterText: '',
          hintText: '••••••',
        ),
      ),
    );
  }
}
