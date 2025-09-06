// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? team;
  final String? organization;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.team,
    this.organization,
    this.role = 'Member',
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      team: json['team'],
      organization: json['organization'],
      role: json['role'] ?? 'Member',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'team': team,
      'organization': organization,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
