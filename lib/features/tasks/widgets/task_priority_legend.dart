import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_priority_color.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_priority_badge.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_priority_legend_item.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Explains the colored bar on the edge of each task card. Same colors as
/// the calendar's legend.
class TaskPriorityLegend extends StatelessWidget {
  const TaskPriorityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppDimensions.space4,
      runSpacing: AppDimensions.space2,
      children: [
        for (final priority in TaskPriority.values)
          TaskPriorityLegendItem(
            color: TaskPriorityBadge.colorFor(priority),
            label: calendarPriorityLabel(l10n, priority),
          ),
      ],
    );
  }
}
