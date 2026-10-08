import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// A centered error placeholder with a retry action, shown when an
/// API-driven screen fails to load. Never displays raw backend/technical
/// error text — only a user-friendly message. Scrollable so it never
/// overflows on small screens or with large text.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message, this.onRetry});

  /// Defaults to the localized generic error message.
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.heroRadius),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: context.readable(AppColors.danger),
              ),
            ),
            const SizedBox(height: AppDimensions.space5),
            Text(
              l10n.errorTitle,
              style: AppTextStyles.headingMedium.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space2),
            Text(
              message ?? l10n.genericError,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.space5),
              AppButton(
                label: l10n.retry,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
