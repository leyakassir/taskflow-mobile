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
      status: _statusFromJson(json['status'] as String?),
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

TaskStatus _statusFromJson(String? value) {
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
