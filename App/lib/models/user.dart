// lib/models/user.dart
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? version; // MongoDB __v field

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.version,
  });

  // Getter for full name
  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing user JSON: $json');

      // Handle each field with explicit null checking and type conversion
      final id = json['_id']?.toString() ?? '';
      final firstName = json['firstName']?.toString() ?? '';
      final lastName = json['lastName']?.toString() ?? '';
      final email = json['email']?.toString() ?? '';
      final role = json['role']?.toString() ?? 'employee';

      // Handle date parsing with null safety
      DateTime createdAt;
      try {
        createdAt = json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now();
      } catch (e) {
        print('Error parsing createdAt: $e');
        createdAt = DateTime.now();
      }

      DateTime updatedAt;
      try {
        updatedAt = json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString())
            : DateTime.now();
      } catch (e) {
        print('Error parsing updatedAt: $e');
        updatedAt = DateTime.now();
      }

      // Handle MongoDB version field
      int? version;
      try {
        version = json['__v'] is int ? json['__v'] : int.tryParse(json['__v']?.toString() ?? '');
      } catch (e) {
        print('Error parsing __v field: $e');
        version = null;
      }

      final user = User(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        createdAt: createdAt,
        updatedAt: updatedAt,
        version: version,
      );

      print('Successfully created user: ${user.toString()}');
      return user;

    } catch (e) {
      print('Error parsing User from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}