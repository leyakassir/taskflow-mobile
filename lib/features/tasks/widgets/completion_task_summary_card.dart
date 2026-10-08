import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_priority_badge.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_status_chip.dart';

/// Compact task summary at the top of the complete-task screen.
class CompletionTaskSummaryCard extends StatelessWidget {
  const CompletionTaskSummaryCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
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
                  task.titleFor(Localizations.localeOf(context).languageCode),
                  style: AppTextStyles.headingSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimensions.itemSpacing),
              TaskPriorityBadge(priority: task.priority),
            ],
          ),
          const SizedBox(height: AppDimensions.itemSpacing),
          TaskStatusChip(status: task.status),
        ],
      ),
    );
  }
}
