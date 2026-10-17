import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/network/api_interceptor.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';
import 'package:taskflow_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:taskflow_mobile/features/auth/data/repositories/auth_repository_impl.dart';

class FakeSecureStorage extends SecureStorageService {
  FakeSecureStorage(this.values) : super(const FlutterSecureStorage());
  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async => values[key] = value;
  @override
  Future<void> delete(String key) async => values.remove(key);
}

class FailingAuthRemote extends AuthRemoteDataSource {
  FailingAuthRemote(this.error) : super(Dio());
  final ApiException error;

  @override
  Future<void> validateSession() async => throw error;
}

/// A fake server: [handle] answers each request with (status, json body).
class FakeServer implements HttpClientAdapter {
  FakeServer(this.handle);
  final Future<(int, Object?)> Function(RequestOptions options) handle;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = await handle(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const (int, Object?) _expired = (401, {'message': 'Invalid or expired token'});
const (int, Object?) _newTokens = (
  200,
  {'accessToken': 'new-access', 'refreshToken': 'new-refresh'},
);

void main() {
  group('Starting the app with a saved session', () {
    test('no connection: reported (splash shows retry), token kept', () async {
      final storage = FakeSecureStorage({StorageKeys.accessToken: 'tok'});
      final repo = AuthRepositoryImpl(
        FailingAuthRemote(
          const ApiException('offline', kind: ApiErrorKind.offline),
        ),
        storage,
      );
      await expectLater(repo.validateSession(), throwsA(isA<ApiException>()));
      expect(storage.values, contains(StorageKeys.accessToken));
    });

    test('session rejected: signed out, tokens removed', () async {
      final storage = FakeSecureStorage({
        StorageKeys.accessToken: 'tok',
        StorageKeys.refreshToken: 'ref',
      });
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
      await expectLater(repo.validateSession(), throwsA(isA<ApiException>()));
      expect(storage.values, contains(StorageKeys.accessToken));
    });
  });

  group('15-minute access token renewed with the refresh token', () {
    late FakeSecureStorage storage;
    late int expiredCalls;

    (Dio, FakeServer) setUpClient(
      Future<(int, Object?)> Function(RequestOptions) handle,
    ) {
      final server = FakeServer(handle);
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = server;
      final refreshDio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = server;
      dio.interceptors.add(
        ApiInterceptor(
          storage,
          client: () => dio,
          refreshClient: refreshDio,
          onSessionExpired: () => expiredCalls++,
        ),
      );
      return (dio, server);
    }

    setUp(() {
      storage = FakeSecureStorage({
        StorageKeys.accessToken: 'old-access',
        StorageKeys.refreshToken: 'old-refresh',
      });
      expiredCalls = 0;
    });

    test('expired access token: renewed and the request sent again', () async {
      final (dio, server) = setUpClient((o) async {
        if (o.path == ApiConstants.refresh) {
          expect(o.data, {'refreshToken': 'old-refresh'});
          return _newTokens;
        }
        return o.headers['Authorization'] == 'Bearer new-access'
            ? (200, {'ok': true})
            : _expired;
      });

      final response = await dio.get<Map<String, dynamic>>('/tasks');

      expect(response.data, {'ok': true});
      expect(storage.values[StorageKeys.accessToken], 'new-access');
      expect(storage.values[StorageKeys.refreshToken], 'new-refresh');
      expect(server.requests.map((r) => r.path), [
        '/tasks',
        ApiConstants.refresh,
        '/tasks',
      ]);
      expect(expiredCalls, 0);
    });

    test('requests failing together share one refresh', () async {
      var refreshes = 0;
      final (dio, _) = setUpClient((o) async {
        if (o.path == ApiConstants.refresh) {
          refreshes++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return _newTokens;
        }
        return o.headers['Authorization'] == 'Bearer new-access'
            ? (200, {'path': o.path})
            : _expired;
      });

      final results = await Future.wait([
        dio.get<Map<String, dynamic>>('/tasks'),
        dio.get<Map<String, dynamic>>('/notifications'),
        dio.get<Map<String, dynamic>>('/me'),
      ]);

      expect(refreshes, 1);
      expect(results.map((r) => r.data!['path']), [
        '/tasks',
        '/notifications',
        '/me',
      ]);
    });

    test(
      'refresh token rejected: tokens deleted, user sent to login',
      () async {
        final (dio, _) = setUpClient(
          (o) async => o.path == ApiConstants.refresh
              ? (401, {'message': 'Session ended, please sign in again'})
              : _expired,
        );

        await expectLater(
          dio.get<void>('/tasks'),
          throwsA(
            isA<DioException>().having(
              (e) => (e.error! as ApiException).statusCode,
              'statusCode',
              401,
            ),
          ),
        );
        expect(storage.values, isEmpty);
        expect(expiredCalls, 1);
      },
    );

    test('no connection during refresh: tokens kept for next time', () async {
      final (dio, _) = setUpClient((o) async {
        if (o.path == ApiConstants.refresh) {
          throw DioException.connectionError(
            requestOptions: o,
            reason: 'offline',
          );
        }
        return _expired;
      });

      await expectLater(dio.get<void>('/tasks'), throwsA(isA<DioException>()));
      expect(storage.values[StorageKeys.refreshToken], 'old-refresh');
      expect(expiredCalls, 0);
    });

    test('wrong password at login is not an expired session', () async {
      storage.values.clear();
      final (dio, server) = setUpClient(
        (o) async => (401, {'message': 'Invalid email or password'}),
      );

      await expectLater(
        dio.post<void>(ApiConstants.login, data: {'email': 'a@b.c'}),
        throwsA(isA<DioException>()),
      );
      expect(server.requests.map((r) => r.path), [ApiConstants.login]);
      expect(expiredCalls, 0);
    });
  });
}
