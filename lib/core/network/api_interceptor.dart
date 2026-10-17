import 'package:dio/dio.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';

/// Adds the access token to every request and maps errors to
/// [ApiException].
///
/// Access tokens last 15 minutes. When the server answers 401, the refresh
/// token is traded for a new pair (POST /auth/refresh) and the request is
/// sent again once. If that fails the session is over: both tokens are
/// deleted and [onSessionExpired] runs, which sends the user to login.
class ApiInterceptor extends Interceptor {
  ApiInterceptor(
    this._secureStorage, {
    required this.client,
    Dio? refreshClient,
    this.onSessionExpired,
  }) : _refreshClient =
           refreshClient ??
           Dio(
             BaseOptions(
               baseUrl: ApiConstants.baseUrl,
               connectTimeout: ApiConstants.connectTimeout,
               receiveTimeout: ApiConstants.receiveTimeout,
               headers: const {'Content-Type': 'application/json'},
             ),
           );

  final SecureStorageService _secureStorage;

  /// The Dio this interceptor belongs to, used to send a request again.
  final Dio Function() client;

  /// Has no interceptor, so refreshing can never trigger another refresh.
  final Dio _refreshClient;

  final void Function()? onSessionExpired;

  /// The refresh in progress. Requests failing at the same time wait for
  /// it instead of each spending the (single-use) refresh token.
  Future<String?>? _refreshing;

  static const _retriedKey = 'tokenRefreshRetried';
  static const _noRefreshPaths = {
    ApiConstants.login,
    ApiConstants.refresh,
    ApiConstants.logout,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final sentToken = options.headers['Authorization'] != null;
    if (err.response?.statusCode == 401 &&
        sentToken &&
        options.extra[_retriedKey] != true &&
        !_noRefreshPaths.contains(options.path)) {
      final newToken = await _refreshAccessToken();
      if (newToken != null) {
        try {
          final retried = await client().fetch<dynamic>(
            _retryOptions(options, newToken),
          );
          return handler.resolve(retried);
        } on DioException catch (retryError) {
          return handler.next(
            retryError.copyWith(error: _mapToApiException(retryError)),
          );
        }
      }
    }
    handler.next(err.copyWith(error: _mapToApiException(err)));
  }

  Future<String?> _refreshAccessToken() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  /// Returns the new access token, or null when the session has ended.
  Future<String?> _refresh() async {
    final refreshToken = await _secureStorage.read(StorageKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _endSession();
      return null;
    }
    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );
      final access = response.data?['accessToken'];
      final refresh = response.data?['refreshToken'];
      if (access is! String || refresh is! String) {
        await _endSession();
        return null;
      }
      await _secureStorage.write(StorageKeys.accessToken, access);
      await _secureStorage.write(StorageKeys.refreshToken, refresh);
      return access;
    } on DioException catch (error) {
      // Rejected: the session is over. A network problem is not: keep the
      // tokens and let this request fail; the next one tries again.
      if (error.response?.statusCode == 401) await _endSession();
      return null;
    }
  }

  Future<void> _endSession() async {
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
    onSessionExpired?.call();
  }

  RequestOptions _retryOptions(RequestOptions options, String token) {
    final data = options.data;
    return options.copyWith(
      // Multipart bodies can only be sent once; send a fresh copy.
      data: data is FormData ? data.clone() : data,
      headers: {...options.headers, 'Authorization': 'Bearer $token'},
      extra: {...options.extra, _retriedKey: true},
    );
  }

  ApiException _mapToApiException(DioException err) {
    switch (err.type) {
      // Never reached the server: same as having no connection.
      case DioExceptionType.connectionTimeout:
        return const ApiException(
          'No internet connection.',
          kind: ApiErrorKind.offline,
        );
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          'Connection timed out.',
          kind: ApiErrorKind.timeout,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No internet connection.',
          kind: ApiErrorKind.offline,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          'Secure connection failed.',
          kind: ApiErrorKind.certificate,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          'Request cancelled.',
          kind: ApiErrorKind.cancelled,
        );
      case DioExceptionType.badResponse:
        return _mapResponseError(err);
      case DioExceptionType.unknown:
        return const ApiException.generic();
    }
  }

  ApiException _mapResponseError(DioException err) {
    final response = err.response;
    final data = response?.data;

    String message = 'Something went wrong. Please try again.';
    var kind = ApiErrorKind.generic;
    if (data is Map<String, dynamic> && data['message'] != null) {
      final raw = data['message'];
      message = raw is List ? raw.join(', ') : raw.toString();
      kind = ApiErrorKind.server;
    }

    return ApiException(message, statusCode: response?.statusCode, kind: kind);
  }
}
