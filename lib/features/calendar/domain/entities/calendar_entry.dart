import 'package:taskflow_mobile/core/utils/date_utils.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';

enum CalendarEntryKind { start, deadline }

/// A task placed on one calendar day, either on its start date or on its
/// deadline. Built from existing task data; there is no separate event model.
class CalendarEntry {
  const CalendarEntry({required this.task, required this.kind});

  final Task task;
  final CalendarEntryKind kind;

  DateTime get dateTime =>
      (kind == CalendarEntryKind.deadline ? task.deadline! : task.startDate!)
          .toLocal();

  bool get isOverdue =>
      task.status == TaskStatus.overdue || task.isPastDeadline;

  /// Groups tasks by local calendar day. A task appears on its deadline day
  /// and, when set, on its start day (once, if both fall on the same day).
  static Map<DateTime, List<CalendarEntry>> groupByDay(List<Task> tasks) {
    final byDay = <DateTime, List<CalendarEntry>>{};
    void add(DateTime day, CalendarEntry entry) =>
        byDay.putIfAbsent(day, () => []).add(entry);

    for (final task in tasks) {
      final deadlineDay = task.deadline == null
          ? null
          : localDateOf(task.deadline!);
      if (deadlineDay != null) {
        add(
          deadlineDay,
          CalendarEntry(task: task, kind: CalendarEntryKind.deadline),
        );
      }
      if (task.startDate != null) {
        final startDay = localDateOf(task.startDate!);
        if (deadlineDay == null || startDay != deadlineDay) {
          add(
            startDay,
            CalendarEntry(task: task, kind: CalendarEntryKind.start),
          );
        }
      }
    }
    for (final entries in byDay.values) {
      entries.sort(_compare);
    }
    return byDay;
  }

  // Overdue first, then higher priority, then earlier time.
  static int _compare(CalendarEntry a, CalendarEntry b) {
    if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
    final byPriority = b.task.priority.index.compareTo(a.task.priority.index);
    if (byPriority != 0) return byPriority;
    return a.dateTime.compareTo(b.dateTime);
  }
}
