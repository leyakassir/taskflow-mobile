import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.kind,
    required super.title,
    required super.body,
    required super.createdAt,
    super.taskId,
    super.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      kind: notificationKindFromJson(json['kind']?.toString()),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      taskId: json['taskId'] as String?,
      readAt: DateTime.tryParse(json['readAt'] as String? ?? ''),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

/// Maps the backend NotificationKind string (also sent in push payloads).
NotificationKind notificationKindFromJson(String? value) {
  switch (value) {
    case 'TASK_ASSIGNED':
      return NotificationKind.taskAssigned;
    case 'TASK_REASSIGNED':
      return NotificationKind.taskReassigned;
    case 'TASK_UNASSIGNED':
      return NotificationKind.taskUnassigned;
    case 'TASK_DUE_SOON':
      return NotificationKind.taskDueSoon;
    case 'TASK_OVERDUE':
      return NotificationKind.taskOverdue;
    case 'TASK_CANCELLED':
      return NotificationKind.taskCancelled;
    case 'TASK_UPDATED':
      return NotificationKind.taskUpdated;
    case 'TASK_SUBMITTED':
      return NotificationKind.taskSubmitted;
    case 'TASK_COMMENT':
      return NotificationKind.taskComment;
    case 'DAILY_SUMMARY':
      return NotificationKind.dailySummary;
    default:
      return NotificationKind.generic;
  }
}
