import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/network/dio_client.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_comment_model.dart';

final taskCommentRemoteDataSourceProvider =
    Provider<TaskCommentRemoteDataSource>((ref) {
      return TaskCommentRemoteDataSource(ref.watch(dioProvider));
    });

class TaskCommentRemoteDataSource {
  TaskCommentRemoteDataSource(this._dio);
  final Dio _dio;

  Future<TaskCommentPageModel> getComments(
    String taskId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.taskComments(taskId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.generic();
      }
      return TaskCommentPageModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<TaskCommentModel> addComment(String taskId, String body) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.taskComments(taskId),
        data: {'body': body},
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException.generic();
      }
      return TaskCommentModel.fromJson(data);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }
}
