// lib/screens/tasks/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/data_provider.dart';
import 'package:app/models/task.dart';
import 'package:app/config/theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _titleController = TextEditingController(text: _task.title);
    _descriptionController = TextEditingController(text: _task.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveTask,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer2<AuthProvider, DataProvider>(
        builder: (context, auth, dataProvider, _) {
          final project = dataProvider.getProjectById(_task.projectId);
          final assignee = dataProvider.getUserById(_task.assigneeId);
          final isOverdue = _task.dueDate.isBefore(DateTime.now()) && _task.status != TaskStatus.completed;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Image
                  if (_task.image != null) ...[
                    Card(
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(_task.image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Title and Priority
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _isEditing
                                    ? TextFormField(
                                  controller: _titleController,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Title',
                                    border: InputBorder.none,
                                  ),
                                )
                                    : Text(
                                  _task.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _buildPriorityChip(_task.priority),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Status
                          _buildStatusChip(_task.status, isEditing: _isEditing),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _isEditing
                              ? TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Enter task description...',
                              border: InputBorder.none,
                            ),
                            maxLines: 4,
                          )
                              : Text(
                            _task.description.isEmpty
                                ? 'No description provided'
                                : _task.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: _task.description.isEmpty
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Project and Assignment Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Project
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.folder, color: AppColors.primary),
                            title: const Text('Project'),
                            subtitle: Text(project?.name ?? 'Unknown Project'),
                          ),
                          const Divider(),
                          // Assignee
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.person, color: AppColors.primary),
                            title: const Text('Assigned to'),
                            subtitle: Text(assignee?.fullName ?? 'Unknown User'), // FIXED: Changed from .name to .fullName
                          ),
                          const Divider(),
                          // Due Date
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.calendar_today,
                              color: isOverdue ? AppColors.error : AppColors.primary,
                            ),
                            title: const Text('Due Date'),
                            subtitle: Row(
                              children: [
                                Text(
                                  '${_task.dueDate.day}/${_task.dueDate.month}/${_task.dueDate.year}',
                                  style: TextStyle(
                                    color: isOverdue ? AppColors.error : AppColors.textSecondary,
                                  ),
                                ),
                                if (isOverdue) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      'OVERDUE',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Divider(),
                          // Created Date
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.access_time, color: AppColors.primary),
                            title: const Text('Created'),
                            subtitle: Text('${_task.createdAt.day}/${_task.createdAt.month}/${_task.createdAt.year}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  if (_task.tags.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tags',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _task.tags.map((tag) => _buildTag(tag)).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status, {bool isEditing = false}) {
    if (isEditing) {
      return DropdownButton<TaskStatus>(
        value: status,
        items: TaskStatus.values.map((s) {
          return DropdownMenuItem(
            value: s,
            child: Text(_getStatusText(s)),
          );
        }).toList(),
        onChanged: (newStatus) {
          if (newStatus != null) {
            setState(() {
              _task.status = newStatus;
            });
          }
        },
      );
    }

    Color color;
    String text;
    switch (status) {
      case TaskStatus.todo:
        color = AppColors.textTertiary;
        text = 'TO DO';
        break;
      case TaskStatus.inProgress:
        color = AppColors.warning;
        text = 'IN PROGRESS';
        break;
      case TaskStatus.completed:
        color = AppColors.success;
        text = 'COMPLETED';
        break;
      case TaskStatus.onHold:
        color = AppColors.error;
        text = 'ON HOLD';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = AppColors.priorityHigh;
        break;
      case 'medium':
        color = AppColors.priorityMedium;
        break;
      case 'low':
        color = AppColors.priorityLow;
        break;
      default:
        color = AppColors.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.onHold:
        return 'On Hold';
    }
  }

  void _saveTask() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (auth.token == null) return;

    final taskData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'status': _task.status.toString().split('.').last,
    };

    final success = await dataProvider.updateTask(auth.token!, _task.id, taskData);
    if (success) {
      setState(() {
        _task = Task(
          id: _task.id,
          projectId: _task.projectId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          assigneeId: _task.assigneeId,
          image: _task.image,
          tags: _task.tags,
          dueDate: _task.dueDate,
          status: _task.status,
          priority: _task.priority,
          createdAt: _task.createdAt,
        );
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dataProvider.error.isNotEmpty
              ? dataProvider.error
              : 'Failed to update task'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}