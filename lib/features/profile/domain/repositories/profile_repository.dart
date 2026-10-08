import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<Profile> updateName(String fullName);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> uploadAvatar({required String filePath});
}
