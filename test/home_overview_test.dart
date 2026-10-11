import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow_mobile/features/home/providers/home_provider.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';

/// [deadlineIn] is relative to now (negative = in the past). For completed
/// tasks, [completedAgo] says when it was submitted.
Task _task(
  String id, {
  required TaskStatus status,
  Duration? deadlineIn,
  Duration? completedAgo,
}) {
  final now = DateTime.now();
  return Task(
    id: id,
    title: id,
    priority: TaskPriority.medium,
    status: status,
    deadline: deadlineIn == null ? null : now.add(deadlineIn),
    completionTimestamp: completedAgo == null
        ? null
        : now.subtract(completedAgo),
    minPhotosRequired: 0,
    minFilesRequired: 0,
    requiresChecklist: false,
    assigneeId: 'w',
    createdById: 'a',
    createdAt: now.subtract(const Duration(days: 60)),
    updatedAt: now,
  );
}

const _day = Duration(days: 1);

void main() {
  group('On-time rate: deadlines met in the last 30 days', () {
    test('overdue open tasks count as missed', () {
      final overview = HomeOverview.fromTasks([
        // Finished a day before its deadline: met.
        _task(
          'met',
          status: TaskStatus.completed,
          deadlineIn: -_day * 4,
          completedAgo: _day * 5,
        ),
        // Deadline passed 2 days ago, still not done: missed.
        _task('overdue', status: TaskStatus.overdue, deadlineIn: -_day * 2),
        // Still "in progress" past its deadline: missed.
        _task('late-wip', status: TaskStatus.inProgress, deadlineIn: -_day),
        // Finished a day after its deadline: missed.
        _task(
          'late',
          status: TaskStatus.completed,
          deadlineIn: -_day * 10,
          completedAgo: _day * 9,
        ),
      ]);
      expect(overview.onTimeRate, 0.25);
    });

    test('leaves out tasks whose outcome is not known or does not apply', () {
      final overview = HomeOverview.fromTasks([
        _task(
          'met',
          status: TaskStatus.completed,
          deadlineIn: -_day,
          completedAgo: _day * 2,
        ),
        // Due in the future and not done yet: not judged.
        _task('upcoming', status: TaskStatus.assigned, deadlineIn: _day * 3),
        // No deadline: can't be judged.
        _task('no-deadline', status: TaskStatus.inProgress),
        // Cancelled: not the worker's miss.
        _task('cancelled', status: TaskStatus.cancelled, deadlineIn: -_day),
        // Missed, but the deadline was 40 days ago: outside the window.
        _task('old', status: TaskStatus.overdue, deadlineIn: -_day * 40),
      ]);
      expect(overview.onTimeRate, 1.0);
    });

    test('finished early counts as met even before the deadline arrives', () {
      final overview = HomeOverview.fromTasks([
        _task(
          'early',
          status: TaskStatus.completed,
          deadlineIn: _day * 5,
          completedAgo: _day,
        ),
      ]);
      expect(overview.onTimeRate, 1.0);
    });

    test('submitting exactly at the deadline counts as met', () {
      final now = DateTime.now();
      final at = now.subtract(_day);
      final task = Task(
        id: 'exact',
        title: 'exact',
        priority: TaskPriority.low,
        status: TaskStatus.completed,
        deadline: at,
        completionTimestamp: at,
        minPhotosRequired: 0,
        minFilesRequired: 0,
        requiresChecklist: false,
        assigneeId: 'w',
        createdById: 'a',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      );
      expect(HomeOverview.fromTasks([task]).onTimeRate, 1.0);
    });

    test('is null when nothing qualifies (shown as a dash)', () {
      final overview = HomeOverview.fromTasks([
        _task('upcoming', status: TaskStatus.assigned, deadlineIn: _day),
      ]);
      expect(overview.onTimeRate, isNull);
    });
  });
}
