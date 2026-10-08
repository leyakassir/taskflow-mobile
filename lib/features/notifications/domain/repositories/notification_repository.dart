import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepository {
  /// The current user's notifications, newest first.
  Future<List<AppNotification>> getNotifications();

  /// Marks one of the current user's notifications as read.
  Future<void> markRead(String notificationId);

  /// Marks every unread notification of the current user as read.
  Future<void> markAllRead();
}
