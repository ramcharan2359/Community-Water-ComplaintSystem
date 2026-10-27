/// User roles supported by AquaCare
enum UserRole {
  resident,
  admin,
}

/// Represents a user profile in the AquaCare system
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String community;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.community,
    this.avatarUrl,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isResident => role == UserRole.resident;

  String get roleDisplayName => isAdmin ? 'Municipal Administrator' : 'Community Resident';

  /// Creates a copy of the user with updated fields for in-memory profile edits
  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? community,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      community: community ?? this.community,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
