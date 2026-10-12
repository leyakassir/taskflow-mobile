import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/offline/pending_operation.dart';
import 'package:taskflow_mobile/features/sync/providers/sync_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Lists the offline changes the server refused, with its reason.
class SyncFailuresSheet extends ConsumerWidget {
  const SyncFailuresSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final failures = ref.watch(syncControllerProvider).failures;

    String action(PendingOperationType type) => switch (type) {
      PendingOperationType.updateTaskStatus => l10n.syncActionStatus,
      PendingOperationType.uploadAttachment => l10n.syncActionUpload,
      PendingOperationType.completeTask => l10n.syncActionComplete,
      PendingOperationType.addComment => l10n.syncActionComment,
      PendingOperationType.markNotificationRead ||
      PendingOperationType.markAllNotificationsRead =>
        l10n.syncActionNotification,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          0,
          AppDimensions.pagePadding,
          AppDimensions.pagePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.syncFailuresTitle,
              style: AppTextStyles.headingMedium.copyWith(
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.space2),
            Text(
              l10n.syncFailuresMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.space3),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final failure in failures)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.error_outline_rounded,
                        color: context.readable(AppColors.danger),
                      ),
                      title: Text(
                        failure.taskTitle == null
                            ? action(failure.operation.type)
                            : '${action(failure.operation.type)} · ${failure.taskTitle}',
                      ),
                      subtitle: Text(failure.message),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space3),
            FilledButton(
              onPressed: () {
                ref.read(syncControllerProvider.notifier).dismissFailures();
                Navigator.of(context).pop();
              },
              child: Text(l10n.syncDismiss),
            ),
          ],
        ),
      ),
    );
  }
}
