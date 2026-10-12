import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/offline/connectivity_provider.dart';
import 'package:taskflow_mobile/core/offline/offline_files.dart';
import 'package:taskflow_mobile/core/offline/pending_operation.dart';
import 'package:taskflow_mobile/core/offline/sync_queue.dart';
import 'package:taskflow_mobile/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';
import 'package:taskflow_mobile/features/tasks/data/datasources/task_comment_remote_data_source.dart';
import 'package:taskflow_mobile/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_comments_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_details_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';

/// A queued change the server refused (e.g. the task was cancelled or
/// reassigned while the worker was offline). It is dropped from the queue
/// and listed for the worker so nothing disappears silently.
class SyncFailure {
  const SyncFailure({
    required this.operation,
    required this.message,
    this.taskTitle,
  });

  final PendingOperation operation;
  final String message;
  final String? taskTitle;
}

class SyncState {
  const SyncState({this.isSyncing = false, this.failures = const []});

  final bool isSyncing;
  final List<SyncFailure> failures;

  SyncState copyWith({bool? isSyncing, List<SyncFailure>? failures}) =>
      SyncState(
        isSyncing: isSyncing ?? this.isSyncing,
        failures: failures ?? this.failures,
      );
}

/// Sends queued offline changes to the server, oldest first, as soon as it
/// is reachable; then refreshes the offline copy of the worker's tasks.
///
/// Kept alive while the signed-in shell is shown (the status bar watches
/// it). Runs on start, when the connection comes back, and when a change is
/// queued while online (e.g. behind another unsent change).
final syncControllerProvider = NotifierProvider<SyncController, SyncState>(
  SyncController.new,
);

class SyncController extends Notifier<SyncState> {
  @override
  SyncState build() {
    ref.listen<bool>(connectivityProvider, (was, isOnline) {
      if (isOnline && was == false) sync(refreshCache: true);
    });
    ref.listen<List<PendingOperation>>(syncQueueProvider, (before, after) {
      if (after.length > (before?.length ?? 0)) sync();
    });
    Future.microtask(() => sync(refreshCache: true));
    return const SyncState();
  }

  void dismissFailures() => state = state.copyWith(failures: const []);

  Future<void> sync({bool refreshCache = false}) async {
    if (state.isSyncing || !ref.read(connectivityProvider)) return;
    final queue = ref.read(syncQueueProvider.notifier);
    if (queue.isEmpty && !refreshCache) return;

    state = state.copyWith(isSyncing: true);
    var sentAny = false;
    try {
      while (!queue.isEmpty) {
        final op = queue.operations.first;
        try {
          await _send(op);
          await queue.remove(op.id);
          sentAny = true;
        } on ApiException catch (error) {
          if (_shouldRetryLater(error)) return;
          await queue.remove(op.id);
          _recordFailure(op, error.message);
        } catch (error) {
          // e.g. a queued photo file that no longer exists.
          debugPrint('Dropping queued change ${op.type.name}: $error');
          await queue.remove(op.id);
          _recordFailure(op, error.toString());
        }
      }
      if (sentAny || refreshCache) await _refreshFromServer();
    } finally {
      state = state.copyWith(isSyncing: false);
    }
  }

  /// Offline, timeouts, server errors and an expired session are temporary:
  /// keep the change and try again later. Anything else is a refusal.
  bool _shouldRetryLater(ApiException error) =>
      error.isOffline ||
      error.kind == ApiErrorKind.timeout ||
      error.isServerError ||
      error.isUnauthorized;

  Future<void> _send(PendingOperation op) async {
    final taskId = op.taskId ?? '';
    final p = op.payload;
    switch (op.type) {
      case PendingOperationType.updateTaskStatus:
        await ref
            .read(taskRemoteDataSourceProvider)
            .updateTaskStatus(taskId, p['status'] as String);
      case PendingOperationType.uploadAttachment:
        final path = p['filePath'] as String;
        await ref
            .read(taskRemoteDataSourceProvider)
            .uploadAttachment(
              taskId: taskId,
              filePath: path,
              kind: p['kind'] as String,
            );
        await ref.read(offlineFilesProvider).discard(path);
      case PendingOperationType.completeTask:
        await ref
            .read(taskRemoteDataSourceProvider)
            .completeTask(taskId, TaskSubmissionModel.fromJson(p));
      case PendingOperationType.addComment:
        await ref
            .read(taskCommentRemoteDataSourceProvider)
            .addComment(taskId, p['body'] as String);
      case PendingOperationType.markNotificationRead:
        await ref
            .read(notificationRemoteDataSourceProvider)
            .markRead(p['notificationId'] as String);
      case PendingOperationType.markAllNotificationsRead:
        await ref.read(notificationRemoteDataSourceProvider).markAllRead();
    }
  }

  void _recordFailure(PendingOperation op, String message) {
    final title = ref
        .read(tasksControllerProvider)
        .valueOrNull
        ?.where((t) => t.id == op.taskId)
        .firstOrNull
        ?.title;
    state = state.copyWith(
      failures: [
        ...state.failures,
        SyncFailure(operation: op, message: message, taskTitle: title),
      ],
    );
  }

  /// Re-downloads everything so the offline copy and the screens match the
  /// server. Failures are ignored: the next sync tries again.
  Future<void> _refreshFromServer() async {
    try {
      await ref.read(taskRepositoryProvider).refreshAllTasks();
    } catch (error) {
      debugPrint('Could not refresh offline tasks: $error');
      return;
    }
    await ref.read(tasksControllerProvider.notifier).reloadQuietly();
    ref
      ..invalidate(taskDetailsControllerProvider)
      ..invalidate(taskCommentsControllerProvider);
    await ref.read(notificationsControllerProvider.notifier).refresh();
  }
}
