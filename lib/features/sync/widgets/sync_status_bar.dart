import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/offline/connectivity_provider.dart';
import 'package:taskflow_mobile/core/offline/sync_queue.dart';
import 'package:taskflow_mobile/features/sync/providers/sync_provider.dart';
import 'package:taskflow_mobile/features/sync/widgets/sync_failures_sheet.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Slim bar above the bottom navigation: offline state, unsent changes,
/// syncing progress, and changes the server refused. Hidden when online
/// with nothing pending. Watching the sync controller also keeps it
/// running for the whole signed-in session.
class SyncStatusBar extends ConsumerWidget {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final online = ref.watch(connectivityProvider);
    final pending = ref.watch(syncQueueProvider).length;
    final sync = ref.watch(syncControllerProvider);

    final (IconData, Color, String)? content = !online
        ? (
            Icons.cloud_off_rounded,
            AppColors.neutral,
            pending > 0
                ? '${l10n.syncOffline} ${l10n.syncWaiting(pending)}'
                : l10n.syncOffline,
          )
        : sync.isSyncing
        ? (Icons.sync_rounded, AppColors.info, l10n.syncSyncing)
        : sync.failures.isNotEmpty
        ? (
            Icons.error_outline_rounded,
            AppColors.danger,
            l10n.syncFailedCount(sync.failures.length),
          )
        : pending > 0
        ? (
            Icons.cloud_upload_outlined,
            AppColors.warning,
            l10n.syncWaiting(pending),
          )
        : null;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: content == null
          ? const SizedBox(width: double.infinity)
          : Material(
              color: content.$2.withValues(alpha: 0.14),
              child: InkWell(
                onTap: sync.failures.isNotEmpty
                    ? () => showModalBottomSheet<void>(
                        context: context,
                        builder: (_) => const SyncFailuresSheet(),
                      )
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.pagePadding,
                    vertical: AppDimensions.space2,
                  ),
                  child: Row(
                    children: [
                      if (sync.isSyncing && online)
                        SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.readable(content.$2),
                          ),
                        )
                      else
                        Icon(
                          content.$1,
                          size: 18,
                          color: context.readable(content.$2),
                        ),
                      const SizedBox(width: AppDimensions.space2),
                      Expanded(
                        child: Text(
                          content.$3,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      if (sync.failures.isNotEmpty && online)
                        Text(
                          l10n.syncDetails,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        )
                      else if (online && pending > 0 && !sync.isSyncing)
                        TextButton(
                          onPressed: () =>
                              ref.read(syncControllerProvider.notifier).sync(),
                          child: Text(l10n.retry),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
