// lib/services/task_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:domo/models/task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class TaskService {
  final String baseUrl;
  TaskService({this.baseUrl = 'http://ec2-15-165-74-79.ap-northeast-2.compute.amazonaws.com:8080'});

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

    final jsonString = utf8.decode(response.bodyBytes);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load tasks [${response.statusCode}]: ${response.body}',
      );
    }

    // 5) Decode and map
    final List<dynamic> data = jsonDecode(jsonString);
    return data
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Subtask>> getSubtasks(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$projectId/subtasks');
    final resp = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        'Failed to load subtasks [${resp.statusCode}]: ${resp.body}'
      );
    }

    // *** decode as UTF‑8 explicitly ***
    final bodyString = utf8.decode(resp.bodyBytes);
    final List<dynamic> data = jsonDecode(bodyString);

    return data
        .map((e) => Subtask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createSubtasks(int projectId, Subtask sub) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$projectId/subtasks');

    final Map<String, dynamic> obj = {
      'subTaskName':         sub.title,
      'subTaskExpectedTime': sub.expectedDuration.inMinutes,
      'subTaskOrder':        sub.order,
    };

    // wrap it in a List
    final bodyJson = jsonEncode([ obj ]);

    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
      },
      body: bodyJson,
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final msg = utf8.decode(resp.bodyBytes);
      throw Exception('Failed to create subtasks [${resp.statusCode}]: $msg');
    }
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

    // decode bodyBytes as UTF‑8
    final bodyString = utf8.decode(resp.bodyBytes);
    final List<dynamic> data = jsonDecode(bodyString);

    final categories = data.map<String>((e) {
      final raw = (e as Map<String, dynamic>)['projectTagName'] as String;
      // Task.rawToUi should be a public static Map<String,String> in Task
      return Task.rawToUi[raw] ?? raw;
    }).toList();

    // update the UI‐side list
    Task.allCategories = categories;
    return categories;
  }

  Future<void> setSubtaskDone(int subTaskId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId/done');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
      },
      // if your API expects a JSON body, uncomment:
      // body: jsonEncode({'done': isDone}),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to mark subtask done [${resp.statusCode}]: ${resp.body}');
    }
  }

  Future<void> setSubtaskUndone(int subTaskId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId/undone');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
      },
      // if your API expects a JSON body, uncomment:
      // body: jsonEncode({'done': isDone}),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to mark subtask done [${resp.statusCode}]: ${resp.body}');
    }
  }

  Future<void> updateSubtasks(int projectId, List<Subtask> subs) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$projectId/subtasks');
    final payload = subs.map((s) => {
          'subTaskId':           s.id,
          'subTaskName':         s.title,
          'subTaskExpectedTime': s.expectedDuration.inMinutes,
          'subTaskTag':          s.tag,
          'subTaskOrder':        s.order,
        }).toList();

    final bodyJson = jsonEncode(payload);
    debugPrint('>>> PUT $url');
    debugPrint('>>> headers: {Authorization: Bearer $token, Content-Type: application/json}');
    debugPrint('>>> body: $bodyJson');

    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json',
      },
      body: bodyJson,
    );
    debugPrint('<<< ${resp.statusCode}');
    debugPrint('<<< ${resp.body}');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        'Failed to update subtasks [${resp.statusCode}]: ${resp.body}',
      );
    }
  }

  Future<void> deleteSubtask(int subTaskId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId');
    final resp = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to delete subtask [${resp.statusCode}]: ${resp.body}');
    }
  }

  Future<void> updateSubtask(int subTaskId, Map<String, dynamic> body) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to update subtask [${resp.statusCode}]: ${resp.body}');
    }
  }

Future<void> updateSubtaskActualTime(int subTaskId, int minutes) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId/time');
    final body = { 'subTaskActualTime': minutes };

    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        'Failed to update actual time [${resp.statusCode}]: ${resp.body}'
      );
    }
  }

  Future<void> createProjectTag(String uiTag) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/project-tag');
    final body = jsonEncode({
      // adjust field name if your backend expects something else
      'projectTagName': uiTag,
    });

    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to create project tag [${resp.statusCode}]: ${resp.body}');
    }
  }

  Future<List<Subtask>> generateSubtasksWithAI(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    final url = Uri.parse('$baseUrl/api/gpt/$projectId/subtasks');
    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
      },
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('AI generation failed ${resp.statusCode}: ${resp.body}');
    }
    final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = jsonBody['subTaskList'] as List<dynamic>;
    return list.map((m) => Subtask(
      id:                DateTime.now().microsecondsSinceEpoch,
      order:             m['subTaskOrder'] as int,
      title:             m['subTaskName'] as String,
      expectedDuration:  Duration(minutes: m['subTaskExpectedTime'] as int),
      tag:               m['subTaskTag'] as String,
    )).toList();
  }
}

