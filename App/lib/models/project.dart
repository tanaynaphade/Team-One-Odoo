// lib/models/project.dart
class Project {
  final String id;
  final String name;
  final String description;
  final List<String> memberIds;
  final String? image;
  final List<String> tags;
  final String managerId;
  final DateTime deadline;
  final String priority;
  final String status;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.memberIds,
    this.image,
    this.tags = const [],
    required this.managerId,
    required this.deadline,
    this.priority = 'Medium',
    this.status = 'Active',
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      description: json['description'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      image: json['image'],
      tags: List<String>.from(json['tags'] ?? []),
      managerId: json['managerId'],
      deadline: DateTime.parse(json['deadline']),
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Active',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'memberIds': memberIds,
      'image': image,
      'tags': tags,
      'managerId': managerId,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
