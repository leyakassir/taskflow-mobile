import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    required super.isActive,
    super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'].toString(),
    email: json['email'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    role: json['role'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
    avatarUrl: json['avatarUrl'] as String?,
  );
}

Map<String, dynamic> profileToJson(Profile p) => {
  'id': p.id,
  'email': p.email,
  'fullName': p.fullName,
  'role': p.role,
  'isActive': p.isActive,
  'avatarUrl': p.avatarUrl,
};
