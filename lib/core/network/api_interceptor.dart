import 'package:dio/dio.dart';

import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._secureStorage, {this.onReachable, this.onUnreachable});

  final SecureStorageService _secureStorage;

  /// Called whenever the server answers (any status code).
  final void Function()? onReachable;

  /// Called when a request could not reach the server at all.
  final void Function()? onUnreachable;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    onReachable?.call();
    handler.next(response);
  }

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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = _mapToApiException(err);
    if (mapped.kind == ApiErrorKind.offline) {
      onUnreachable?.call();
    } else if (err.response != null) {
      onReachable?.call();
    }
    handler.next(err.copyWith(error: mapped));
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
