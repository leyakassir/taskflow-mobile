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
  TaskCommentRepositoryImpl(this._remote);

  final TaskCommentRemoteDataSource _remote;

  @override
  Future<TaskCommentPage> getComments(
    String taskId, {
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _remote.getComments(taskId, page: page, limit: limit);
    return TaskCommentPage(
      comments: result.comments,
      page: result.page,
      totalPages: result.totalPages,
    );
  }

  @override
  Future<TaskComment> addComment(String taskId, String body) =>
      _remote.addComment(taskId, body.trim());
}
