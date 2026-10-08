import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/utils/date_utils.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// One notification. Unread items have a tinted background, a primary
/// border, bold title and a dot; the icon reflects the kind of event.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final (icon, hue) = _iconFor(notification.kind);
    final iconColor = context.readable(hue);
    final unread = !notification.isRead;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: unread
            ? colorScheme.primary.withValues(alpha: 0.07)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: unread
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.space4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.fieldRadius,
                    ),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: AppDimensions.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space1),
                      Text(
                        notification.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space1),
                      Text(
                        relativeTimeLabel(notification.createdAt, l10n),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsetsDirectional.only(
                      start: AppDimensions.space2,
                      top: AppDimensions.space1,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _iconFor(NotificationKind kind) => switch (kind) {
    NotificationKind.taskAssigned => (
      Icons.assignment_ind_outlined,
      AppColors.info,
    ),
    NotificationKind.taskReassigned => (
      Icons.swap_horiz_rounded,
      AppColors.info,
    ),
    NotificationKind.taskUnassigned => (
      Icons.person_remove_outlined,
      AppColors.neutral,
    ),
    NotificationKind.taskDueSoon => (Icons.alarm_rounded, AppColors.warning),
    NotificationKind.taskOverdue => (
      Icons.error_outline_rounded,
      AppColors.danger,
    ),
    NotificationKind.taskCancelled => (Icons.block_rounded, AppColors.neutral),
    NotificationKind.taskUpdated => (Icons.edit_note_rounded, AppColors.info),
    NotificationKind.taskSubmitted => (
      Icons.task_alt_rounded,
      AppColors.success,
    ),
    NotificationKind.taskComment => (Icons.forum_outlined, AppColors.brandBlue),
    NotificationKind.dailySummary => (
      Icons.wb_sunny_outlined,
      AppColors.warning,
    ),
    NotificationKind.generic => (
      Icons.notifications_none_rounded,
      AppColors.neutral,
    ),
  };
}
