import 'package:flutter/foundation.dart';
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
    await _secureStorage.write(StorageKeys.refreshToken, result.refreshToken);
    return result.user;
  }

  /// Checks the saved session with the server. An expired access token is
  /// renewed on the way (see ApiInterceptor). Only a rejected session ends
  /// it; a network failure or a server error is passed on so the splash
  /// screen can show it with Retry.
  @override
  Future<bool> validateSession() async {
    final token = await _secureStorage.read(StorageKeys.accessToken);
    if (token == null || token.isEmpty) return false;

    try {
      await _remoteDataSource.validateSession();
      return true;
    } on ApiException catch (error) {
      if (!error.isUnauthorized && !error.isForbidden) rethrow;
      try {
        await _deleteTokens();
      } catch (_) {
        // Keep startup resilient if secure storage itself is unavailable.
      }
      return false;
    }
  }

  @override
  Future<void> requestSignup({
    required String fullName,
    required String email,
    required String password,
    required String languageCode,
  }) => _remoteDataSource.requestSignup(
    fullName: fullName.trim(),
    email: email.trim(),
    password: password,
    languageCode: languageCode,
  );

  @override
  Future<void> verifySignup({required String email, required String code}) =>
      _remoteDataSource.verifySignup(email: email.trim(), code: code.trim());

  @override
  Future<void> requestPasswordReset({
    required String email,
    required String languageCode,
  }) => _remoteDataSource.requestPasswordReset(
    email: email.trim(),
    languageCode: languageCode,
  );

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _remoteDataSource.resetPassword(
    email: email.trim(),
    code: code.trim(),
    newPassword: newPassword,
  );

  /// Ends the session on the server (best effort), then forgets the tokens.
  @override
  Future<void> logout() async {
    final refreshToken = await _secureStorage.read(StorageKeys.refreshToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _remoteDataSource.logout(refreshToken);
      } catch (error) {
        // Signing out on this phone must work even without a connection.
        debugPrint('Could not end the session on the server: $error');
      }
    }
    await _deleteTokens();
  }

  Future<void> _deleteTokens() async {
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
  }
}
