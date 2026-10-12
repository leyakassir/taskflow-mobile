import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/offline/offline_store.dart';
import 'package:taskflow_mobile/core/offline/pending_operation.dart';
import 'package:taskflow_mobile/core/offline/sync_queue.dart';
import 'package:taskflow_mobile/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:taskflow_mobile/features/notifications/data/models/notification_model.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/features/notifications/domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
    ref.watch(offlineStoreProvider),
    ref.read(syncQueueProvider.notifier),
  );
});

/// Keeps the last notification list for offline use. Marking items read
/// while offline is queued; the read state shows immediately.
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote, this._store, this._queue);

  final NotificationRemoteDataSource _remote;
  final OfflineStore _store;
  final SyncQueue _queue;

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      final list = await _remote.getNotifications();
      await _save(list);
      return _withPendingReads(list);
    } on ApiException catch (error) {
      final cached = _store
          .readList(OfflineStore.notificationsKey)
          ?.map(NotificationModel.fromJson)
          .toList();
      if (!error.isOffline || cached == null) rethrow;
      return _withPendingReads(cached);
    }
  }

  @override
  Future<void> markRead(String notificationId) async {
    try {
      await _remote.markRead(notificationId);
    } on ApiException catch (error) {
      if (!error.isOffline) rethrow;
      await _queue.enqueue(
        PendingOperationType.markNotificationRead,
        payload: {'notificationId': notificationId},
      );
    }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _remote.markAllRead();
    } on ApiException catch (error) {
      if (!error.isOffline) rethrow;
      await _queue.enqueue(PendingOperationType.markAllNotificationsRead);
    }
  }

  Future<void> _save(List<AppNotification> list) => _store.write(
    OfflineStore.notificationsKey,
    [for (final n in list) notificationToJson(n)],
  );

  List<AppNotification> _withPendingReads(List<AppNotification> list) {
    final ops = _queue.operations;
    final all = ops.any(
      (op) => op.type == PendingOperationType.markAllNotificationsRead,
    );
    final ids = {
      for (final op in ops)
        if (op.type == PendingOperationType.markNotificationRead)
          op.payload['notificationId'],
    };
    if (!all && ids.isEmpty) return list;
    final now = DateTime.now();
    return [
      for (final n in list) all || ids.contains(n.id) ? n.markedRead(now) : n,
    ];
  }
}
