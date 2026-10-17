import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';

Task _task(int i) => Task(
  id: 't$i',
  title: 'Task $i',
  priority: TaskPriority.medium,
  status: TaskStatus.assigned,
  minPhotosRequired: 0,
  minFilesRequired: 0,
  requiresChecklist: false,
  assigneeId: 'w',
  createdById: 'a',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

/// Pages a fixed list the same way the backend does.
class FakePagedRepository implements TaskRepository {
  FakePagedRepository(this.total);
  final int total;
  final requests = <String>[];
  bool fail = false;

  @override
  Future<TaskPage> getTasks({int page = 1, int limit = 20}) async {
    requests.add('$page/$limit');
    if (fail) throw const ApiException.generic();
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, total);
    return TaskPage(
      tasks: [for (var i = start; i < end; i++) _task(i)],
      page: page,
      limit: limit,
      total: total,
      totalPages: (total / limit).ceil(),
    );
  }

  @override
  Future<List<Task>> getTasksInRange({
    required DateTime from,
    required DateTime to,
  }) async => [];
  @override
  Future<Task> getTaskById(String taskId) async => _task(0);
  @override
  Future<Task> updateTaskStatus(String taskId, TaskStatus status) async =>
      _task(0);
  @override
  Future<Task> completeTask(String taskId, TaskSubmissionModel s) async =>
      _task(0);
  @override
  Future<void> uploadAttachment({
    required String taskId,
    required String filePath,
    required String kind,
  }) async {}
}

(ProviderContainer, FakePagedRepository) _setUp(int total) {
  final repo = FakePagedRepository(total);
  final c = ProviderContainer(
    overrides: [taskRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return (c, repo);
}

void main() {
  test('loads 20 at a time until the last page', () async {
    final (c, repo) = _setUp(45);
    final controller = c.read(tasksControllerProvider.notifier);

    expect(await c.read(tasksControllerProvider.future), hasLength(20));
    expect(controller.hasMore, isTrue);

    await controller.loadNextPage();
    expect(c.read(tasksControllerProvider).value, hasLength(40));
    await controller.loadNextPage();
    expect(c.read(tasksControllerProvider).value, hasLength(45));
    expect(controller.hasMore, isFalse);

    // Nothing more to fetch: no extra request.
    await controller.loadNextPage();
    expect(repo.requests, ['1/20', '2/20', '3/20']);
    // Pages join in order without duplicates.
    final ids = c.read(tasksControllerProvider).value!.map((t) => t.id);
    expect(ids.toSet(), hasLength(45));
    expect(ids.first, 't0');
    expect(ids.last, 't44');
  });

  test('a failed page keeps the list and can be retried', () async {
    final (c, repo) = _setUp(30);
    final controller = c.read(tasksControllerProvider.notifier);
    await c.read(tasksControllerProvider.future);

    repo.fail = true;
    await controller.loadNextPage();
    expect(c.read(tasksControllerProvider).value, hasLength(20));
    expect(c.read(tasksLoadMoreFailedProvider), isTrue);

    repo.fail = false;
    await controller.loadNextPage();
    expect(c.read(tasksControllerProvider).value, hasLength(30));
    expect(c.read(tasksLoadMoreFailedProvider), isFalse);
  });

  test('pull to refresh starts again from page 1', () async {
    final (c, _) = _setUp(45);
    final controller = c.read(tasksControllerProvider.notifier);
    await c.read(tasksControllerProvider.future);
    await controller.loadNextPage();

    await controller.refresh();
    expect(c.read(tasksControllerProvider).value, hasLength(20));
    expect(controller.hasMore, isTrue);
  });

  test('a background sync keeps every page already loaded', () async {
    final (c, repo) = _setUp(45);
    final controller = c.read(tasksControllerProvider.notifier);
    await c.read(tasksControllerProvider.future);
    await controller.loadNextPage();
    repo.requests.clear();

    await controller.reloadQuietly();
    expect(c.read(tasksControllerProvider).value, hasLength(40));
    expect(repo.requests, ['1/20', '2/20']);
    expect(controller.hasMore, isTrue);
  });

  test('fewer than 20 tasks: one page, no "Load more"', () async {
    final (c, repo) = _setUp(12);
    final controller = c.read(tasksControllerProvider.notifier);
    expect(await c.read(tasksControllerProvider.future), hasLength(12));
    expect(controller.hasMore, isFalse);
    expect(repo.requests, ['1/20']);
  });
}
