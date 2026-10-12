import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';

/// Full-screen outcome of an account request: a big icon, a title, an
/// explanation and one button.
class SignupResultView extends StatelessWidget {
  const SignupResultView({
    super.key,
    required this.success,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final bool success;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = success ? AppColors.success : AppColors.danger;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.mark_email_read_rounded : Icons.error_outline,
                  size: 48,
                  color: context.readable(accent),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.space2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.space6),
            SizedBox(
              width: double.infinity,
              child: AppButton(label: buttonLabel, onPressed: onPressed),
            ),
          ],
        ),
      ),
    );
  }
}
