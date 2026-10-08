import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// The backend currently has no password-reset endpoint. Keep this route
/// informative instead of presenting a form that cannot submit anything.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).passwordHelpTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_reset_rounded, size: 56, color: colors.primary),
              const SizedBox(height: AppDimensions.space4),
              Text(
                AppLocalizations.of(context).passwordHelpHeading,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingLarge.copyWith(
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.space2),
              Text(
                AppLocalizations.of(context).passwordHelpBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
