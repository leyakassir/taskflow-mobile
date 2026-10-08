import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';

final taskDetailsControllerProvider =
    AsyncNotifierProvider.family<TaskDetailsController, Task, String>(
      TaskDetailsController.new,
    );

class TaskDetailsController extends FamilyAsyncNotifier<Task, String> {
  @override
  Future<Task> build(String taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    return repository.getTaskById(taskId);
  }

  /// Re-fetches this single task, e.g. after returning to the details
  /// screen or on pull-to-refresh.
  Future<void> refresh() async {
    final repository = ref.read(taskRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repository.getTaskById(arg));
  }

  /// Re-fetches while keeping the current task on screen (pull-to-refresh).
  /// On failure the current task stays visible.
  Future<void> reload() async {
    final repository = ref.read(taskRepositoryProvider);
    final next = await AsyncValue.guard(() => repository.getTaskById(arg));
    if (next.hasValue || !state.hasValue) state = next;
  }

  Future<void> updateStatus(TaskStatus status) async {
    final repository = ref.read(taskRepositoryProvider);
    final updated = await repository.updateTaskStatus(arg, status);
    state = AsyncData(updated);
    _syncIntoTaskList(updated);
  }

  Future<void> complete(TaskSubmissionModel submission) async {
    final repository = ref.read(taskRepositoryProvider);
    final updated = await repository.completeTask(arg, submission);
    state = AsyncData(updated);
    _syncIntoTaskList(updated);
  }

  Future<Map<String, dynamic>> uploadAttachment({
    required String filePath,
    required String kind,
  }) {
    final task = state.value;
    if (task == null) {
      throw StateError('Task details must load before uploading attachments.');
    }
    return ref
        .read(taskRepositoryProvider)
        .uploadAttachment(taskId: task.id, filePath: filePath, kind: kind);
  }

  /// Keeps the tasks list screen in sync after a status change or
  /// completion made from the details/completion screens, without forcing
  /// a full network re-fetch of the whole list.
  void _syncIntoTaskList(Task updated) {
    final tasksState = ref.read(tasksControllerProvider);
    final tasks = tasksState.value;
    if (tasks == null) return;
    ref.read(tasksControllerProvider.notifier).state = AsyncData([
      for (final task in tasks)
        if (task.id == updated.id) updated else task,
    ]);
  }
}
