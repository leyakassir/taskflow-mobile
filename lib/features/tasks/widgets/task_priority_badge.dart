import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// A compact badge showing a task's priority level. Visually distinct
/// from [TaskStatusChip] (a small flag glyph instead of a status icon,
/// tighter padding) so the two read as separate signals when shown
/// together on a task card.
class TaskPriorityBadge extends StatelessWidget {
  const TaskPriorityBadge({super.key, required this.priority});

  final TaskPriority priority;

  /// Accent for a priority: high/urgent red, medium amber, low indigo.
  /// Also used for the task card's priority bar.
  static Color colorFor(TaskPriority priority) => switch (priority) {
    TaskPriority.low => AppColors.info,
    TaskPriority.medium => AppColors.warning,
    TaskPriority.high || TaskPriority.urgent => AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(context, priority);
    final foreground = context.readable(style.foreground);

    return Container(
      // Outlined pill, so it never competes with the filled status chip.
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 11, color: foreground),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _PriorityStyle _styleFor(BuildContext context, TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return _PriorityStyle(
          label: AppLocalizations.of(context).priorityLow,
          foreground: AppColors.info,
          background: AppColors.infoBg,
        );
      case TaskPriority.medium:
        return _PriorityStyle(
          label: AppLocalizations.of(context).priorityMedium,
          foreground: AppColors.warning,
          background: AppColors.warningBg,
        );
      case TaskPriority.high:
        return _PriorityStyle(
          label: AppLocalizations.of(context).priorityHigh,
          foreground: AppColors.danger,
          background: AppColors.dangerBg,
        );
      case TaskPriority.urgent:
        return _PriorityStyle(
          label: AppLocalizations.of(context).priorityUrgent,
          foreground: AppColors.danger,
          background: AppColors.dangerBg,
        );
    }
  }
}

class _PriorityStyle {
  const _PriorityStyle({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;
}
