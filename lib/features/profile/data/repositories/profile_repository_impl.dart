import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/offline/offline_store.dart';
import 'package:taskflow_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:taskflow_mobile/features/profile/data/models/profile_model.dart';
import 'package:taskflow_mobile/features/profile/domain/entities/profile.dart';
import 'package:taskflow_mobile/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    ref.watch(profileRemoteDataSourceProvider),
    ref.watch(offlineStoreProvider),
  ),
);

/// The profile is cached for offline display. Editing it (name, photo,
/// password) needs a connection and fails with the usual offline message.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote, this._store);
  final ProfileRemoteDataSource _remote;
  final OfflineStore _store;

  @override
  Future<Profile> getProfile() async {
    try {
      final profile = await _remote.getProfile();
      await _store.write(OfflineStore.profileKey, profileToJson(profile));
      return profile;
    } on ApiException catch (error) {
      final cached = _store.readMap(OfflineStore.profileKey);
      if (!error.isOffline || cached == null) rethrow;
      return ProfileModel.fromJson(cached);
    }
  }

  @override
  Future<Profile> updateName(String fullName) async {
    final profile = await _remote.updateName(fullName);
    await _store.write(OfflineStore.profileKey, profileToJson(profile));
    return profile;
  }

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
