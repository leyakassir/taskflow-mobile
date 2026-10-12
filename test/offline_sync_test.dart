import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/offline/connectivity_provider.dart';
import 'package:taskflow_mobile/core/offline/offline_files.dart';
import 'package:taskflow_mobile/core/offline/pending_operation.dart';
import 'package:taskflow_mobile/core/offline/sync_queue.dart';
import 'package:taskflow_mobile/core/storage/local_storage_service.dart';
import 'package:taskflow_mobile/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:taskflow_mobile/features/notifications/data/models/notification_model.dart';
import 'package:taskflow_mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/features/sync/providers/sync_provider.dart';
import 'package:taskflow_mobile/features/tasks/data/datasources/task_comment_remote_data_source.dart';
import 'package:taskflow_mobile/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_comment_model.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/data/repositories/task_comment_repository_impl.dart';
import 'package:taskflow_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';
import 'package:taskflow_mobile/features/tasks/domain/repositories/task_repository.dart';

const _offline = ApiException(
  'No internet connection.',
  kind: ApiErrorKind.offline,
);

TaskModel _taskJson(String id, String status) => TaskModel.fromJson({
  'id': id,
  'title': 'Task $id',
  'priority': 'HIGH',
  'status': status,
  'deadline': DateTime.now()
      .add(const Duration(days: 1))
      .toUtc()
      .toIso8601String(),
  'requiresChecklist': true,
  'checklistItems': [
    {'id': 'c1', 'taskId': id, 'label': 'Check', 'done': false},
  ],
  'assigneeId': 'w',
  'createdById': 'a',
  'createdAt': DateTime.now().toUtc().toIso8601String(),
  'updatedAt': DateTime.now().toUtc().toIso8601String(),
});

/// Server stand-in: holds tasks, records calls, can be switched offline or
/// made to refuse a call type.
class FakeServer {
  bool offline = false;
  final calls = <String>[];
  final refuse = <String>{};
  final tasks = <String, TaskModel>{
    't1': _taskJson('t1', 'ASSIGNED'),
    't2': _taskJson('t2', 'ASSIGNED'),
  };

  void hit(String call) {
    if (offline) throw _offline;
    if (refuse.contains(call)) {
      throw const ApiException('Task was cancelled', statusCode: 400);
    }
    calls.add(call);
  }
}

class FakeTaskRemote extends TaskRemoteDataSource {
  FakeTaskRemote(this.server) : super(Dio());
  final FakeServer server;

  @override
  Future<TaskPageModel> getTasks({
    int page = 1,
    int limit = 20,
    DateTime? from,
    DateTime? to,
  }) async {
    server.hit('list');
    final list = server.tasks.values.toList();
    return TaskPageModel(
      tasks: list,
      page: 1,
      limit: limit,
      total: list.length,
      totalPages: 1,
    );
  }

  @override
  Future<TaskModel> getTaskById(String taskId) async {
    server.hit('get');
    return server.tasks[taskId]!;
  }

  @override
  Future<TaskModel> updateTaskStatus(String taskId, String status) async {
    server.hit('status:$taskId:$status');
    final json = taskToJson(server.tasks[taskId]!)..['status'] = status;
    return server.tasks[taskId] = TaskModel.fromJson(json);
  }

  @override
  Future<TaskModel> completeTask(
    String taskId,
    TaskSubmissionModel submission,
  ) async {
    server.hit('complete:$taskId');
    final json = taskToJson(server.tasks[taskId]!)..['status'] = 'COMPLETED';
    return server.tasks[taskId] = TaskModel.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> uploadAttachment({
    required String taskId,
    required String filePath,
    required String kind,
  }) async {
    server.hit('upload:$taskId:$kind');
    return {};
  }
}

class FakeCommentRemote extends TaskCommentRemoteDataSource {
  FakeCommentRemote(this.server) : super(Dio());
  final FakeServer server;
  final comments = <TaskCommentModel>[];

  @override
  Future<TaskCommentPageModel> getComments(
    String taskId, {
    int page = 1,
    int limit = 20,
  }) async {
    server.hit('comments');
    return TaskCommentPageModel(comments: comments, page: 1, totalPages: 1);
  }

