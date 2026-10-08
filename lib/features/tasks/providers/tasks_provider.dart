import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';

final tasksControllerProvider =
    AsyncNotifierProvider<TasksController, List<Task>>(TasksController.new);
final tasksLoadingMoreProvider = StateProvider<bool>((ref) => false);
final tasksLoadMoreFailedProvider = StateProvider<bool>((ref) => false);

class TasksController extends AsyncNotifier<List<Task>> {
  static const _pageSize = 20;
  int _page = 1;
  int _totalPages = 1;

  @override
  Future<List<Task>> build() async {
    final repository = ref.read(taskRepositoryProvider);
    _page = 1;
    _totalPages = 1;
    final result = await repository.getTasks(page: _page, limit: _pageSize);
    _totalPages = result.totalPages;
    return result.tasks;
  }

  /// Re-fetches the task list, e.g. for pull-to-refresh.
  Future<void> refresh() async {
    final repository = ref.read(taskRepositoryProvider);
    state = const AsyncLoading();
    _page = 1;
    _totalPages = 1;
    ref.read(tasksLoadingMoreProvider.notifier).state = false;
    ref.read(tasksLoadMoreFailedProvider.notifier).state = false;
    state = await AsyncValue.guard(() async {
      final result = await repository.getTasks(page: 1, limit: _pageSize);
      _page = result.page;
      _totalPages = result.totalPages;
      return result.tasks;
    });
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null ||
        _page >= _totalPages ||
        ref.read(tasksLoadingMoreProvider)) {
      return;
    }
    ref.read(tasksLoadingMoreProvider.notifier).state = true;
    ref.read(tasksLoadMoreFailedProvider.notifier).state = false;
    try {
      final result = await ref
          .read(taskRepositoryProvider)
          .getTasks(page: _page + 1, limit: _pageSize);
      _page = result.page;
      _totalPages = result.totalPages;
      state = AsyncData([...current, ...result.tasks]);
    } catch (_) {
      ref.read(tasksLoadMoreFailedProvider.notifier).state = true;
    } finally {
      ref.read(tasksLoadingMoreProvider.notifier).state = false;
    }
  }

  bool get hasMore => _page < _totalPages;

  /// Transitions a single task's status and updates it in-place within
  /// the currently held list, avoiding a full re-fetch.
  Future<void> updateStatus(String taskId, TaskStatus status) async {
    final repository = ref.read(taskRepositoryProvider);
    final updated = await repository.updateTaskStatus(taskId, status);
    _replaceTask(updated);
  }

  void _replaceTask(Task updated) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final task in current)
        if (task.id == updated.id) updated else task,
    ]);
  }
}
