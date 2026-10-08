import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';
import 'package:taskflow_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:taskflow_mobile/features/auth/domain/entities/user.dart';
import 'package:taskflow_mobile/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageServiceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  @override
  Future<User?> login({required String email, required String password}) async {
    final result = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _secureStorage.write(StorageKeys.accessToken, result.accessToken);
    return result.user;
  }

  @override
  Future<bool> validateSession() async {
    final token = await _secureStorage.read(StorageKeys.accessToken);
    if (token == null || token.isEmpty) return false;

    try {
      await _remoteDataSource.validateSession();
      return true;
    } on ApiException catch (error) {
      // Only a rejected token ends the session. A network failure or a
      // server error says nothing about the token, so it is passed on and
      // the splash screen shows it.
      if (!error.isUnauthorized && !error.isForbidden) rethrow;
      try {
        await _secureStorage.delete(StorageKeys.accessToken);
      } catch (_) {
        // Keep startup resilient if secure storage itself is unavailable.
      }
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
  }
}
