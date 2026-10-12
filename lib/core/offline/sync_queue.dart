import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/offline/offline_store.dart';
import 'package:taskflow_mobile/core/offline/pending_operation.dart';

/// Changes made offline, oldest first, persisted so they survive the app
/// being closed. The sync controller sends them when the server is back.
final syncQueueProvider = NotifierProvider<SyncQueue, List<PendingOperation>>(
  SyncQueue.new,
);

/// Task ids with changes that have not reached the server yet, for the
/// "Waiting to sync" markers.
final pendingTaskIdsProvider = Provider<Set<String>>((ref) {
  return {
    for (final op in ref.watch(syncQueueProvider))
      if (op.taskId != null) op.taskId!,
  };
});

class SyncQueue extends Notifier<List<PendingOperation>> {
  int _counter = 0;

  OfflineStore get _store => ref.read(offlineStoreProvider);

  @override
  List<PendingOperation> build() {
    final saved = _store.readList(OfflineStore.queueKey) ?? const [];
    return [for (final json in saved) ?PendingOperation.fromJson(json)];
  }

  bool get isEmpty => state.isEmpty;

  /// Current queue, oldest first (for code outside the notifier).
  List<PendingOperation> get operations => state;

  /// True when this task already has unsent changes. New changes to it must
  /// then be queued too, even when online, so they stay in order.
  bool hasPendingFor(String taskId) => state.any((op) => op.taskId == taskId);

  Future<PendingOperation> enqueue(
    PendingOperationType type, {
    String? taskId,
    Map<String, dynamic> payload = const {},
  }) async {
    final now = DateTime.now();
    final op = PendingOperation(
      id: '${now.microsecondsSinceEpoch}-${_counter++}',
      type: type,
      taskId: taskId,
      payload: payload,
      createdAt: now,
    );
    state = [...state, op];
    await _persist();
    return op;
  }

  Future<void> remove(String operationId) async {
    state = [
      for (final op in state)
        if (op.id != operationId) op,
    ];
    await _persist();
  }

  Future<void> clear() async {
    state = const [];
    await _persist();
  }

  Future<void> _persist() => _store.write(OfflineStore.queueKey, [
    for (final op in state) op.toJson(),
  ]);
}
