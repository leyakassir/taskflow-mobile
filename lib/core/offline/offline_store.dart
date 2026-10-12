import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/storage/local_storage_service.dart';

/// On-device copy of the signed-in user's data, so the app can show tasks,
/// profile, notifications and comments without a connection.
///
/// Stored as JSON in SharedPreferences (already loaded synchronously at
/// startup, so the cache is available instantly). Every key starts with
/// [_prefix], and [clear] wipes them all on logout so the next account
/// never sees the previous one's data.
final offlineStoreProvider = Provider<OfflineStore>(
  (ref) => OfflineStore(ref.watch(localStorageServiceProvider)),
);

class OfflineStore {
  OfflineStore(this._storage);

  final LocalStorageService _storage;

  static const _prefix = 'offline.';

  static const tasksKey = 'tasks';
  static const profileKey = 'profile';
  static const notificationsKey = 'notifications';
  static const queueKey = 'queue';
  static String commentsKey(String taskId) => 'comments.$taskId';

  Object? read(String key) {
    final raw = _storage.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null; // Corrupt entry: behave as if nothing was cached.
    }
  }

  Map<String, dynamic>? readMap(String key) {
    final value = read(key);
    return value is Map<String, dynamic> ? value : null;
  }

  List<Map<String, dynamic>>? readList(String key) {
    final value = read(key);
    if (value is! List) return null;
    return value.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> write(String key, Object value) =>
      _storage.setString('$_prefix$key', jsonEncode(value));

  Future<void> clear() async {
    for (final key in _storage.keys().where((k) => k.startsWith(_prefix))) {
      await _storage.remove(key);
    }
  }
}
