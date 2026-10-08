import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_mobile/core/constants/storage_keys.dart';
import 'package:taskflow_mobile/core/storage/local_storage_service.dart';

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends Notifier<bool> {
  @override
  bool build() {
    final local = ref.read(localStorageServiceProvider);
    // Do NOT auto-mark here.
    return local.getBool(StorageKeys.hasSeenOnboarding) ?? false;
  }

  Future<void> markSeen() async {
    final local = ref.read(localStorageServiceProvider);
    await local.setBool(StorageKeys.hasSeenOnboarding, true);
    state = true;
  }
}
