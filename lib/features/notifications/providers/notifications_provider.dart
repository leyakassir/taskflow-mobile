import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/features/notifications/data/models/notification_model.dart';
import 'package:taskflow_mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_details_provider.dart';

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(
      NotificationsController.new,
    );

/// Unread count for the bell badge. Updates whenever the list changes:
/// on load, refresh, a foreground push, or marking items read.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsControllerProvider).value;
  return notifications?.where((n) => !n.isRead).length ?? 0;
});

class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() =>
      ref.read(notificationRepositoryProvider).getNotifications();

  /// Pull-to-refresh: keeps the current list visible until the reload ends.
  Future<void> refresh() async {
    final next = await AsyncValue.guard(
      () => ref.read(notificationRepositoryProvider).getNotifications(),
    );
    if (next.hasValue || !state.hasValue) state = next;
  }

  /// Marks a notification read locally right away, then on the server.
  /// Failures are logged only: opening the task matters more.
  Future<void> markRead(String notificationId) async {
    final current = state.value;
    if (current != null) {
      final now = DateTime.now();
      state = AsyncData([
        for (final n in current)
          if (n.id == notificationId) n.markedRead(now) else n,
      ]);
    }
    try {
      await ref.read(notificationRepositoryProvider).markRead(notificationId);
    } catch (error) {
      debugPrint('Could not mark notification $notificationId read: $error');
    }
  }

  /// Marks everything read locally, then on the server. Restores the
  /// previous list and rethrows if the server call fails.
  Future<void> markAllRead() async {
    final previous = state.value;
    if (previous == null) return;
    final now = DateTime.now();
    state = AsyncData([for (final n in previous) n.markedRead(now)]);
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

/// Where tapping a notification leads.
class NotificationDestination {
  const NotificationDestination(this.path, {this.isTab = false});

  final String path;

  /// True for a bottom-navigation tab root, which should be switched to
  /// (`go`) rather than pushed on top of the current screen.
  final bool isTab;
}

final notificationOpenerProvider = Provider<NotificationOpener>(
  NotificationOpener.new,
);

/// Shared by the in-app list and push taps (system tray or foreground):
/// marks the notification read and works out where to go.
class NotificationOpener {
  NotificationOpener(this._ref);

  final Ref _ref;

  /// Returns null when there is nothing to open, e.g. the task was
  /// reassigned away from this worker and is no longer visible to them.
  NotificationDestination? open({
    String? notificationId,
    required NotificationKind kind,
    String? taskId,
  }) {
    if (notificationId != null && notificationId.isNotEmpty) {
      _ref
          .read(notificationsControllerProvider.notifier)
          .markRead(notificationId);
    }
    if (kind == NotificationKind.dailySummary) {
      return const NotificationDestination(RouteNames.calendar, isTab: true);
    }
    if (taskId == null ||
        taskId.isEmpty ||
        kind == NotificationKind.taskUnassigned) {
      return null;
    }
    // The notification may be about a change; don't show a cached copy.
    _ref.invalidate(taskDetailsControllerProvider(taskId));
    return NotificationDestination(
      RouteNames.taskDetailsPath(
        taskId,
        focusComments: kind == NotificationKind.taskComment,
      ),
    );
  }

  /// Same as [open], for a push payload's data map.
  NotificationDestination? openFromPayload(Map<String, dynamic> data) => open(
    notificationId: data['notificationId']?.toString(),
    kind: notificationKindFromJson(data['kind']?.toString()),
    taskId: data['taskId']?.toString(),
  );
}
