import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';
import 'package:taskflow_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:taskflow_mobile/core/notifications/fcm_service.dart';
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
    await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    _clearUserData();
    state = const AsyncData(true);
    await ref.read(fcmServiceProvider).initializeForAuthenticatedUser();
  }

  Future<bool> validateSession() async {
    // Errors (no connection, server down) propagate so the splash can show
    // them with Retry.
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
    _clearUserData();
    state = const AsyncData(false);
  }

  /// The server ended the session (refresh token expired or revoked, account
  /// deactivated, password reset). The tokens are already deleted; the
  /// router sends the user to login once the state is false.
  void sessionExpired() {
    if (state.valueOrNull == false) return;
    _clearUserData();
    state = const AsyncData(false);
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
