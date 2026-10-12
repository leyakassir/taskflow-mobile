import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_priority_color.dart';
import 'package:taskflow_mobile/features/home/widgets/priority_pill.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// URGENT / HIGH / MEDIUM / LOW pills, each with a count badge, in the
/// app's priority colors (the same as the calendar and task cards).
class PriorityBreakdownRow extends StatelessWidget {
  const PriorityBreakdownRow({
    super.key,
    required this.urgent,
    required this.high,
    required this.medium,
    required this.low,
  });

  final int urgent;
  final int high;
  final int medium;
  final int low;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final counts = {
      TaskPriority.urgent: urgent,
      TaskPriority.high: high,
      TaskPriority.medium: medium,
      TaskPriority.low: low,
    };
    return Wrap(
      spacing: AppDimensions.space2,
      runSpacing: AppDimensions.space2,
      children: [
        for (final MapEntry(key: priority, value: count) in counts.entries)
          PriorityPill(
            label: calendarPriorityLabel(l10n, priority),
            count: count,
            color: calendarPriorityColor(priority),
          ),
      ],
    );
  }
}
