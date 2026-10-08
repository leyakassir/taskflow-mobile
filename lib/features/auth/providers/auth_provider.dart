import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';
import 'package:taskflow_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:taskflow_mobile/core/notifications/fcm_service.dart';

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
    await repository.login(email: email, password: password);
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
    await repository.logout();
    state = const AsyncData(false);
  }
}
