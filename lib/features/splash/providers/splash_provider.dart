import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/storage/local_storage_service.dart';
import 'package:taskflow_mobile/features/auth/providers/auth_provider.dart';

final splashControllerProvider =
    AsyncNotifierProvider<SplashController, String>(SplashController.new);

class SplashController extends AsyncNotifier<String> {
  // The minimum display time lives in SplashScreen, counted from when the
  // splash is actually on screen; this only works out where to go.
  @override
  Future<String> build() => _resolveDestination();

  Future<String> _resolveDestination() async {
    final local = ref.read(localStorageServiceProvider);

    // First launch? -> Onboarding (stay there until user taps a button)
    final hasSeenOnboarding =
        local.getBool(StorageKeys.hasSeenOnboarding) ?? false;
    if (!hasSeenOnboarding) return RouteNames.onboarding;

    // Not first launch: validate any stored token against the backend.
    // Failures are not swallowed: the splash screen shows them with a retry.
    final isAuthed = await ref
        .read(authControllerProvider.notifier)
        .validateSession();
    return isAuthed ? RouteNames.home : RouteNames.login;
  }
}
