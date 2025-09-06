// lib/providers/data_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class DataProvider extends ChangeNotifier {
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<User> _users = [];
  bool _isLoading = false;
  String _error = '';

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Projects
  Future<void> loadProjects(String token) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _projects = await ApiService.getProjects(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load projects: \$e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProject(String token, Map<String, dynamic> projectData) async {
    try {
      final project = await ApiService.createProject(token, projectData);
      if (project != null) {
        _projects.add(project);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to create project: \$e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject(String token, String projectId, Map<String, dynamic> projectData) async {
    try {
      final success = await ApiService.updateProject(token, projectId, projectData);
      if (success) {
        // Refresh projects
        await loadProjects(token);
      }
      return success;
    } catch (e) {
      _error = 'Failed to update project: \$e';
      notifyListeners();
      return false;
    }
  }

  // Tasks
  Future<void> loadTasks(String token, {String? projectId}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _tasks = await ApiService.getTasks(token, projectId: projectId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load tasks: \$e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask(String token, Map<String, dynamic> taskData) async {
    try {
      final task = await ApiService.createTask(token, taskData);
      if (task != null) {
        _tasks.add(task);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to create task: \$e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(String token, String taskId, Map<String, dynamic> taskData) async {
    try {
      final success = await ApiService.updateTask(token, taskId, taskData);
      if (success) {
        // Update local task
        final index = _tasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          // Refresh tasks to get updated data
          await loadTasks(token);
        }
      }
      return success;
    } catch (e) {
      _error = 'Failed to update task: \$e';
      notifyListeners();
      return false;
    }
  }

  // Utility methods
  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  List<Task> getTasksForUser(String userId) {
    return _tasks.where((task) => task.assigneeId == userId).toList();
  }

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  Project? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
