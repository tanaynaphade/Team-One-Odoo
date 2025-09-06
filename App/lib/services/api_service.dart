// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/project.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.7:8080/api/v1';

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract cookies for token
        String? accessToken;
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          final cookieList = cookies.split(',');
          for (String cookie in cookieList) {
            if (cookie.trim().startsWith('accessToken=')) {
              accessToken = cookie.split('=')[1].split(';')[0];
              break;
            }
          }
        }

        return {
          'success': true,
          'data': {
            'user': responseData['data'],
            'token': accessToken, // Use extracted token from cookies
          },
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'password': password,
        }),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Register error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // User endpoints
  static Future<User?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'), // You'll need to implement this endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get current user response status: ${response.statusCode}');
      print('Get current user response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data'] ?? data);
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile(String token, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'), // You'll need to implement this endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      print('Update profile response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Project endpoints
  static Future<List<Project>> getProjects(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/project'), // Note: using 'project' not 'projects' to match your backend route
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get projects response status: ${response.statusCode}');
      print('Get projects response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? responseData;
        return data.map((json) => Project.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get projects error: $e');
      return [];
    }
  }

  static Future<Project?> createProject(String token, Map<String, dynamic> projectData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/project/createproject'), // Match your backend route
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(projectData),
      );

      print('Create project response status: ${response.statusCode}');
      print('Create project response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return Project.fromJson(responseData['data']);
      }
      return null;
    } catch (e) {
      print('Create project error: $e');
      return null;
    }
  }

  static Future<bool> updateProject(String token, String projectId, Map<String, dynamic> projectData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/project/$projectId'), // You'll need to implement this endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(projectData),
      );

      print('Update project response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Update project error: $e');
      return false;
    }
  }

  static Future<bool> deleteProject(String token, String projectId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/project/$projectId'), // You'll need to implement this endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete project response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Delete project error: $e');
      return false;
    }
  }

  // Task endpoints - You'll need to implement these in your backend
  static Future<List<Task>> getTasks(String token, {String? projectId}) async {
    try {
      String url = '$baseUrl/tasks';
      if (projectId != null) {
        url += '?projectId=$projectId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get tasks response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'] ?? responseData;
        return data.map((json) => Task.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get tasks error: $e');
      return [];
    }
  }

  static Future<Task?> createTask(String token, Map<String, dynamic> taskData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taskData),
      );

      print('Create task response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return Task.fromJson(responseData['data'] ?? responseData);
      }
      return null;
    } catch (e) {
      print('Create task error: $e');
      return null;
    }
  }

  static Future<bool> updateTask(String token, String taskId, Map<String, dynamic> taskData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(taskData),
      );

      print('Update task response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Update task error: $e');
      return false;
    }
  }

  static Future<bool> deleteTask(String token, String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete task response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Delete task error: $e');
      return false;
    }
  }

  // File upload - You'll need to implement this endpoint in your backend
  static Future<String?> uploadImage(String token, File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();

      print('Upload image response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['imageUrl'];
      }
      return null;
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
  }
}