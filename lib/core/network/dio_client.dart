import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/network/api_interceptor.dart';
import 'package:taskflow_mobile/core/storage/secure_storage_service.dart';

/// Single centralized Dio instance. Never create Dio elsewhere.
final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(ApiInterceptor(secureStorage));
  return dio;
});
