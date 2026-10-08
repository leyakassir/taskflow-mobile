import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';

class TaskCommentModel extends TaskComment {
  const TaskCommentModel({
    required super.id,
    required super.taskId,
    required super.body,
    required super.createdAt,
    required super.author,
  });

  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? const {};
    return TaskCommentModel(
      id: (json['id'] ?? '').toString(),
      taskId: (json['taskId'] ?? '').toString(),
      body: json['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      author: TaskCommentAuthor(
        id: (author['id'] ?? '').toString(),
        fullName: author['fullName'] as String? ?? '',
        role: author['role'] as String? ?? 'WORKER',
        avatarUrl: author['avatarUrl'] as String?,
      ),
    );
  }
}

class TaskCommentPageModel extends TaskCommentPage {
  const TaskCommentPageModel({
    required super.comments,
    required super.page,
    required super.totalPages,
  });

  factory TaskCommentPageModel.fromJson(Map<String, dynamic> json) =>
      TaskCommentPageModel(
        comments: (json['data'] as List<dynamic>? ?? [])
            .map((e) => TaskCommentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        page: (json['page'] as num?)?.toInt() ?? 1,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      );
}