  @override
  Future<TaskCommentModel> addComment(String taskId, String body) async {
    server.hit('comment:$taskId');
    final c = TaskCommentModel(
      id: 'srv${comments.length}',
      taskId: taskId,
      body: body,
      createdAt: DateTime.now(),
      author: const TaskCommentAuthor(
        id: 'w',
        fullName: 'Worker',
        role: 'WORKER',
      ),
    );
    comments.add(c);
    return c;
  }
}

class FakeNotificationRemote extends NotificationRemoteDataSource {
  FakeNotificationRemote(this.server) : super(Dio());
  final FakeServer server;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    server.hit('notifications');
    return [
      NotificationModel(
        id: 'n1',
        kind: NotificationKind.taskAssigned,
        title: 'New task',
        body: 'b',
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<void> markRead(String notificationId) async =>
      server.hit('read:$notificationId');

  @override
  Future<void> markAllRead() async => server.hit('readAll');
}

/// Keeps "kept" files in memory instead of the documents folder.
class FakeFiles extends OfflineFiles {
  @override
  Future<String> keep(String sourcePath) async => 'kept/$sourcePath';
  @override
  Future<void> discard(String path) async {}
  @override
  Future<void> clear() async {}
}

Future<(ProviderContainer, FakeServer)> _setUp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final server = FakeServer();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      taskRemoteDataSourceProvider.overrideWithValue(FakeTaskRemote(server)),
      taskCommentRemoteDataSourceProvider.overrideWithValue(
        FakeCommentRemote(server),
      ),
      notificationRemoteDataSourceProvider.overrideWithValue(
        FakeNotificationRemote(server),
      ),
      offlineFilesProvider.overrideWithValue(FakeFiles()),
    ],
  );
  addTearDown(container.dispose);
  return (container, server);
}

/// Simulates losing / regaining the connection (normally reported by the
/// Dio interceptor).
void _goOffline(ProviderContainer c, FakeServer s) {
  s.offline = true;
  c.read(connectivityProvider.notifier).reportOffline();
}

