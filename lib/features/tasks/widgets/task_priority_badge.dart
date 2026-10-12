import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_priority_color.dart';
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

  /// Accent for a priority, the same as on the calendar: low grey, medium
  /// indigo, high amber, urgent red. Also used for the task card's bar.
  static Color colorFor(TaskPriority priority) =>
      calendarPriorityColor(priority);

  @override
  Widget build(BuildContext context) {
    final foreground = context.readable(colorFor(priority));
    final label = calendarPriorityLabel(AppLocalizations.of(context), priority);

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
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
