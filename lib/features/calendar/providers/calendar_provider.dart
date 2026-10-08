import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/utils/date_utils.dart';
import 'package:taskflow_mobile/features/calendar/domain/entities/calendar_entry.dart';
import 'package:taskflow_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';

/// First day of the month currently shown by the calendar.
final calendarFocusedMonthProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final calendarSelectedDayProvider = StateProvider.autoDispose<DateTime>(
  (ref) => dateOnly(DateTime.now()),
);

/// Tasks for one month only, so the calendar never loads the full list.
final calendarMonthTasksProvider = FutureProvider.autoDispose
    .family<List<Task>, DateTime>((ref, month) {
      final from = DateTime(month.year, month.month);
      final to = DateTime(
        month.year,
        month.month + 1,
      ).subtract(const Duration(milliseconds: 1));
      return ref
          .read(taskRepositoryProvider)
          .getTasksInRange(from: from, to: to);
    });

/// Calendar entries for the focused month, keyed by local calendar day.
final calendarEntriesProvider =
    Provider.autoDispose<AsyncValue<Map<DateTime, List<CalendarEntry>>>>((ref) {
      final month = ref.watch(calendarFocusedMonthProvider);
      return ref
          .watch(calendarMonthTasksProvider(month))
          .whenData(CalendarEntry.groupByDay);
    });
