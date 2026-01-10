/// Auth Models
/// 
/// Based on API_CONTRACT.md v1.0
/// Models for authentication endpoints
/// snake_case from API is converted to camelCase

/// Authenticated User Model
/// 
/// From /auth/login and /auth/me responses
class AuthenticatedUser {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? gender;
  final String? department;
  final UserRole role;
  
  const AuthenticatedUser({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
    this.gender,
    this.department,
    required this.role,
  });
  
  /// Parse from JSON (snake_case from API)
  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      profilePicture: json['profile_picture'] as String?,
      gender: json['gender'] as String?,
      department: json['department'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
    );
  }
  
  /// Convert to JSON (for local storage if needed)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'gender': gender,
      'department': department,
      'role': role.toString(),
    };
  }
  
  /// Create copy with updated fields
  AuthenticatedUser copyWith({
    int? userId,
    String? username,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? gender,
    String? department,
    UserRole? role,
  }) {
    return AuthenticatedUser(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      gender: gender ?? this.gender,
      department: department ?? this.department,
      role: role ?? this.role,
    );
  }
}

/// User Role Enum
/// 
/// From API_CONTRACT.md v1.0
enum UserRole {
  admin,
  plp,
  user;
  
  factory UserRole.fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'plp':
        return UserRole.plp;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.user;
    }
  }
  
  @override
  String toString() {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.plp:
        return 'plp';
      case UserRole.user:
        return 'user';
    }
  }
  
  /// Check if user is admin
  bool get isAdmin => this == UserRole.admin;
  
  /// Check if user is PLP
  bool get isPlp => this == UserRole.plp;
  
  /// Check if user is regular user
  bool get isUser => this == UserRole.user;
}

/// Auth Token Model
/// 
/// Contains token and expiry from /auth/login response
/// Token is opaque - no decoding
class AuthToken {
  final String token; // Opaque JWT - never decode
  final DateTime expiresAt;
  
  const AuthToken({
    required this.token,
    required this.expiresAt,
  });
  
  /// Check if token is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }
  
  /// Parse from JSON (from login response)
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
  
  /// Convert to JSON (for storage)
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

/// Login Request Model
class LoginRequest {
  final String username;
  final String password;
  
  const LoginRequest({
    required this.username,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

/// Login Response Model
/// 
/// From /auth/login response (success)
class LoginResponse {
  final AuthToken token;
  final AuthenticatedUser user;
  
  const LoginResponse({
    required this.token,
    required this.user,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      token: AuthToken.fromJson(data),
      user: AuthenticatedUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}

/// Change Password Request Model
class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;
  
  const ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'new_password': newPassword,
    };
  }
}
