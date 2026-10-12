import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/constants/api_constants.dart';

/// Whether the backend is currently reachable (true = online).
///
/// There is no connectivity plugin: every API call reports its outcome
/// through the Dio interceptor, which is a better signal anyway (Wi-Fi can
/// be "connected" while the server is unreachable). While offline, the
/// server is probed every [probeInterval] and whenever the app returns to
/// the foreground, so the app notices when the connection comes back.
final connectivityProvider = NotifierProvider<ConnectivityController, bool>(
  ConnectivityController.new,
);

class ConnectivityController extends Notifier<bool> {
  static const probeInterval = Duration(seconds: 15);

  Timer? _probeTimer;
  AppLifecycleListener? _lifecycle;
  bool _probing = false;

  @override
  bool build() {
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (!state) probe();
      },
    );
    ref.onDispose(() {
      _probeTimer?.cancel();
      _lifecycle?.dispose();
    });
    return true;
  }

  void reportOnline() {
    if (state) return;
    _probeTimer?.cancel();
    _probeTimer = null;
    state = true;
  }

  void reportOffline() {
    if (!state) return;
    state = false;
    _probeTimer ??= Timer.periodic(probeInterval, (_) => probe());
  }

  /// Pings a cheap public endpoint. Uses its own Dio so the result is not
  /// reported twice and no auth header is needed.
  Future<void> probe() async {
    if (_probing) return;
    _probing = true;
    try {
      await Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      ).get<dynamic>(ApiConstants.configLocales);
      reportOnline();
    } on DioException catch (error) {
      // Any HTTP answer means the server is reachable.
      if (error.response != null) reportOnline();
    } catch (_) {
      // Still offline.
    } finally {
      _probing = false;
    }
  }
}
