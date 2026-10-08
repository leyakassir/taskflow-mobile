import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/utils/date_utils.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_priority_badge.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_status_chip.dart';

class TaskPreviewCard extends StatelessWidget {
  const TaskPreviewCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deadlineColor = task.isPastDeadline
        ? context.readable(AppColors.danger)
        : colorScheme.onSurfaceVariant;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: () => context.push(RouteNames.taskDetailsPath(task.id)),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.space4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.titleFor(
                        Localizations.localeOf(context).languageCode,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space2),
                  TaskPriorityBadge(priority: task.priority),
                ],
              ),
              if (task.descriptionFor(
                    Localizations.localeOf(context).languageCode,
                  )
                  case final description? when description.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.space2),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.space4),
              Row(
                children: [
                  TaskStatusChip(status: task.status),
                  const Spacer(),
                  if (task.deadline != null) ...[
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: deadlineColor,
                    ),
                    const SizedBox(width: AppDimensions.space1),
                    Flexible(
                      child: Text(
                        _deadlineLabel(context, task.deadline!),
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: deadlineColor,
                          fontWeight: task.isPastDeadline
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: AppDimensions.space2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // API dates are UTC: count days and format on the local date.
  String _deadlineLabel(BuildContext context, DateTime deadline) {
    final days = calendarDaysFromToday(deadline);
    if (days == 0) {
      final locale = Localizations.localeOf(context).toLanguageTag();
      return AppLocalizations.of(context)
          .dueAtTime(DateFormat.jm(locale).format(deadline.toLocal()));
    }
    if (days == 1) return AppLocalizations.of(context).dueTomorrow;
    if (days < 0) return AppLocalizations.of(context).overdueDays(-days);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMd(locale).format(deadline.toLocal());
  }
}
