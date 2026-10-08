import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/network/dio_client.dart';
import 'package:taskflow_mobile/features/notifications/data/models/notification_model.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSource(ref.watch(dioProvider));
    });

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.notifications,
      );
      return (response.data ?? const [])
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.patch<void>(ApiConstants.notificationsReadAll);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _dio.patch<void>(ApiConstants.notificationRead(notificationId));
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw const ApiException.generic();
    }
  }
}
