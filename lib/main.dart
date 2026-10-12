import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taskflow_mobile/app/app.dart';
import 'package:taskflow_mobile/core/notifications/firebase_bootstrap.dart';
import 'package:taskflow_mobile/core/storage/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase starts in the background so the splash draws immediately
  // (push setup waits for it, see FirebaseBootstrap).
  unawaited(FirebaseBootstrap.ensureInitialized());

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TaskFlowApp(),
    ),
  );
}
