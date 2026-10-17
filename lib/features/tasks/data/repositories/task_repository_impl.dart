import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/domain/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskRemoteDataSourceProvider));
});

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._remote);

  final TaskRemoteDataSource _remote;

  @override
  Future<TaskPage> getTasks({int page = 1, int limit = 20}) =>
      _remote.getTasks(page: page, limit: limit);

  @override
  Future<List<Task>> getTasksInRange({
    required DateTime from,
    required DateTime to,
  }) async {
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
    return tasks;
  }

  @override
  Future<Task> getTaskById(String taskId) => _remote.getTaskById(taskId);

  @override
  Future<Task> updateTaskStatus(String taskId, TaskStatus status) =>
      _remote.updateTaskStatus(taskId, taskStatusToJson(status));

  @override
  Future<Task> completeTask(String taskId, TaskSubmissionModel submission) =>
      _remote.completeTask(taskId, submission);

  @override
  Future<void> uploadAttachment({
    required String taskId,
    required String filePath,
    required String kind,
  }) =>
      _remote.uploadAttachment(taskId: taskId, filePath: filePath, kind: kind);
}
