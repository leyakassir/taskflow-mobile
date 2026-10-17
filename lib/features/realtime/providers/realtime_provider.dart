import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/features/calendar/providers/calendar_provider.dart';
import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';
import 'package:taskflow_mobile/features/realtime/data/datasources/realtime_remote_data_source.dart';
import 'package:taskflow_mobile/features/realtime/domain/entities/realtime_event.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_comments_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_details_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';

/// Live updates: while the signed-in app is open, keeps a connection to the
/// server's event stream and quietly reloads whatever an admin changed
/// (tasks, comments, notifications) without the worker refreshing.
///
/// State is whether the stream is connected. Lives as long as the signed-in
/// shell watches it (autoDispose), so it stops on logout. Disconnects in
/// the background and reconnects, with a catch-up reload, on resume.
final realtimeProvider = NotifierProvider.autoDispose<RealtimeController, bool>(
  RealtimeController.new,
);

class RealtimeController extends AutoDisposeNotifier<bool> {
  /// Events arriving close together are handled in one reload.
  static const debounce = Duration(milliseconds: 400);
  static const _backoff = [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 30),
  ];

  CancelToken? _cancel;
  StreamSubscription<RealtimeEvent>? _subscription;
  Timer? _retryTimer;
  Timer? _flushTimer;
  AppLifecycleListener? _lifecycle;
  bool _active = true;
  bool _inForeground = true;
  bool _connectedBefore = false;
  int _failures = 0;

  final _changedTasks = <String>{};
  final _changedComments = <String>{};
  bool _tasksChanged = false;
  bool _notificationsChanged = false;

  @override
  bool build() {
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _inForeground = true;
        _connect();
      },
      onPause: () {
        _inForeground = false;
        _disconnect();
      },
    );
    ref.onDispose(() {
      _active = false;
      _disconnect();
      _flushTimer?.cancel();
      _lifecycle?.dispose();
    });
    Future.microtask(_connect);
    return false;
  }

  Future<void> _connect() async {
    if (!_active || !_inForeground || _subscription != null) return;
    _retryTimer?.cancel();
    final cancel = CancelToken();
    _cancel = cancel;
    try {
      final events = await ref
          .read(realtimeRemoteDataSourceProvider)
          .connect(cancel);
      if (!_active || cancel.isCancelled) return;
      // Changes may have happened while disconnected: catch up once.
      if (_connectedBefore) _catchUp();
      _connectedBefore = true;
      _failures = 0;
      state = true;
      _subscription = events.listen(
        _onEvent,
        onError: (Object _) => _onDropped(cancel),
        onDone: () => _onDropped(cancel),
        cancelOnError: true,
      );
    } on ApiException catch (error) {
      if (cancel.isCancelled) return;
      // Signed out or session expired: no point retrying with this token.
      if (error.isUnauthorized || error.isForbidden) return;
      _scheduleRetry();
    } catch (_) {
      if (!cancel.isCancelled) _scheduleRetry();
    }
  }

  void _onDropped(CancelToken cancel) {
    _subscription = null;
    if (!_active || cancel.isCancelled) return;
    state = false;
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (!_active || !_inForeground) return;
    final delay = _backoff[_failures.clamp(0, _backoff.length - 1)];
    _failures++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, _connect);
  }

  void _disconnect() {
    _retryTimer?.cancel();
    _cancel?.cancel();
    _cancel = null;
    _subscription?.cancel();
    _subscription = null;
    if (_active) state = false;
  }

  void _onEvent(RealtimeEvent event) {
    switch (event.type) {
      case RealtimeEventType.task:
        _tasksChanged = true;
        if (event.taskId != null) _changedTasks.add(event.taskId!);
      case RealtimeEventType.comment:
        if (event.taskId != null) _changedComments.add(event.taskId!);
      case RealtimeEventType.notification:
        _notificationsChanged = true;
      case RealtimeEventType.ping || RealtimeEventType.unknown:
        return;
    }
    _flushTimer?.cancel();
    _flushTimer = Timer(debounce, _flush);
  }

  void _catchUp() {
    _tasksChanged = true;
    _notificationsChanged = true;
    _flushTimer?.cancel();
    _flushTimer = Timer(debounce, _flush);
  }

  /// Reloads what changed, keeping the current screens visible meanwhile.
  Future<void> _flush() async {
    if (!_active) return;
    final tasks = {..._changedTasks};
    final comments = {..._changedComments};
    final tasksChanged = _tasksChanged;
    final notificationsChanged = _notificationsChanged;
    _changedTasks.clear();
    _changedComments.clear();
    _tasksChanged = false;
    _notificationsChanged = false;

    try {
      if (tasksChanged) {
        await ref.read(tasksControllerProvider.notifier).reloadQuietly();
        ref.invalidate(calendarMonthTasksProvider);
        for (final id in tasks) {
          final details = taskDetailsControllerProvider(id);
          if (ref.exists(details)) await ref.read(details.notifier).reload();
        }
      }
      for (final id in comments) {
        final thread = taskCommentsControllerProvider(id);
        if (ref.exists(thread)) await ref.read(thread.notifier).refresh();
      }
      if (notificationsChanged) {
        await ref.read(notificationsControllerProvider.notifier).refresh();
      }
    } catch (error) {
      debugPrint('Live update refresh failed: $error');
    }
  }
}
