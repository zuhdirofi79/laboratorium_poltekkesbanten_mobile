import '../../../features/auth/data/auth_models.dart';

/// Admin User Model
/// 
/// Domain model for admin user management
/// Fields in camelCase, mapped from backend snake_case
/// fromJson factory only (no toJson needed for now)
class AdminUser {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;

  const AdminUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
  });

  /// Parse from JSON (snake_case from API → camelCase)
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['nama'] as String, // Backend uses 'nama'
      email: json['email'] as String,
      phone: json['telepon'] as String?, // Backend uses 'telepon'
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
    );
  }
}
