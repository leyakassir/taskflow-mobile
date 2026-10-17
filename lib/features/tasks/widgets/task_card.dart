import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/utils/date_utils.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_priority_badge.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_progress_indicator.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_status_chip.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// The primary task list item, shown on the Tasks screen and Home
/// screen's "today's tasks" section. Tapping opens the task details.
///
/// A 4px bar on the start edge shows the priority (high red, medium amber,
/// low indigo); the priority name is still announced to screen readers.
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final languageCode = Localizations.localeOf(context).languageCode;
    final isOverdue = task.isPastDeadline;
    final deadlineColor = isOverdue
        ? context.readable(AppColors.danger)
        : colorScheme.onSurfaceVariant;
    final description = task.descriptionFor(languageCode) ?? '';
    final radius = BorderRadius.circular(AppDimensions.taskCardRadius);

    return Card(
      shape: Theme.of(context).cardTheme.shape is RoundedRectangleBorder
          ? (Theme.of(context).cardTheme.shape! as RoundedRectangleBorder)
                .copyWith(borderRadius: radius)
          : RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: _priorityLabel(context, task.priority),
                child: Container(
                  width: 4,
                  color: TaskPriorityBadge.colorFor(task.priority),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppDimensions.space4,
                    AppDimensions.space4,
                    AppDimensions.space4,
                    AppDimensions.space4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.titleFor(languageCode),
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space1),
                        Text(
                          description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppDimensions.space3),
                      // Wrap instead of Row: on narrow screens or with large
                      // text the deadline moves under the status chip.
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppDimensions.space2,
                        runSpacing: AppDimensions.space2,
                        children: [
                          TaskStatusChip(status: task.status),
                          if (task.deadline != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: deadlineColor,
                                ),
                                const SizedBox(width: AppDimensions.space1),
                                Text(
                                  _formatDeadline(context, task.deadline!),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: deadlineColor,
                                    fontWeight: isOverdue
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (task.requiresChecklist &&
                          task.checklistItems.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space3),
                        TaskProgressIndicator(
                          completed: task.checklistItems
                              .where((c) => c.done)
                              .length,
                          total: task.checklistItems.length,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _priorityLabel(BuildContext context, TaskPriority priority) {
  final l10n = AppLocalizations.of(context);
  return switch (priority) {
    TaskPriority.low => l10n.priorityLow,
    TaskPriority.medium => l10n.priorityMedium,
    TaskPriority.high => l10n.priorityHigh,
    TaskPriority.urgent => l10n.priorityUrgent,
  };
}

/// Short deadline label. API dates are UTC, so days are counted on the
/// local calendar date; other dates use the app locale's month names.
String _formatDeadline(BuildContext context, DateTime deadline) {
  final l10n = AppLocalizations.of(context);
  final days = calendarDaysFromToday(deadline);
  if (days == 0) return l10n.dayToday;
  if (days == 1) return l10n.dayTomorrow;
  if (days == -1) return l10n.dayYesterday;
  if (days < 0) return l10n.overdueDays(-days);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.MMMd(locale).format(deadline.toLocal());
}
