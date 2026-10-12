import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/offline/offline_files.dart';
import 'package:taskflow_mobile/core/offline/pending_operation.dart';
import 'package:taskflow_mobile/core/offline/sync_queue.dart';
import 'package:taskflow_mobile/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:taskflow_mobile/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/domain/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    ref.watch(taskRemoteDataSourceProvider),
    ref.watch(taskLocalDataSourceProvider),
    ref.read(syncQueueProvider.notifier),
    ref.watch(offlineFilesProvider),
  );
});

/// Online: talks to the server and keeps the local copy up to date.
/// Offline: answers from the local copy, and queues changes so the worker
/// can keep working; the sync controller sends them later. Unsent changes
/// are applied on top of whatever is returned, so the app always shows the
/// worker's own latest actions.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._remote, this._local, this._queue, this._files);

  final TaskRemoteDataSource _remote;
  final TaskLocalDataSource _local;
  final SyncQueue _queue;
  final OfflineFiles _files;

  @override
  Future<TaskPage> getTasks({int page = 1, int limit = 20}) async {
    try {
      final result = await _remote.getTasks(page: page, limit: limit);
      await _local.upsert(result.tasks);
      return TaskPage(
        tasks: result.tasks.map(_withPending).toList(),
        page: result.page,
        limit: result.limit,
        total: result.total,
        totalPages: result.totalPages,
      );
    } on ApiException catch (error) {
      final cached = _local.readTasks();
      // Offline: everything saved is returned as one page.
      if (!error.isOffline || cached == null || page > 1) rethrow;
      return TaskPage(
        tasks: cached.map(_withPending).toList(),
        page: 1,
        limit: cached.length,
        total: cached.length,
        totalPages: 1,
      );
    }
  }

  @override
  Future<void> refreshAllTasks() async {
    const pageSize = 100; // backend maximum
    final tasks = <Task>[];
    var page = 1;
    var totalPages = 1;
    do {
      final result = await _remote.getTasks(page: page, limit: pageSize);
      tasks.addAll(result.tasks);
      totalPages = result.totalPages;
      page++;
    } while (page <= totalPages);
    // A full download also drops tasks no longer visible to the worker
    // (reassigned or deleted).
    await _local.saveAll(tasks);
  }

  @override
  Future<List<Task>> getTasksInRange({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      const pageSize = 100; // backend maximum
      final tasks = <Task>[];
      var page = 1;
      var totalPages = 1;
      do {
        final result = await _remote.getTasks(
          page: page,
          limit: pageSize,
          from: from,
          to: to,
        );
        tasks.addAll(result.tasks);
        totalPages = result.totalPages;
        page++;
      } while (page <= totalPages);
      await _local.upsert(tasks);
      return tasks.map(_withPending).toList();
    } on ApiException catch (error) {
      final cached = _local.readTasks();
      if (!error.isOffline || cached == null) rethrow;
      // Same rule as the backend: deadline or start date inside the range.
      bool inRange(DateTime? d) =>
          d != null && !d.isBefore(from) && !d.isAfter(to);
      return cached
          .where((t) => inRange(t.deadline) || inRange(t.startDate))
          .map(_withPending)
          .toList();
    }
  }

  @override
  Future<Task> getTaskById(String taskId) async {
    try {
      final task = await _remote.getTaskById(taskId);
      await _local.upsert([task]);
      return _withPending(task);
    } on ApiException catch (error) {
      final cached = _local.readTask(taskId);
      if (!error.isOffline || cached == null) rethrow;
      return _withPending(cached);
    }
  }

  @override
  Future<Task> updateTaskStatus(String taskId, TaskStatus status) {
    return _sendOrQueue(
      taskId,
      send: () async {
        final task = await _remote.updateTaskStatus(
          taskId,
          taskStatusToJson(status),
        );
        await _local.upsert([task]);
        return task;
      },
      queue: () => _queue.enqueue(
        PendingOperationType.updateTaskStatus,
        taskId: taskId,
        payload: {'status': taskStatusToJson(status)},
      ),
    );
  }

  @override
  Future<Task> completeTask(String taskId, TaskSubmissionModel submission) {
    return _sendOrQueue(
      taskId,
      send: () async {
        final task = await _remote.completeTask(taskId, submission);
        await _local.upsert([task]);
        return task;
      },
      queue: () => _queue.enqueue(
        PendingOperationType.completeTask,
        taskId: taskId,
        payload: submission.toJson(),
      ),
    );
  }

  @override
  Future<AttachmentUploadResult> uploadAttachment({
    required String taskId,
    required String filePath,
    required String kind,
  }) async {
    Future<AttachmentUploadResult> queueIt() async {
      final kept = await _files.keep(filePath);
      await _queue.enqueue(
        PendingOperationType.uploadAttachment,
        taskId: taskId,
        payload: {'filePath': kept, 'kind': kind},
      );
      return AttachmentUploadResult.queued;
    }

    if (_queue.hasPendingFor(taskId)) return queueIt();
    try {
      await _remote.uploadAttachment(
        taskId: taskId,
        filePath: filePath,
        kind: kind,
      );
      return AttachmentUploadResult.uploaded;
    } on ApiException catch (error) {
      if (!error.isOffline) rethrow;
      return queueIt();
    }
  }

  /// Sends now when possible. Queues instead when offline, or when this
  /// task already has unsent changes (so they reach the server in order).
  Future<Task> _sendOrQueue(
    String taskId, {
    required Future<Task> Function() send,
    required Future<PendingOperation> Function() queue,
  }) async {
    if (!_queue.hasPendingFor(taskId)) {
      try {
        return _withPending(await send());
      } on ApiException catch (error) {
        if (!error.isOffline) rethrow;
      }
    }
    final cached = _local.readTask(taskId);
    if (cached == null) {
      throw const ApiException(
        'No internet connection.',
        kind: ApiErrorKind.offline,
      );
    }
    await queue();
    return _withPending(cached);
  }

  /// Applies this task's unsent changes, oldest first.
  Task _withPending(Task task) {
    var result = task;
    for (final op in _queue.operations.where((op) => op.taskId == task.id)) {
      switch (op.type) {
        case PendingOperationType.updateTaskStatus:
          result = result.copyWith(
            status: taskStatusFromJson(op.payload['status'] as String?),
          );
        case PendingOperationType.completeTask:
          final results = {
            for (final r in (op.payload['checklistResults'] as List? ?? []))
              if (r is Map) r['id']: r['done'] == true,
          };
          result = result.copyWith(
            status: TaskStatus.completed,
            completionTimestamp: op.createdAt,
            completionNotes: op.payload['notes'] as String?,
            checklistItems: [
              for (final item in result.checklistItems)
                item.copyWith(done: results[item.id] ?? item.done),
            ],
          );
        case PendingOperationType.uploadAttachment ||
            PendingOperationType.addComment ||
            PendingOperationType.markNotificationRead ||
            PendingOperationType.markAllNotificationsRead:
          break;
      }
    }
    return result;
  }
}
