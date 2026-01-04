import '../core/constants/strings.dart';

class UserModel {
  final String id;
  final String token;
  final String userName;
  final String fullName;
  final String role;
  final String? avatarUrl;
  final String expiration;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.token,
    required this.userName,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    required this.expiration,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'] ?? '',
      expiration: json['expiration'] ?? DateTime.now().toIso8601String(),
      userName: json['userName'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? AppStrings.roleStudent,
      avatarUrl: json['avatarUrl'],
      email: json['email'] ?? '',
      id: json['id'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'userName': userName,
      'fullName': fullName,
      'role': role,
      'avatarUrl': avatarUrl,
      'expiration': expiration,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}