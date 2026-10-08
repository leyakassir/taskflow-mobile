import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Shown on the splash screen instead of the loading bar when starting the
/// app fails (backend unreachable, server error, ...). The user stays on
/// the splash and can retry.
class SplashErrorPanel extends StatelessWidget {
  const SplashErrorPanel({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final message = error is ApiException
        ? (error as ApiException).localized(l10n)
        : l10n.genericError;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off_rounded, size: 32, color: colorScheme.error),
        const SizedBox(height: AppDimensions.space3),
        Text(
          l10n.splashErrorTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.headingMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.space2),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.space5),
        AppButton(
          label: l10n.retry,
          onPressed: onRetry,
          icon: Icons.refresh_rounded,
        ),
      ],
    );
  }
}
