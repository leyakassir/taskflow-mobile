import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/network/dio_client.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_model.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource(ref.watch(dioProvider));
});

class TaskRemoteDataSource {
  TaskRemoteDataSource(this._dio);
  final Dio _dio;

  Future<TaskPageModel> getTasks({
    int page = 1,
    int limit = 20,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.tasks,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (from != null) 'from': from.toUtc().toIso8601String(),
          if (to != null) 'to': to.toUtc().toIso8601String(),
        },
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.generic();
      }
      return TaskPageModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<TaskModel> getTaskById(String taskId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.taskById(taskId),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.generic();
      }
      return TaskModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<TaskModel> updateTaskStatus(String taskId, String status) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiConstants.taskStatus(taskId),
        data: {'status': status},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.generic();
      }
      return TaskModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<TaskModel> completeTask(
    String taskId,
    TaskSubmissionModel submission,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiConstants.taskComplete(taskId),
        data: submission.toJson(),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.generic();
      }
      return TaskModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<Map<String, dynamic>> uploadAttachment({
    required String taskId,
    required String filePath,
    required String kind,
  }) async {
    try {
      final formData = FormData.fromMap({
        'kind': kind,
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.taskAttachments(taskId),
        data: formData,
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.generic();
      }
      return data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }
}
