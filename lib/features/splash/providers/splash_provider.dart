import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/storage/local_storage_service.dart';
import 'package:taskflow_mobile/features/auth/providers/auth_provider.dart';

final splashControllerProvider =
    AsyncNotifierProvider<SplashController, String>(SplashController.new);

class SplashController extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final minimumSplashDuration = Future<void>.delayed(
      const Duration(seconds: 5),
    );
    final destination = _resolveDestination();
    await Future.wait([minimumSplashDuration, destination]);
    return destination;
  }

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
