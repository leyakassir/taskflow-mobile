import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/tasks/data/datasources/task_comment_remote_data_source.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';
import 'package:taskflow_mobile/features/tasks/domain/repositories/task_comment_repository.dart';

final taskCommentRepositoryProvider = Provider<TaskCommentRepository>((ref) {
  return TaskCommentRepositoryImpl(
    ref.watch(taskCommentRemoteDataSourceProvider),
  );
});

class TaskCommentRepositoryImpl implements TaskCommentRepository {
  TaskCommentRepositoryImpl(this._remoteDataSource);

  final TaskCommentRemoteDataSource _remoteDataSource;

  @override
  Future<TaskCommentPage> getComments(
    String taskId, {
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getComments(taskId, page: page, limit: limit);
  }

  @override
  Future<TaskComment> addComment(String taskId, String body) {
    return _remoteDataSource.addComment(taskId, body.trim());
  }
}
