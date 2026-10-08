import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';

abstract class TaskCommentRepository {
  /// Comments on a task, oldest first. The backend enforces that workers
  /// only read comments on tasks assigned to them.
  Future<TaskCommentPage> getComments(
    String taskId, {
    int page = 1,
    int limit = 20,
  });

  /// Posts a comment. [body] must be 1–1000 characters after trimming.
  Future<TaskComment> addComment(String taskId, String body);
}
