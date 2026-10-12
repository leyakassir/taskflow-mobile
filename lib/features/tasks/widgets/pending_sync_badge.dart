import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/offline/sync_queue.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// "Waiting to sync" pill on a task that has changes not on the server yet.
/// Renders nothing otherwise.
class PendingSyncBadge extends ConsumerWidget {
  const PendingSyncBadge({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(pendingTaskIdsProvider).contains(taskId)) {
      return const SizedBox.shrink();
    }
    final color = context.readable(AppColors.warning);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context).pendingSyncBadge,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
