import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/core/widgets/loading_indicator.dart';
import 'package:taskflow_mobile/features/calendar/providers/calendar_provider.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_day_tasks.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_legend.dart';
import 'package:taskflow_mobile/features/calendar/widgets/task_month_calendar.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final month = ref.watch(calendarFocusedMonthProvider);
    final selectedDay = ref.watch(calendarSelectedDayProvider);
    final entriesAsync = ref.watch(calendarEntriesProvider);
    final entriesByDay = entriesAsync.value ?? const {};

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendarTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(calendarMonthTasksProvider(month).future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: [
            TaskMonthCalendar(
              focusedMonth: month,
              selectedDay: selectedDay,
              entriesByDay: entriesByDay,
              onDaySelected: (day) =>
                  ref.read(calendarSelectedDayProvider.notifier).state = day,
              onMonthChanged: (newMonth) =>
                  ref.read(calendarFocusedMonthProvider.notifier).state =
                      newMonth,
            ),
            const SizedBox(height: AppDimensions.space3),
            const CalendarLegend(),
            const SizedBox(height: AppDimensions.sectionSpacing),
            entriesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppDimensions.space7),
                child: LoadingIndicator(),
              ),
              error: (_, _) => ErrorView(
                message: l10n.calendarLoadError,
                onRetry: () =>
                    ref.invalidate(calendarMonthTasksProvider(month)),
              ),
              data: (byDay) => CalendarDayTasks(
                day: selectedDay,
                entries: byDay[selectedDay] ?? const [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
