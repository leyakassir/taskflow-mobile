import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';

class TaskAttachmentModel extends TaskAttachment {
  const TaskAttachmentModel({
    required super.id,
    required super.taskId,
    required super.kind,
    required super.url,
    required super.mimeType,
    required super.sizeBytes,
    required super.createdAt,
  });

  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentModel(
      id: (json['id'] ?? '').toString(),
      taskId: (json['taskId'] ?? '').toString(),
      kind: _kindFromJson(json['kind'] as String?),
      url: json['url'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

TaskAttachmentKind _kindFromJson(String? value) {
  switch (value) {
    case 'COMPLETION_PHOTO':
      return TaskAttachmentKind.completionPhoto;
    case 'COMPLETION_FILE':
      return TaskAttachmentKind.completionFile;
    case 'INSTRUCTION':
    default:
      return TaskAttachmentKind.instruction;
  }
}

Map<String, dynamic> attachmentToJson(TaskAttachment attachment) => {
  'id': attachment.id,
  'taskId': attachment.taskId,
  'kind': switch (attachment.kind) {
    TaskAttachmentKind.instruction => 'INSTRUCTION',
    TaskAttachmentKind.completionPhoto => 'COMPLETION_PHOTO',
    TaskAttachmentKind.completionFile => 'COMPLETION_FILE',
  },
  'url': attachment.url,
  'mimeType': attachment.mimeType,
  'sizeBytes': attachment.sizeBytes,
  'createdAt': attachment.createdAt.toUtc().toIso8601String(),
};
