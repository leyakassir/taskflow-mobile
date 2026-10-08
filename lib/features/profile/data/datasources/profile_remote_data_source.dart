import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/network/dio_client.dart';

import '../models/profile_model.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(ref.watch(dioProvider)),
);

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);
  final Dio _dio;

  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.myProfile,
      );
      if (response.data == null) {
        throw const ApiException.generic();
      }
      return ProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<ProfileModel> updateName(String fullName) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiConstants.myProfile,
        data: {'fullName': fullName},
      );
      if (response.data == null) {
        throw const ApiException.generic();
      }
      return ProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.patch<void>(
        ApiConstants.myPassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<void> uploadAvatar({required String filePath}) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      await _dio.post<Map<String, dynamic>>(ApiConstants.myAvatar, data: form);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }
}
