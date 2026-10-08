import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Priority color used by calendar markers, the legend and day tiles. Each
/// priority gets its own hue so markers stay distinguishable; overdue items
/// use [AppColors.danger] with a ring shape instead of a fill.
Color calendarPriorityColor(TaskPriority priority) => switch (priority) {
  TaskPriority.low => AppColors.neutral,
  TaskPriority.medium => AppColors.info,
  TaskPriority.high => AppColors.warning,
  TaskPriority.urgent => AppColors.danger,
};

String calendarPriorityLabel(AppLocalizations l10n, TaskPriority priority) =>
    switch (priority) {
      TaskPriority.low => l10n.priorityLow,
      TaskPriority.medium => l10n.priorityMedium,
      TaskPriority.high => l10n.priorityHigh,
      TaskPriority.urgent => l10n.priorityUrgent,
    };
