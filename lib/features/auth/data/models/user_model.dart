import 'package:taskflow_mobile/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: json['email'] as String? ?? '',
      // Backend uses "fullName" — map it into domain "name".
      name: (json['fullName'] as String?) ?? (json['name'] as String?),
      role: json['role'] as String?,
    );
  }
}
