class Profile {
  const Profile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.avatarUrl,
  });
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final String? avatarUrl;
}