void _goOnline(ProviderContainer c, FakeServer s) {
  s.offline = false;
  c.read(connectivityProvider.notifier).reportOnline();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tasks seen online are available offline', () async {
    final (c, s) = await _setUp();
    final repo = c.read(taskRepositoryProvider);
    await repo.getTasks();
    _goOffline(c, s);

    final page = await repo.getTasks();
    expect(page.tasks.map((t) => t.id), containsAll(['t1', 't2']));
    expect((await repo.getTaskById('t1')).title, 'Task t1');
    final inRange = await repo.getTasksInRange(
      from: DateTime.now(),
      to: DateTime.now().add(const Duration(days: 2)),
    );
    expect(inRange, hasLength(2));
  });

  test('nothing cached yet: offline errors are passed on', () async {
    final (c, s) = await _setUp();
    _goOffline(c, s);
    expect(
      () => c.read(taskRepositoryProvider).getTasks(),
      throwsA(isA<ApiException>()),
    );
  });

  test('working offline queues changes in order and shows them', () async {
    final (c, s) = await _setUp();
    final repo = c.read(taskRepositoryProvider);
    await repo.getTasks();
    _goOffline(c, s);

    final started = await repo.updateTaskStatus('t1', TaskStatus.inProgress);
    expect(started.status, TaskStatus.inProgress);
    expect(
      await repo.uploadAttachment(
        taskId: 't1',
        filePath: 'p.jpg',
        kind: 'PHOTO',
      ),
      AttachmentUploadResult.queued,
    );
    final done = await repo.completeTask(
      't1',
      const TaskSubmissionModel(
        notes: 'ok',
        checklistResults: [ChecklistResultInput(id: 'c1', done: true)],
      ),
    );
    expect(done.status, TaskStatus.completed);
    expect(done.checklistItems.single.done, isTrue);
    expect(done.completionNotes, 'ok');

    // The offline list shows the worker's own changes too.
    final listed = (await repo.getTasks()).tasks.firstWhere(
      (t) => t.id == 't1',
    );
    expect(listed.status, TaskStatus.completed);
    expect(c.read(pendingTaskIdsProvider), {'t1'});
    expect(c.read(syncQueueProvider).map((op) => op.type), [
      PendingOperationType.updateTaskStatus,
      PendingOperationType.uploadAttachment,
      PendingOperationType.completeTask,
    ]);
  });

  test('back online: queued changes are sent in order', () async {
    final (c, s) = await _setUp();
    final repo = c.read(taskRepositoryProvider);
    await repo.getTasks();
    _goOffline(c, s);
    await repo.updateTaskStatus('t1', TaskStatus.inProgress);
    await repo.uploadAttachment(taskId: 't1', filePath: 'p.jpg', kind: 'PHOTO');
    await repo.completeTask('t1', const TaskSubmissionModel(notes: 'ok'));

    _goOnline(c, s);
    await c.read(syncControllerProvider.notifier).sync();

    expect(s.calls.where((call) => !['list', 'notifications'].contains(call)), [
      'status:t1:IN_PROGRESS',
      'upload:t1:PHOTO',
      'complete:t1',
    ]);
    expect(c.read(syncQueueProvider), isEmpty);
    expect(c.read(syncControllerProvider).failures, isEmpty);
    expect(s.tasks['t1']!.status, TaskStatus.completed);
  });

  test(
    'a refused change is dropped and reported; later ones still go',
    () async {
      final (c, s) = await _setUp();
      final repo = c.read(taskRepositoryProvider);
      await repo.getTasks();
      _goOffline(c, s);
      await repo.updateTaskStatus('t1', TaskStatus.inProgress);
      await repo.updateTaskStatus('t2', TaskStatus.inProgress);

      s.refuse.add('status:t1:IN_PROGRESS');
      _goOnline(c, s);
      await c.read(syncControllerProvider.notifier).sync();

      final failures = c.read(syncControllerProvider).failures;
      expect(failures, hasLength(1));
      expect(failures.single.operation.taskId, 't1');
      expect(failures.single.message, 'Task was cancelled');
      expect(s.calls, contains('status:t2:IN_PROGRESS'));
      expect(c.read(syncQueueProvider), isEmpty);
    },
  );

  test('still offline during sync: nothing is lost', () async {
    final (c, s) = await _setUp();
    final repo = c.read(taskRepositoryProvider);
    await repo.getTasks();
    _goOffline(c, s);
    await repo.updateTaskStatus('t1', TaskStatus.inProgress);

    // Connectivity says online, but the request still fails offline.
    c.read(connectivityProvider.notifier).reportOnline();
    await c.read(syncControllerProvider.notifier).sync();

    expect(c.read(syncQueueProvider), hasLength(1));
    expect(c.read(syncControllerProvider).failures, isEmpty);
  });

  test('a task with unsent changes keeps queueing even when online', () async {
    final (c, s) = await _setUp();
    final repo = c.read(taskRepositoryProvider);
    await repo.getTasks();
    _goOffline(c, s);
    await repo.updateTaskStatus('t1', TaskStatus.inProgress);

    // Server reachable again, but the start is still waiting: completing
    // must not overtake it.
    s.offline = false;
    await repo.completeTask('t1', const TaskSubmissionModel());
    expect(s.calls.where((call) => call.startsWith('complete')), isEmpty);
    expect(c.read(syncQueueProvider), hasLength(2));
  });

  test('comments: written offline, shown as pending, then sent', () async {
    final (c, s) = await _setUp();
    final repo = c.read(taskCommentRepositoryProvider);
    await repo.getComments('t1');
    _goOffline(c, s);

    final pending = await repo.addComment('t1', '  On my way  ');
    expect(pending.isPending, isTrue);
    expect(pending.body, 'On my way');
    final page = await repo.getComments('t1');
    expect(page.comments.single.isPending, isTrue);

    _goOnline(c, s);
    await c.read(syncControllerProvider.notifier).sync();
    expect(s.calls, contains('comment:t1'));
    final after = await repo.getComments('t1');
    expect(after.comments.single.isPending, isFalse);
  });

  test('notifications: marked read offline stay read and sync', () async {
    final (c, s) = await _setUp();
    final repo = c.read(notificationRepositoryProvider);
    await repo.getNotifications();
    _goOffline(c, s);

    await repo.markRead('n1');
    expect((await repo.getNotifications()).single.isRead, isTrue);

    _goOnline(c, s);
    await c.read(syncControllerProvider.notifier).sync();
    expect(s.calls, contains('read:n1'));
  });

  test('the queue survives an app restart', () async {
    final (c, s) = await _setUp();
    final repo = c.read(taskRepositoryProvider);
    await repo.getTasks();
    _goOffline(c, s);
    await repo.updateTaskStatus('t1', TaskStatus.inProgress);

    // New container on the same SharedPreferences = app restarted.
    final restarted = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(restarted.dispose);
    expect(restarted.read(syncQueueProvider), hasLength(1));
  });
}
