import 'package:taskflow_mobile/core/utils/date_utils.dart';

enum NotificationKind {
  taskAssigned,
  taskReassigned,
  taskUnassigned,
  taskDueSoon,
  taskOverdue,
  taskCancelled,
  taskUpdated,
  taskSubmitted,
  taskComment,
  dailySummary,
  generic,
}

/// Section of the notifications list an item falls into.
enum NotificationDay { today, yesterday, earlier }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.taskId,
    this.readAt,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final String? taskId;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  NotificationDay dayRelativeTo(DateTime now) {
    final created = localDateOf(createdAt);
    final today = dateOnly(now);
    if (created == today) return NotificationDay.today;
    if (created == today.subtract(const Duration(days: 1))) {
      return NotificationDay.yesterday;
    }
    return NotificationDay.earlier;
  }

  AppNotification markedRead(DateTime at) => AppNotification(
    id: id,
    kind: kind,
    title: title,
    body: body,
    createdAt: createdAt,
    taskId: taskId,
    readAt: readAt ?? at,
  );
}
