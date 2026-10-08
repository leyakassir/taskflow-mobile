import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/profile/providers/profile_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_comments_provider.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_comment_input.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_comment_list.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_comments_empty_state.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Comments card on the task details screen: loading, error, empty and
/// list states, plus the input. Pull-to-refresh is handled by the screen.
class TaskCommentsSection extends ConsumerWidget {
  const TaskCommentsSection({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final commentsAsync = ref.watch(taskCommentsControllerProvider(taskId));
    final controller = ref.read(
      taskCommentsControllerProvider(taskId).notifier,
    );
    final currentUserId = ref.watch(profileControllerProvider).value?.id;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.forum_outlined, size: 18, color: colorScheme.primary),
              const SizedBox(width: AppDimensions.space2),
              Text(
                l10n.commentsTitle,
                style: AppTextStyles.headingSmall.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space3),
          commentsAsync.when(
            skipLoadingOnRefresh: true,
            loading: () => const Padding(
              padding: EdgeInsets.all(AppDimensions.space4),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => Center(
              child: Column(
                children: [
                  Text(
                    l10n.commentsLoadFailed,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        ref.invalidate(taskCommentsControllerProvider(taskId)),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
            data: (state) => state.comments.isEmpty
                ? const TaskCommentsEmptyState()
                : TaskCommentList(
                    comments: state.comments,
                    currentUserId: currentUserId,
                    hasMore: state.hasMore,
                    loadingMore: state.loadingMore,
                    loadMoreFailed: state.loadMoreFailed,
                    onLoadMore: controller.loadMore,
                  ),
          ),
          const SizedBox(height: AppDimensions.space3),
          TaskCommentInput(taskId: taskId),
        ],
      ),
    );
  }
}
