import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/offline/offline_store.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_comment_model.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>(
  (ref) => TaskLocalDataSource(ref.watch(offlineStoreProvider)),
);

/// The last tasks and comments received from the server, kept on the
/// device for offline use. Holds server data only; unsent offline changes
/// live in the sync queue and are applied on top by the repository.
class TaskLocalDataSource {
  TaskLocalDataSource(this._store);

  final OfflineStore _store;

  /// Null when nothing has been cached yet (never been online).
  List<Task>? readTasks() =>
      _store.readList(OfflineStore.tasksKey)?.map(TaskModel.fromJson).toList();

  Task? readTask(String taskId) =>
      readTasks()?.where((t) => t.id == taskId).firstOrNull;

  /// Replaces the whole cache (after a full download of the task list).
  Future<void> saveAll(List<Task> tasks) => _store.write(
    OfflineStore.tasksKey,
    [for (final t in tasks) taskToJson(t)],
  );

  /// Adds or updates tasks, keeping every other cached task.
  Future<void> upsert(Iterable<Task> tasks) async {
    final byId = {for (final t in readTasks() ?? const <Task>[]) t.id: t};
    for (final task in tasks) {
      byId[task.id] = task;
    }
    final all = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await saveAll(all);
  }

  List<TaskComment>? readComments(String taskId) => _store
      .readList(OfflineStore.commentsKey(taskId))
      ?.map(TaskCommentModel.fromJson)
      .toList();

  Future<void> saveComments(String taskId, List<TaskComment> comments) =>
      _store.write(OfflineStore.commentsKey(taskId), [
        for (final c in comments) commentToJson(c),
      ]);
}
