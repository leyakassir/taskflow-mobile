import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/offline/offline_store.dart';
import 'package:taskflow_mobile/core/offline/pending_operation.dart';
import 'package:taskflow_mobile/core/offline/sync_queue.dart';
import 'package:taskflow_mobile/features/tasks/data/datasources/task_comment_remote_data_source.dart';
import 'package:taskflow_mobile/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';
import 'package:taskflow_mobile/features/tasks/domain/repositories/task_comment_repository.dart';

final taskCommentRepositoryProvider = Provider<TaskCommentRepository>((ref) {
  return TaskCommentRepositoryImpl(
    ref.watch(taskCommentRemoteDataSourceProvider),
    ref.watch(taskLocalDataSourceProvider),
    ref.read(syncQueueProvider.notifier),
    ref.watch(offlineStoreProvider),
  );
});

/// Comments the worker has seen are kept per task for offline reading.
/// Comments written offline are queued and shown as "pending" at the end
/// of the thread until they are sent.
class TaskCommentRepositoryImpl implements TaskCommentRepository {
  TaskCommentRepositoryImpl(
    this._remote,
    this._local,
    this._queue,
    this._store,
  );

  final TaskCommentRemoteDataSource _remote;
  final TaskLocalDataSource _local;
  final SyncQueue _queue;
  final OfflineStore _store;

  @override
  Future<TaskCommentPage> getComments(
    String taskId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remote.getComments(
        taskId,
        page: page,
        limit: limit,
      );
      if (page == 1) await _local.saveComments(taskId, result.comments);
      // Pending comments belong after the newest page.
      final isLastPage = result.page >= result.totalPages;
      return TaskCommentPage(
        comments: [...result.comments, if (isLastPage) ..._pendingFor(taskId)],
        page: result.page,
        totalPages: result.totalPages,
      );
    } on ApiException catch (error) {
      if (!error.isOffline || page > 1) rethrow;
      return TaskCommentPage(
        comments: [...?_local.readComments(taskId), ..._pendingFor(taskId)],
        page: 1,
        totalPages: 1,
      );
    }
  }

  @override
  Future<TaskComment> addComment(String taskId, String body) async {
    final text = body.trim();
    if (!_queue.hasPendingFor(taskId)) {
      try {
        return await _remote.addComment(taskId, text);
      } on ApiException catch (error) {
        if (!error.isOffline) rethrow;
      }
    }
    final op = await _queue.enqueue(
      PendingOperationType.addComment,
      taskId: taskId,
      payload: {'body': text},
    );
    return _pendingComment(op);
  }

  Iterable<TaskComment> _pendingFor(String taskId) => _queue.operations
      .where(
        (op) =>
            op.type == PendingOperationType.addComment && op.taskId == taskId,
      )
      .map(_pendingComment);

  /// Shown as written by the signed-in user (from the cached profile).
  TaskComment _pendingComment(PendingOperation op) {
    final me = _store.readMap(OfflineStore.profileKey) ?? const {};
    return TaskComment(
      id: 'pending-${op.id}',
      taskId: op.taskId ?? '',
      body: op.payload['body'] as String? ?? '',
      createdAt: op.createdAt,
      isPending: true,
      author: TaskCommentAuthor(
        id: me['id']?.toString() ?? '',
        fullName: me['fullName'] as String? ?? '',
        role: me['role'] as String? ?? 'WORKER',
        avatarUrl: me['avatarUrl'] as String?,
      ),
    );
  }
}
