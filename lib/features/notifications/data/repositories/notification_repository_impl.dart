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
  NotificationRepositoryImpl(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<AppNotification>> getNotifications() =>
      _remoteDataSource.getNotifications();

  @override
  Future<void> markRead(String notificationId) =>
      _remoteDataSource.markRead(notificationId);

  @override
  Future<void> markAllRead() => _remoteDataSource.markAllRead();
}
