import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';
import 'package:taskflow_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:taskflow_mobile/core/notifications/fcm_service.dart';
import 'package:taskflow_mobile/core/offline/offline_files.dart';
import 'package:taskflow_mobile/core/offline/offline_store.dart';
import 'package:taskflow_mobile/core/offline/sync_queue.dart';
import 'package:taskflow_mobile/features/sync/providers/sync_provider.dart';
import 'package:taskflow_mobile/features/calendar/providers/calendar_provider.dart';
import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';
import 'package:taskflow_mobile/features/profile/providers/profile_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_comments_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_details_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, bool>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final secure = ref.read(secureStorageServiceProvider);
    final token = await secure.read(StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }

  Future<void> login({required String email, required String password}) async {
    final repository = ref.read(authRepositoryProvider);
    final user = await repository.login(email: email, password: password);
    // Offline data on this phone belongs to whoever used it last. Keep it
    // (including unsent changes) only when the same person signs back in,
    // e.g. after their session expired.
    final cachedUserId = ref
        .read(offlineStoreProvider)
        .readMap(OfflineStore.profileKey)?['id']
        ?.toString();
    if (cachedUserId == null || cachedUserId != user?.id) {
      await _clearOfflineData();
    }
    _clearUserData();
    state = const AsyncData(true);
    await ref.read(fcmServiceProvider).initializeForAuthenticatedUser();
  }

  Future<bool> validateSession() async {
    // Errors (offline, server down) propagate so the splash can show them.
    final isValid = await ref.read(authRepositoryProvider).validateSession();
    state = AsyncData(isValid);
    if (isValid) {
      await ref.read(fcmServiceProvider).initializeForAuthenticatedUser();
    }
    return isValid;
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    // Before the session token is cleared, so the request is authenticated.
    await ref.read(fcmServiceProvider).unregisterForLogout();
    await repository.logout();
    await _clearOfflineData();
    _clearUserData();
    state = const AsyncData(false);
  }

  /// Removes the offline copy, unsent changes and kept upload files.
  Future<void> _clearOfflineData() async {
    await ref.read(syncQueueProvider.notifier).clear();
    await ref.read(offlineStoreProvider).clear();
    try {
      await ref.read(offlineFilesProvider).clear();
    } catch (_) {
      // Nothing kept, or the folder is not available on this platform.
    }
    ref.invalidate(syncControllerProvider);
  }

  /// Drops everything loaded for the previous account (tasks, profile,
  /// calendar, task details, comments, notifications) so the next login
  /// starts clean instead of showing the last user's data. Providers
  /// rebuild from the API on next use. Add new per-user providers here.
  void _clearUserData() {
    ref
      ..invalidate(tasksControllerProvider)
      ..invalidate(tasksLoadingMoreProvider)
      ..invalidate(tasksLoadMoreFailedProvider)
      ..invalidate(profileControllerProvider)
      ..invalidate(notificationsControllerProvider)
      ..invalidate(calendarMonthTasksProvider)
      ..invalidate(taskDetailsControllerProvider)
      ..invalidate(taskCommentsControllerProvider);
  }
}
