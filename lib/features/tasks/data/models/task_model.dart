import 'package:taskflow_mobile/features/tasks/data/models/task_attachment_model.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';

class TaskChecklistItemModel extends TaskChecklistItem {
  const TaskChecklistItemModel({
    required super.id,
    required super.taskId,
    required super.label,
    required super.done,
  });

  factory TaskChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return TaskChecklistItemModel(
      id: (json['id'] ?? '').toString(),
      taskId: (json['taskId'] ?? '').toString(),
      label: json['label'] as String? ?? '',
      done: json['done'] as bool? ?? false,
    );
  }
}

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    super.titleAr,
    super.descriptionAr,
    required super.priority,
    required super.status,
    super.deadline,
    super.startDate,
    super.location,
    required super.minPhotosRequired,
    required super.minFilesRequired,
    required super.requiresChecklist,
    required super.assigneeId,
    required super.createdById,
    super.checklistItems,
    super.attachments,
    super.completionNotes,
    super.completionTimestamp,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      titleAr: json['titleAr'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      priority: _priorityFromJson(json['priority'] as String?),
      status: taskStatusFromJson(json['status'] as String?),
      deadline: _dateFromJson(json['deadline'] as String?),
      startDate: _dateFromJson(json['startDate'] as String?),
      location: json['location'] as String?,
      minPhotosRequired: (json['minPhotosRequired'] as num?)?.toInt() ?? 0,
      minFilesRequired: (json['minFilesRequired'] as num?)?.toInt() ?? 0,
      requiresChecklist: json['requiresChecklist'] as bool? ?? false,
      assigneeId: (json['assigneeId'] ?? '').toString(),
      createdById: (json['createdById'] ?? '').toString(),
      checklistItems: (json['checklistItems'] as List<dynamic>? ?? [])
          .map(
            (e) => TaskChecklistItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((e) => TaskAttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      completionNotes: json['completionNotes'] as String?,
      completionTimestamp: _dateFromJson(
        json['completionTimestamp'] as String?,
      ),
      createdAt: _dateFromJson(json['createdAt'] as String?) ?? DateTime.now(),
      updatedAt: _dateFromJson(json['updatedAt'] as String?) ?? DateTime.now(),
    );
  }
}

TaskPriority _priorityFromJson(String? value) {
  switch (value) {
    case 'LOW':
      return TaskPriority.low;
    case 'HIGH':
      return TaskPriority.high;
    case 'URGENT':
      return TaskPriority.urgent;
    case 'MEDIUM':
    default:
      return TaskPriority.medium;
  }
}

TaskStatus taskStatusFromJson(String? value) {
  switch (value) {
    case 'IN_PROGRESS':
      return TaskStatus.inProgress;
    case 'COMPLETED':
      return TaskStatus.completed;
    case 'OVERDUE':
      return TaskStatus.overdue;
    case 'CANCELLED':
      return TaskStatus.cancelled;
    case 'ASSIGNED':
    default:
      return TaskStatus.assigned;
  }
}

DateTime? _dateFromJson(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

class TaskPageModel extends TaskPage {
  const TaskPageModel({
    required super.tasks,
    required super.page,
    required super.limit,
    required super.total,
    required super.totalPages,
  });

  factory TaskPageModel.fromJson(Map<String, dynamic> json) => TaskPageModel(
    tasks: (json['data'] as List<dynamic>? ?? [])
        .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
        .toList(),
    page: (json['page'] as num?)?.toInt() ?? 1,
    limit: (json['limit'] as num?)?.toInt() ?? 20,
    total: (json['total'] as num?)?.toInt() ?? 0,
    totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
  );
}

/// Serializes a task in the API's JSON shape, for the offline cache.
Map<String, dynamic> taskToJson(Task task) => {
  'id': task.id,
  'title': task.title,
  'description': task.description,
  'titleAr': task.titleAr,
  'descriptionAr': task.descriptionAr,
  'priority': priorityToJson(task.priority),
  'status': taskStatusToJson(task.status),
  'deadline': task.deadline?.toUtc().toIso8601String(),
  'startDate': task.startDate?.toUtc().toIso8601String(),
  'location': task.location,
  'minPhotosRequired': task.minPhotosRequired,
  'minFilesRequired': task.minFilesRequired,
  'requiresChecklist': task.requiresChecklist,
  'assigneeId': task.assigneeId,
  'createdById': task.createdById,
  'checklistItems': [
    for (final item in task.checklistItems)
      {
        'id': item.id,
        'taskId': item.taskId,
        'label': item.label,
        'done': item.done,
      },
  ],
  'attachments': [
    for (final attachment in task.attachments) attachmentToJson(attachment),
  ],
  'completionNotes': task.completionNotes,
  'completionTimestamp': task.completionTimestamp?.toUtc().toIso8601String(),
  'createdAt': task.createdAt.toUtc().toIso8601String(),
  'updatedAt': task.updatedAt.toUtc().toIso8601String(),
};

String priorityToJson(TaskPriority priority) => switch (priority) {
  TaskPriority.low => 'LOW',
  TaskPriority.medium => 'MEDIUM',
  TaskPriority.high => 'HIGH',
  TaskPriority.urgent => 'URGENT',
};

String taskStatusToJson(TaskStatus status) => switch (status) {
  TaskStatus.assigned => 'ASSIGNED',
  TaskStatus.inProgress => 'IN_PROGRESS',
  TaskStatus.completed => 'COMPLETED',
  TaskStatus.overdue => 'OVERDUE',
  TaskStatus.cancelled => 'CANCELLED',
};
