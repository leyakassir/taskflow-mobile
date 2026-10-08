import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:taskflow_mobile/features/profile/domain/entities/profile.dart';
import 'package:taskflow_mobile/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider)),
);

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);
  final ProfileRemoteDataSource _remote;
  @override
  Future<Profile> getProfile() => _remote.getProfile();
  @override
  Future<Profile> updateName(String fullName) => _remote.updateName(fullName);
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _remote.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );

  @override
  Future<void> uploadAvatar({required String filePath}) =>
      _remote.uploadAvatar(filePath: filePath);
}
