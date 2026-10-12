import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';

/// Icon tile, title and explanation at the top of a password-reset step.
class AuthStepHeader extends StatelessWidget {
  const AuthStepHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 28, color: colors.onPrimaryContainer),
        ),
        const SizedBox(height: AppDimensions.space5),
        Text(
          title,
          style: AppTextStyles.displaySmall.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.space2),
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
