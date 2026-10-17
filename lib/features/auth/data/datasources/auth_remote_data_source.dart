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

  /// Asks the server to email a 6-digit reset code. The server answers the
  /// same whether or not the email has an account.
  Future<void> requestPasswordReset({
    required String email,
    required String languageCode,
  }) async {
    try {
      await _dio.post<void>(
        ApiConstants.forgotPassword,
        data: {'email': email, 'lang': languageCode == 'ar' ? 'ar' : 'en'},
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  /// Sets a new password with the emailed code. A wrong or expired code is
  /// a 400 [ApiException].
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dio.post<void>(
        ApiConstants.resetPassword,
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  /// "Request an account", step 1: emails a 6-digit code. The server
  /// answers the same whether or not the email already has an account.
  Future<void> requestSignup({
    required String fullName,
    required String email,
    required String password,
    required String languageCode,
  }) async {
    try {
      await _dio.post<void>(
        ApiConstants.signupRequests,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'lang': languageCode == 'ar' ? 'ar' : 'en',
        },
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  /// Step 2: a correct code sends the request to the admins. A wrong or
  /// expired code is a 400 and nothing is sent.
  Future<void> verifySignup({
    required String email,
    required String code,
  }) async {
    try {
      await _dio.post<void>(
        ApiConstants.signupRequestsVerify,
        data: {'email': email, 'code': code},
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        // Mobile sessions: 15-minute access token plus a refresh token.
        data: {'email': email, 'password': password, 'client': 'mobile'},
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

  /// Ends the session on the server: the refresh token stops working.
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
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
