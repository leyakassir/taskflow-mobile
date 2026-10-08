import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_priority_badge.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_status_chip.dart';

/// Top card of the task details screen: status, priority, title and
/// description.
class TaskDetailsHero extends StatelessWidget {
  const TaskDetailsHero({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final description =
        task
            .descriptionFor(Localizations.localeOf(context).languageCode)
            ?.trim() ??
        '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppDimensions.space2,
              runSpacing: AppDimensions.space2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TaskStatusChip(status: task.status, prominent: true),
                TaskPriorityBadge(priority: task.priority),
              ],
            ),
            const SizedBox(height: AppDimensions.space4),
            Text(
              task.titleFor(Localizations.localeOf(context).languageCode),
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.space2),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
