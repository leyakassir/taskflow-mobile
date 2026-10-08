import 'package:dio/dio.dart';

import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._secureStorage);

  final SecureStorageService _secureStorage;

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
    handler.next(err.copyWith(error: _mapToApiException(err)));
  }

  ApiException _mapToApiException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
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
