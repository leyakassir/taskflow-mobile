import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_priority_badge.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_priority_legend_item.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Explains the colored bar on the edge of each task card, in the same
/// style as the calendar's legend. High and urgent share red on the cards,
/// so they share one entry here.
class TaskPriorityLegend extends StatelessWidget {
  const TaskPriorityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppDimensions.space4,
      runSpacing: AppDimensions.space2,
      children: [
        TaskPriorityLegendItem(
          color: TaskPriorityBadge.colorFor(TaskPriority.low),
          label: l10n.priorityLow,
        ),
        TaskPriorityLegendItem(
          color: TaskPriorityBadge.colorFor(TaskPriority.medium),
          label: l10n.priorityMedium,
        ),
        TaskPriorityLegendItem(
          color: TaskPriorityBadge.colorFor(TaskPriority.high),
          label: '${l10n.priorityHigh} / ${l10n.priorityUrgent}',
        ),
      ],
    );
  }
}
