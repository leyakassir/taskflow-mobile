import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';
import 'package:taskflow_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:taskflow_mobile/features/auth/data/repositories/auth_repository_impl.dart';

class FakeSecureStorage extends SecureStorageService {
  FakeSecureStorage(this.values) : super(const FlutterSecureStorage());
  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> delete(String key) async => values.remove(key);
}

class FailingAuthRemote extends AuthRemoteDataSource {
  FailingAuthRemote(this.error) : super(Dio());
  final ApiException error;

  @override
  Future<void> validateSession() async => throw error;
}

void main() {
  group('Starting the app with a saved session', () {
    test('offline: stays signed in (offline mode, token kept)', () async {
      final storage = FakeSecureStorage({StorageKeys.accessToken: 'tok'});
      final repo = AuthRepositoryImpl(
        FailingAuthRemote(
          const ApiException('offline', kind: ApiErrorKind.offline),
        ),
        storage,
      );
      expect(await repo.validateSession(), isTrue);
      expect(storage.values, contains(StorageKeys.accessToken));
    });

    test('token rejected: signed out, token removed', () async {
      final storage = FakeSecureStorage({StorageKeys.accessToken: 'tok'});
      final repo = AuthRepositoryImpl(
        FailingAuthRemote(const ApiException('nope', statusCode: 401)),
        storage,
      );
      expect(await repo.validateSession(), isFalse);
      expect(storage.values, isEmpty);
    });

    test('server error: reported (splash shows retry), token kept', () async {
      final storage = FakeSecureStorage({StorageKeys.accessToken: 'tok'});
      final repo = AuthRepositoryImpl(
        FailingAuthRemote(const ApiException('boom', statusCode: 500)),
        storage,
      );
      expect(repo.validateSession(), throwsA(isA<ApiException>()));
      expect(storage.values, contains(StorageKeys.accessToken));
    });
  });
}
