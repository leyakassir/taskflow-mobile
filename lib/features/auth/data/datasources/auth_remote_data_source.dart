import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/network/dio_client.dart';
import 'package:taskflow_mobile/features/auth/data/models/login_response_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.generic();
      }
      return LoginResponseModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<void> validateSession() async {
    try {
      await _dio.get<Map<String, dynamic>>(ApiConstants.me);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }
}
