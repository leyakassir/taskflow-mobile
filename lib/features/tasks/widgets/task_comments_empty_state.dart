import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Compact empty state that fits inside the comments card.
class TaskCommentsEmptyState extends StatelessWidget {
  const TaskCommentsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space4),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 32,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppDimensions.space2),
          Text(
            l10n.commentsEmptyTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.space1),
          Text(
            l10n.commentsEmptyMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
