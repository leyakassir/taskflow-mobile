import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/utils/date_utils.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_comment_avatar.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// One comment. Admin/manager comments get a brand-tinted bubble and a role
/// badge so they stand apart from the worker's own comments.
class TaskCommentTile extends StatelessWidget {
  const TaskCommentTile({
    super.key,
    required this.comment,
    required this.isOwn,
  });

  final TaskComment comment;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isStaff = comment.author.isStaff;
    final accent = colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskCommentAvatar(author: comment.author),
        const SizedBox(width: AppDimensions.space3),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.space3),
            decoration: BoxDecoration(
              color: isStaff
                  ? accent.withValues(alpha: 0.08)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
              border: Border.all(
                color: isStaff
                    ? accent.withValues(alpha: 0.35)
                    : colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppDimensions.space2,
                  runSpacing: AppDimensions.space1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      isOwn ? l10n.commentYou : comment.author.fullName,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isStaff) _RoleBadge(role: comment.author.role),
                    Text(
                      relativeTimeLabel(comment.createdAt, l10n),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space1),
                Text(
                  comment.body,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 12, color: accent),
          const SizedBox(width: AppDimensions.space1),
          Text(
            role == 'ADMIN' ? l10n.commentRoleAdmin : l10n.commentRoleManager,
            style: AppTextStyles.labelSmall.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
