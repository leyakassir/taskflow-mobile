import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_mobile/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:taskflow_mobile/features/profile/domain/entities/profile.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile>(ProfileController.new);

class ProfileController extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() => ref.read(profileRepositoryProvider).getProfile();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).getProfile(),
    );
  }

  Future<void> updateName(String name) async {
    final updated = await ref.read(profileRepositoryProvider).updateName(name);
    state = AsyncData(updated);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => ref
      .read(profileRepositoryProvider)
      .changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  Future<void> uploadAvatar({required String filePath}) async {
    final repository = ref.read(profileRepositoryProvider);
    await repository.uploadAvatar(filePath: filePath);
    state = AsyncData(await repository.getProfile());
  }
}
