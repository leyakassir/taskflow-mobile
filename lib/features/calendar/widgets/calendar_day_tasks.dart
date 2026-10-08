import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/widgets/empty_state.dart';
import 'package:taskflow_mobile/features/calendar/domain/entities/calendar_entry.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_task_tile.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Header plus the list of the selected day's tasks, or an empty state.
class CalendarDayTasks extends StatelessWidget {
  const CalendarDayTasks({super.key, required this.day, required this.entries});

  final DateTime day;
  final List<CalendarEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat.MMMMEEEEd(locale).format(day),
                style: AppTextStyles.headingMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              l10n.calendarTaskCount(entries.length),
              style: AppTextStyles.labelMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.itemSpacing),
        if (entries.isEmpty)
          EmptyState(
            icon: Icons.event_available_rounded,
            title: l10n.calendarNoTasksTitle,
            message: l10n.calendarNoTasksMessage,
          )
        else
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.itemSpacing),
              child: CalendarTaskTile(
                entry: entry,
                onTap: () =>
                    context.push(RouteNames.taskDetailsPath(entry.task.id)),
              ),
            ),
      ],
    );
  }
}
