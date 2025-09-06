// lib/models/task.dart
enum TaskStatus { todo, inProgress, completed, onHold }

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String assigneeId;
  final String? image;
  final List<String> tags;
  final DateTime dueDate;
  TaskStatus status;
  final String priority;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.assigneeId,
    this.image,
    this.tags = const [],
    required this.dueDate,
    required this.status,
    this.priority = 'Medium',
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] ?? json['id'],
      projectId: json['projectId'],
      title: json['title'],
      description: json['description'],
      assigneeId: json['assigneeId'],
      image: json['image'],
      tags: List<String>.from(json['tags'] ?? []),
      dueDate: DateTime.parse(json['dueDate']),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: json['priority'] ?? 'Medium',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'assigneeId': assigneeId,
      'image': image,
      'tags': tags,
      'dueDate': dueDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
