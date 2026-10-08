import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  void Function(String? payload)? _onTap;
  bool _initialized = false;

  Future<void> initialize({void Function(String? payload)? onTap}) async {
    _onTap = onTap;
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) =>
          _onTap?.call(response.payload),
    );
    const channel = AndroidNotificationChannel(
      'taskflow_updates',
      'Task updates',
      description: 'Notifications about assigned tasks and task progress.',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    _initialized = true;
  }

  Future<void> showRemoteMessage(RemoteMessage message) async {
    await initialize();
    final notification = message.notification;
    if (notification == null) return;
    await _plugin.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'taskflow_updates',
          'Task updates',
          channelDescription:
              'Notifications about assigned tasks and task progress.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> handleLaunchPayload() async {
    await initialize();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      _onTap?.call(details?.notificationResponse?.payload);
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The system tray already shows messages that carry a notification payload
  // while the app is in the background; showing it again would duplicate it.
  if (message.notification != null) return;
  try {
    await Firebase.initializeApp();
    await NotificationService().showRemoteMessage(message);
  } catch (_) {
    // Background delivery should not crash the app if Firebase is unavailable.
  }
}
