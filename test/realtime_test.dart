import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';
import 'package:taskflow_mobile/features/realtime/data/datasources/realtime_remote_data_source.dart';
import 'package:taskflow_mobile/features/realtime/domain/entities/realtime_event.dart';
import 'package:taskflow_mobile/features/realtime/providers/realtime_provider.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/domain/repositories/task_repository.dart';

class FakeStreamSource extends RealtimeRemoteDataSource {
  FakeStreamSource() : super(Dio());
  StreamController<RealtimeEvent>? current;
  int connects = 0;
  ApiException? failWith;

  @override
  Future<Stream<RealtimeEvent>> connect(CancelToken cancelToken) async {
    connects++;
    if (failWith != null) throw failWith!;
    current = StreamController<RealtimeEvent>();
    return current!.stream;
  }

  void send(RealtimeEventType type, [String? taskId]) =>
      current!.add(RealtimeEvent(type, taskId: taskId));
}

class CountingTaskRepository implements TaskRepository {
  int listLoads = 0;

  @override
  Future<TaskPage> getTasks({int page = 1, int limit = 20}) async {
    listLoads++;
    return const TaskPage(
      tasks: [],
      page: 1,
      limit: 20,
      total: 0,
      totalPages: 1,
    );
  }

  @override
  Future<List<Task>> getTasksInRange({
    required DateTime from,
    required DateTime to,
  }) async => [];
  @override
  Future<Task> getTaskById(String taskId) => throw UnimplementedError();
  @override
  Future<Task> updateTaskStatus(String taskId, TaskStatus status) =>
      throw UnimplementedError();
  @override
  Future<Task> completeTask(String taskId, TaskSubmissionModel s) =>
      throw UnimplementedError();
  @override
  Future<void> uploadAttachment({
    required String taskId,
    required String filePath,
    required String kind,
  }) => throw UnimplementedError();
}

class CountingNotificationRepository implements NotificationRepository {
  int loads = 0;
  @override
  Future<List<AppNotification>> getNotifications() async {
    loads++;
    return [];
  }

  @override
  Future<void> markRead(String notificationId) async {}
  @override
  Future<void> markAllRead() async {}
}

const _settle = Duration(milliseconds: 600); // > the 400 ms debounce

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SSE parsing', () {
    test('reads data lines, ignores comments, pings pass through', () async {
      final events = await parseServerSentEvents(
        Stream.fromIterable([
          ': comment',
          'data: {"type":"task","taskId":"t1"}',
          '',
          'id: 7',
          'data: {"type":"ping"}',
          '',
          'data: not json',
          '',
          'data: {"type":"comment",',
          'data: "taskId":"t2"}',
          '',
        ]),
      ).toList();
      expect(events.map((e) => e.type), [
        RealtimeEventType.task,
        RealtimeEventType.ping,
        RealtimeEventType.comment,
      ]);
      expect(events.first.taskId, 't1');
      expect(events.last.taskId, 't2');
    });
  });

  group('Live updates', () {
    late FakeStreamSource source;
    late CountingTaskRepository tasks;
    late CountingNotificationRepository notifications;
    late ProviderContainer container;

    setUp(() async {
      source = FakeStreamSource();
      tasks = CountingTaskRepository();
      notifications = CountingNotificationRepository();
      container = ProviderContainer(
        overrides: [
          realtimeRemoteDataSourceProvider.overrideWithValue(source),
          taskRepositoryProvider.overrideWithValue(tasks),
          notificationRepositoryProvider.overrideWithValue(notifications),
        ],
      );
      addTearDown(container.dispose);
      // As in the app: the lists are already on screen, then live updates
      // start. Count only what live updates load.
      await container.read(tasksControllerProvider.future);
      await container.read(notificationsControllerProvider.future);
      tasks.listLoads = 0;
      notifications.loads = 0;
      // Keep the autoDispose provider alive, as the app shell does.
      container.listen(realtimeProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    test('connects as soon as the app shell is shown', () {
      expect(source.connects, 1);
      expect(container.read(realtimeProvider), isTrue);
    });

    test('an admin change reloads the task list (once per burst)', () async {
      source
        ..send(RealtimeEventType.task, 't1')
        ..send(RealtimeEventType.task, 't2')
        ..send(RealtimeEventType.task, 't1');
      await Future<void>.delayed(_settle);
      expect(tasks.listLoads, 1);
    });

    test('a new notification reloads the bell and list', () async {
      source.send(RealtimeEventType.notification);
      await Future<void>.delayed(_settle);
      expect(notifications.loads, 1);
      expect(tasks.listLoads, 0);
    });

    test('heartbeats change nothing', () async {
      source.send(RealtimeEventType.ping);
      await Future<void>.delayed(_settle);
      expect(tasks.listLoads + notifications.loads, 0);
    });

    test('a dropped connection reconnects and catches up', () async {
      await source.current!.close();
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      expect(source.connects, 2);
      await Future<void>.delayed(_settle);
      // Anything missed while disconnected is reloaded.
      expect(tasks.listLoads, 1);
      expect(notifications.loads, 1);
    });
  });

  test('signed out (401): does not keep retrying', () async {
    final source = FakeStreamSource()
      ..failWith = const ApiException('expired', statusCode: 401);
    final container = ProviderContainer(
      overrides: [realtimeRemoteDataSourceProvider.overrideWithValue(source)],
    );
    addTearDown(container.dispose);
    container.listen(realtimeProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    expect(source.connects, 1);
    expect(container.read(realtimeProvider), isFalse);
  });
}
