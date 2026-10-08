import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/domain/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskRemoteDataSourceProvider));
});

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._remoteDataSource);

  final TaskRemoteDataSource _remoteDataSource;

  @override
  Future<TaskPage> getTasks({int page = 1, int limit = 20}) {
    return _remoteDataSource.getTasks(page: page, limit: limit);
  }

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
      final result = await _remoteDataSource.getTasks(
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
  Future<Task> getTaskById(String taskId) {
    return _remoteDataSource.getTaskById(taskId);
  }

  @override
  Future<Task> updateTaskStatus(String taskId, TaskStatus status) {
    return _remoteDataSource.updateTaskStatus(taskId, _statusToJson(status));
  }

  @override
  Future<Task> completeTask(String taskId, TaskSubmissionModel submission) {
    return _remoteDataSource.completeTask(taskId, submission);
  }

  @override
  Future<Map<String, dynamic>> uploadAttachment({
    required String taskId,
    required String filePath,
    required String kind,
  }) {
    return _remoteDataSource.uploadAttachment(
      taskId: taskId,
      filePath: filePath,
      kind: kind,
    );
  }
}

// Domain -> backend enum string mapping. The reverse mapping
// (backend string -> domain enum) lives in task_model.dart, next to
// the rest of the JSON parsing logic.
String _statusToJson(TaskStatus status) {
  switch (status) {
    case TaskStatus.assigned:
      return 'ASSIGNED';
    case TaskStatus.inProgress:
      return 'IN_PROGRESS';
    case TaskStatus.completed:
      return 'COMPLETED';
    case TaskStatus.overdue:
      return 'OVERDUE';
    case TaskStatus.cancelled:
      return 'CANCELLED';
  }
}
