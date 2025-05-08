// lib/services/task_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:domo/models/task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class TaskService {
  final String baseUrl;
  TaskService({this.baseUrl = 'http://ec2-3-38-104-110.ap-northeast-2.compute.amazonaws.com:8080'});

  Future<void> createTask(Task task) async {
    // 1) Grab token
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) {
      throw Exception('No access token found – are you logged in?');
    }

    // 2) Build URL
    final url = Uri.parse('$baseUrl/api/project');

    // 3) Reverse-map UI category -> raw backend tag
    const _reverseTagMap = {
      '업무': 'WORK',
      '학업': 'STUDY',
      '일상': 'LIFE',
      '운동': 'EXERCISE',
      '자기계발': 'SELF_IMPROVEMENT',
    };
    final rawTag = _reverseTagMap[task.category] ?? task.category;

    // 4) Build request body exactly per API schema
    final body = <String, dynamic>{
      'projectName'       : task.name,
      'projectDescription': task.description,
      'projectRequirement': task.requirements,
      'projectDeadline'   : task.deadline.toUtc().toIso8601String(),
      'projectTagName'    : rawTag,
    };

    // 5) POST with headers
    final response = await http.post(
      url,
      headers: {
        'Content-Type' : 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    // 6) Log for debugging
    debugPrint('createTask → HTTP ${response.statusCode}: ${response.body}');

    // 7) Accept any 2xx
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Task creation failed (${response.statusCode}): ${response.body}',
      );
    }
    // If you want to parse and use the returned Task object:
    // final created = Task.fromJson(jsonDecode(response.body));
    // return created;
  }

  Future<List<Task>> getTasks() async {
    // 1) Grab the token you saved in ProfileService
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) {
      throw Exception('No access token found – are you logged in?');
    }

    // 2) Fire the GET with Authorization header
    final uri = Uri.parse('$baseUrl/api/project');
    debugPrint('GET $uri with token $token');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    // 3) Log for debugging
    debugPrint('← ${response.statusCode}: ${response.body}');

    // 4) Error out if anything but 200
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load tasks [${response.statusCode}]: ${response.body}',
      );
    }

    // 5) Decode and map
    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Subtask>> getSubtasks(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$projectId/subtasks');
    final resp = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    debugPrint('getSubtasks → ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to fetch subtasks');
    }

    final List<dynamic> data = jsonDecode(resp.body);
    return data
        .map((json) => Subtask.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Delete a project by its ID.
  Future<void> deleteProject(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final uri = Uri.parse('$baseUrl/api/project/$projectId');
    final resp = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Failed to delete project [${resp.statusCode}]: ${resp.body}');
    }
  }

  Future<void> updateProject(Task task) async {
    // 1) fetch JWT
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    // 2) build URL
    final url = Uri.parse('$baseUrl/api/project/${task.id}');

    // 3) serialize body
    final body = {
      'projectName':     task.name,
      'projectDeadline': task.deadline.toIso8601String(),
      'projectTagName':  Task.categoryToRawTag(task.category),
      'description':     task.description,
      'requirements':    task.requirements,
    };

    // 4) call PUT
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
      },
      body: jsonEncode(body),
    );

    // 5) check for errors
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to update project [${resp.statusCode}]: ${resp.body}');
    }
  }

  Future<List<String>> getProjectTags() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'accessToken');
  if (token == null) throw Exception('Not logged in');

  final url = Uri.parse('$baseUrl/api/project-tag');
  final resp = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  });
  if (resp.statusCode < 200 || resp.statusCode >= 300) {
    throw Exception('Failed to load project tags [${resp.statusCode}]');
  }

  final List<dynamic> data = jsonDecode(resp.body);

  // map each JSON object → its .projectTagName, then translate via Task._rawToUi
  final categories = data.map((e) {
    final raw = (e as Map<String, dynamic>)['projectTagName'] as String;
    return Task.rawToUi[raw] ?? raw;    // you must make _rawToUi visible (see below)
  }).toList();

  // optionally also update Task.allCategories
  Task.allCategories = categories;

  return categories;
}

}

