import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:taskflow_mobile/core/notifications/notification_service.dart';

/// Starts Firebase once, in the background.
///
/// main() no longer waits for it before drawing: on a first launch Firebase
/// can take a few seconds, and until the first frame Android only shows its
/// plain launch screen. Code that needs Firebase (push setup) awaits
/// [ensureInitialized] instead; it returns false when Firebase isn't
/// configured, and push is then skipped.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<bool>? _ready;

  static Future<bool> ensureInitialized() => _ready ??= _initialize();

  static Future<bool> _initialize() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      return true;
    } catch (error) {
      debugPrint(
        'Firebase is not configured; push notifications are disabled: $error',
      );
      return false;
    }
  }
}
