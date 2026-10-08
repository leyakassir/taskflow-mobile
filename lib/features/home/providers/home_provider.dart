import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/utils/date_utils.dart';

import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';

final homeOverviewProvider = Provider<AsyncValue<HomeOverview>>((ref) {
  return ref.watch(tasksControllerProvider).whenData(HomeOverview.fromTasks);
});

class HomeOverview {
  const HomeOverview({
    required this.assignedCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.completedThisWeek,
    required this.overdueCount,
    required this.dueToday,
    required this.upcoming,
    required this.priorityTasks,
    required this.currentTask,
    required this.recentTasks,
    required this.weekTotal,
    required this.weekCompleted,
    required this.onTimeRate,
    required this.highPriorityCount,
    required this.mediumPriorityCount,
    required this.lowPriorityCount,
  });

  final int assignedCount;
  final int inProgressCount;
  final int completedCount;
  final int completedThisWeek;
  final int overdueCount;
  final List<Task> dueToday;
  final List<Task> upcoming;
  final List<Task> priorityTasks;
  final Task? currentTask;
  final List<Task> recentTasks;

  /// Tasks created this week (Monday onward) and how many of them are done.
  final int weekTotal;
  final int weekCompleted;

  /// Share of completed tasks (with a deadline) finished before it, 0..1.
  /// Null when no completed task has a deadline yet.
  final double? onTimeRate;

  /// Counts over all loaded tasks; urgent is counted as high.
  final int highPriorityCount;
  final int mediumPriorityCount;
  final int lowPriorityCount;

  factory HomeOverview.fromTasks(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final activeTasks = tasks.where(_isActive).toList();
    final activeOrdered = [...activeTasks]
      ..sort((a, b) {
        final aProgress = a.status == TaskStatus.inProgress ? 0 : 1;
        final bProgress = b.status == TaskStatus.inProgress ? 0 : 1;
        final byProgress = aProgress.compareTo(bProgress);
        if (byProgress != 0) return byProgress;
        if (a.deadline == null) return b.deadline == null ? 0 : 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
    final recentTasks = [...tasks]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final dueToday =
        activeTasks
            .where(
              (task) =>
                  task.deadline != null &&
                  isSameDate(localDateOf(task.deadline!), today),
            )
            .toList()
          ..sort(_deadlineOrder);

    final upcoming =
        activeTasks
            .where(
              (task) =>
                  task.deadline != null && task.deadline!.isAfter(tomorrow),
            )
            .toList()
          ..sort(_deadlineOrder);

    final priorityTasks =
        activeTasks
            .where(
              (task) =>
                  task.priority == TaskPriority.high ||
                  task.priority == TaskPriority.urgent,
            )
            .toList()
          ..sort((a, b) => b.priority.index.compareTo(a.priority.index));

    final weekTasks = tasks
        .where((task) => !task.createdAt.toLocal().isBefore(weekStart))
        .toList();
    final completedWithDeadline = tasks
        .where(
          (task) =>
              task.status == TaskStatus.completed &&
              task.deadline != null &&
              task.completionTimestamp != null,
        )
        .toList();
    final onTime = completedWithDeadline
        .where((task) => !task.completionTimestamp!.isAfter(task.deadline!))
        .length;

    return HomeOverview(
      weekTotal: weekTasks.length,
      weekCompleted: weekTasks
          .where((task) => task.status == TaskStatus.completed)
          .length,
      onTimeRate: completedWithDeadline.isEmpty
          ? null
          : onTime / completedWithDeadline.length,
      highPriorityCount: tasks
          .where(
            (task) =>
                task.priority == TaskPriority.high ||
                task.priority == TaskPriority.urgent,
          )
          .length,
      mediumPriorityCount: tasks
          .where((task) => task.priority == TaskPriority.medium)
          .length,
      lowPriorityCount: tasks
          .where((task) => task.priority == TaskPriority.low)
          .length,
      assignedCount: tasks
          .where((task) => task.status == TaskStatus.assigned)
          .length,
      inProgressCount: tasks
          .where((task) => task.status == TaskStatus.inProgress)
          .length,
      completedCount: tasks
          .where((task) => task.status == TaskStatus.completed)
          .length,
      completedThisWeek: tasks.where((task) {
        final completedAt = task.completionTimestamp;
        return completedAt != null &&
            !completedAt.isBefore(weekStart) &&
            !completedAt.isAfter(now);
      }).length,
      overdueCount: tasks
          .where(
            (task) =>
                task.status == TaskStatus.overdue ||
                (task.isPastDeadline && _isActive(task)),
          )
          .length,
      dueToday: dueToday,
      upcoming: upcoming,
      priorityTasks: priorityTasks,
      currentTask: activeOrdered.isEmpty ? null : activeOrdered.first,
      recentTasks: recentTasks,
    );
  }

  static bool _isActive(Task task) =>
      task.status != TaskStatus.completed &&
      task.status != TaskStatus.cancelled;

  static int _deadlineOrder(Task a, Task b) =>
      a.deadline!.compareTo(b.deadline!);
}
