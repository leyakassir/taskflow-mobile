import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/calendar/domain/entities/calendar_entry.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_marker_dot.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_priority_color.dart';

/// Up to three markers under a day number, plus a "+" when there are more.
class CalendarDayMarkers extends StatelessWidget {
  const CalendarDayMarkers({super.key, required this.entries});

  static const _maxDots = 3;

  final List<CalendarEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visible = entries.take(_maxDots);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in visible)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: CalendarMarkerDot(
              color: calendarPriorityColor(entry.task.priority),
              overdue: entry.isOverdue,
            ),
          ),
        if (entries.length > _maxDots)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppDimensions.space1 / 2,
            ),
            child: Text(
              '+',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 0.8,
              ),
            ),
          ),
      ],
    );
  }
}
