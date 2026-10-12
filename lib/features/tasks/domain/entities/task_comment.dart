class TaskCommentAuthor {
  const TaskCommentAuthor({
    required this.id,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  final String id;
  final String fullName;

  /// Backend role string: ADMIN, MANAGER or WORKER.
  final String role;
  final String? avatarUrl;

  bool get isStaff => role == 'ADMIN' || role == 'MANAGER';
}

class TaskComment {
  const TaskComment({
    required this.id,
    required this.taskId,
    required this.body,
    required this.createdAt,
    required this.author,
    this.isPending = false,
  });

  final String id;
  final String taskId;
  final String body;
  final DateTime createdAt;
  final TaskCommentAuthor author;

  /// Written offline and not on the server yet.
  final bool isPending;
}

class TaskCommentPage {
  const TaskCommentPage({
    required this.comments,
    required this.page,
    required this.totalPages,
  });

  final List<TaskComment> comments;
  final int page;
  final int totalPages;
}
