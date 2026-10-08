import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow_mobile/app/router/app_router.dart';
import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/core/network/dio_client.dart';
import 'package:taskflow_mobile/core/notifications/notification_service.dart';
import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final fcmServiceProvider = Provider<FcmService>(
  (ref) => FcmService(
    ref: ref,
    dio: ref.watch(dioProvider),
    notifications: ref.watch(notificationServiceProvider),
    router: ref.read(goRouterProvider),
  ),
);

class FcmService {
  FcmService({
    required this.ref,
    required this.dio,
    required this.notifications,
    required this.router,
  });

  final Ref ref;
  final Dio dio;
  final NotificationService notifications;
  final GoRouter router;
  StreamSubscription<String>? _tokenSubscription;
  bool _listening = false;

  Future<void> initializeForAuthenticatedUser() async {
    // A new session must not show the previous user's notifications.
    ref.invalidate(notificationsControllerProvider);
    if (Firebase.apps.isEmpty) return;
    try {
      await notifications.initialize(onTap: _handlePayload);
      final messaging = FirebaseMessaging.instance;
      final permission = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (permission.authorizationStatus == AuthorizationStatus.authorized ||
          permission.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) await _registerToken(token);
        _tokenSubscription ??= messaging.onTokenRefresh.listen(_registerToken);
      }

      if (!_listening) {
        FirebaseMessaging.onMessage.listen((message) {
          notifications.showRemoteMessage(message);
          ref.invalidate(notificationsControllerProvider);
        });
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
        _listening = true;
      }
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) _handleMessageTap(initialMessage);
      await notifications.handleLaunchPayload();
    } catch (error) {
      debugPrint('Could not initialize task push notifications: $error');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await dio.post<void>(ApiConstants.myDeviceToken, data: {'token': token});
    } catch (error) {
      debugPrint('Could not register FCM device token: $error');
    }
  }

  void _handleMessageTap(RemoteMessage message) => _open(message.data);

  /// Marks the notification read and opens its task (scrolled to comments
  /// for comment notifications), or the notifications list when there is
  /// no task to show.
  void _open(Map<String, dynamic> data) {
    final destination = ref
        .read(notificationOpenerProvider)
        .openFromPayload(data);
    // From the tray there is no screen to push onto, so always `go`.
    router.go(destination?.path ?? RouteNames.notifications);
  }

  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      _open(jsonDecode(payload) as Map<String, dynamic>);
    } catch (error) {
      debugPrint('Invalid notification payload: $error');
    }
  }
}
