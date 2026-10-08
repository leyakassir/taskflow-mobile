import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_marker_dot.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_priority_color.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Explains the marker colors (priority) and the overdue ring.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: AppDimensions.space4,
      runSpacing: AppDimensions.space2,
      children: [
        for (final priority in TaskPriority.values)
          _LegendItem(
            dot: CalendarMarkerDot(
              color: calendarPriorityColor(priority),
              size: 8,
            ),
            label: calendarPriorityLabel(l10n, priority),
          ),
        _LegendItem(
          dot: const CalendarMarkerDot(
            color: AppColors.danger,
            overdue: true,
            size: 8,
          ),
          label: l10n.calendarOverdue,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.dot, required this.label});

  final Widget dot;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: AppDimensions.space1),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
