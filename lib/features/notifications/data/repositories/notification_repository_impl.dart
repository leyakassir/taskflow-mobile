import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/features/notifications/domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
  );
});

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<List<AppNotification>> getNotifications() =>
      _remote.getNotifications();

  @override
  Future<void> markRead(String notificationId) =>
      _remote.markRead(notificationId);

  @override
  Future<void> markAllRead() => _remote.markAllRead();
}
