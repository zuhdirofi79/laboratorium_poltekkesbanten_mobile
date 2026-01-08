class UserModel {
  final int? id;
  final String username;
  final String nama;
  final String email;
  final String? telepon;
  final String role;
  final String? token;

  UserModel({
    this.id,
    required this.username,
    required this.nama,
    required this.email,
    this.telepon,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      telepon: json['telepon'],
      role: json['role'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nama': nama,
      'email': email,
      'telepon': telepon,
      'role': role,
      'token': token,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? nama,
    String? email,
    String? telepon,
    String? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      telepon: telepon ?? this.telepon,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}