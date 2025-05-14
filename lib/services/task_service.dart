// lib/services/task_service.dart

import 'dart:convert';  // utf8 디코딩을 위해 필요
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:domo/models/task.dart';

class TaskService {
  final String baseUrl;
  TaskService({this.baseUrl = 'https://15.165.74.79.nip.io'});

  /// 프로젝트 생성 후 ID 반환
  Future<int> createTask(Task task) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/project');
    const reverseTagMap = {
      '업무': 'WORK',
      '학업': 'STUDY',
      '일상': 'LIFE',
      '운동': 'EXERCISE',
      '자기계발': 'SELF_IMPROVEMENT',
    };
    final rawTag = reverseTagMap[task.category] ?? task.category;

    final body = {
      'projectName'       : task.name,
      'projectDescription': task.description,
      'projectRequirement': task.requirements,
      'projectDeadline'   : task.deadline.toUtc().toIso8601String(),
      'projectTagName'    : rawTag,
    };

    final resp = await http.post(
      url,
      headers: {
        'Content-Type' : 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('createTask → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Task creation failed (${resp.statusCode}): $respBody');
    }
    return int.parse(respBody.trim());
  }

  /// 전체 프로젝트 리스트 조회
  Future<List<Task>> getTasks() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final uri = Uri.parse('$baseUrl/api/project');
    final resp = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('getTasks → ${resp.statusCode}: $respBody');

    if (resp.statusCode != 200) {
      throw Exception('Failed to load tasks [${resp.statusCode}]: $respBody');
    }
    final List<dynamic> data = jsonDecode(respBody);
    return data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 특정 프로젝트의 하위작업 조회
  Future<List<Subtask>> getSubtasks(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$projectId/subtasks');
    final resp = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('getSubtasks → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to load subtasks [${resp.statusCode}]: $respBody');
    }
    final List<dynamic> data = jsonDecode(respBody);
    return data.map((e) => Subtask.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 하위작업 생성
  Future<void> createSubtasks(int projectId, Subtask sub) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$projectId/subtasks');
    final bodyJson = jsonEncode([
      {
        'subTaskName'         : sub.title,
        'subTaskExpectedTime' : sub.expectedDuration.inMinutes,
        'subTaskOrder'        : sub.order,
        'subTaskTag'          : sub.tag,
      }
    ]);

    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json; charset=utf-8',
        'Accept'       : 'application/json; charset=utf-8',
      },
      body: bodyJson,
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('createSubtasks → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to create subtask [${resp.statusCode}]: $respBody');
    }
  }

  /// 프로젝트 삭제
  Future<void> deleteProject(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final uri = Uri.parse('$baseUrl/api/project/$projectId');
    final resp = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('deleteProject → ${resp.statusCode}: $respBody');

    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Failed to delete project [${resp.statusCode}]: $respBody');
    }
  }

  /// 프로젝트 수정
  Future<void> updateProject(Task task) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/project/${task.id}');
    final body = {
      'projectName'       : task.name,
      'projectDescription': task.description,
      'projectRequirement': task.requirements,
      'projectDeadline'   : task.deadline.toUtc().toIso8601String(),
      'projectTagName'    : Task.categoryToRawTag(task.category),
    };

    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json; charset=utf-8',
        'Accept'       : 'application/json; charset=utf-8',
      },
      body: jsonEncode(body),
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('updateProject → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to update project [${resp.statusCode}]: $respBody');
    }
  }

  /// 프로젝트 태그 목록 조회
  Future<List<String>> getProjectTags() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/project-tag');
    final resp = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('getProjectTags → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to load project tags [${resp.statusCode}]: $respBody');
    }

    final List<dynamic> data = jsonDecode(respBody);
    final categories = data.map<String>((e) {
      final raw = (e as Map<String, dynamic>)['projectTagName'] as String;
      return Task.rawToUi[raw] ?? raw;
    }).toList();

    Task.allCategories = categories;
    return categories;
  }

  /// 하위작업 완료
  Future<void> setSubtaskDone(int subTaskId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId/done');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('setSubtaskDone → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to mark done [${resp.statusCode}]: $respBody');
    }
  }

  /// 하위작업 미완료
  Future<void> setSubtaskUndone(int subTaskId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId/undone');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('setSubtaskUndone → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to mark undone [${resp.statusCode}]: $respBody');
    }
  }

  /// 하위작업 전체 업데이트
  Future<void> updateSubtasks(int projectId, List<Subtask> subs) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$projectId/subtasks');
    final payload = subs.map((s) => {
      'subTaskId'           : s.id,
      'subTaskName'         : s.title,
      'subTaskExpectedTime' : s.expectedDuration.inMinutes,
      'subTaskTag'          : s.tag,
      'subTaskOrder'        : s.order,
    }).toList();

    final bodyJson = jsonEncode(payload);
    debugPrint('updateSubtasks → PUT $url\n$bodyJson');

    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json; charset=utf-8',
        'Accept'       : 'application/json; charset=utf-8',
      },
      body: bodyJson,
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('updateSubtasks ← ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to update subtasks [${resp.statusCode}]: $respBody');
    }
  }

  /// 하위작업 삭제
  Future<void> deleteSubtask(int subTaskId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId');
    final resp = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('deleteSubtask → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to delete subtask [${resp.statusCode}]: $respBody');
    }
  }

  /// 하위작업 단일 업데이트
  Future<void> updateSubtask(int subTaskId, Map<String, dynamic> body) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json; charset=utf-8',
        'Accept'       : 'application/json; charset=utf-8',
      },
      body: jsonEncode(body),
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('updateSubtask → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to update subtask [${resp.statusCode}]: $respBody');
    }
  }

  /// 하위작업 실제 소요시간 업데이트
  Future<void> updateSubtaskActualTime(int subTaskId, int minutes) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/subtasks/$subTaskId/time');
    final bodyJson = jsonEncode({'subTaskActualTime': minutes});
    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json; charset=utf-8',
        'Accept'       : 'application/json; charset=utf-8',
      },
      body: bodyJson,
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('updateSubtaskActualTime → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to update actual time [${resp.statusCode}]: $respBody');
    }
  }

  /// AI 기반 하위작업 생성
  Future<List<Subtask>> generateSubtasksWithAI(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/gpt/$projectId/subtasks');
    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json; charset=utf-8',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('generateSubtasksWithAI → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('AI generation failed [${resp.statusCode}]: $respBody');
    }

    final jsonBody = jsonDecode(respBody) as Map<String, dynamic>;
    final list     = jsonBody['subTaskList'] as List<dynamic>;
    return list.map((m) => Subtask(
      id               : m['subTaskOrder'] as int,
      order            : m['subTaskOrder'] as int,
      title            : m['subTaskName'] as String,
      expectedDuration : Duration(minutes: m['subTaskExpectedTime'] as int),
      tag              : m['subTaskTag'] as String,
    )).toList();
  }

  /// 프로젝트 완료 및 보상 처리
  Future<Map<String, dynamic>> completeProject(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/project/$projectId/complete');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
        'Content-Type' : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('completeProject → ${resp.statusCode}: $respBody');

    if (resp.statusCode != 200) {
      throw Exception('Failed to complete project [${resp.statusCode}]: $respBody');
    }
    return jsonDecode(respBody) as Map<String, dynamic>;
  }

  /// 진행률 업데이트
  Future<void> updateProgressRate(int projectId, double rate) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/project/$projectId/progress-rate');
    final bodyJson = jsonEncode({'progressRate': rate});
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json; charset=utf-8',
        'Accept'       : 'application/json; charset=utf-8',
      },
      body: bodyJson,
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('updateProgressRate → ${resp.statusCode}: $respBody');

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to update progress rate [${resp.statusCode}]: $respBody');
    }
  }

  /// 최근 프로젝트 불러오기
  Future<Task> fetchRecent() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/project/recent');
    final resp = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('fetchRecent → ${resp.statusCode}: $respBody');

    if (resp.statusCode != 200) {
      throw Exception('Failed to load recent project [${resp.statusCode}]: $respBody');
    }
    return Task.fromRecentJson(jsonDecode(respBody) as Map<String, dynamic>);
  }

  /// 완료된 프로젝트 리스트 조회
  Future<List<Task>> getCompletedProjects() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/project/completed');
    final resp = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('getCompletedProjects → ${resp.statusCode}: $respBody');

    if (resp.statusCode != 200) {
      throw Exception('Failed to load completed projects [${resp.statusCode}]: $respBody');
    }
    final List<dynamic> data = jsonDecode(respBody);
    return data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GPT 기반 난이도 예측
  Future<void> predictLevel(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/gpt/$projectId/predict-level');
    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('predictLevel → ${resp.statusCode}: $respBody');

    if (resp.statusCode != 200) {
      throw Exception('Failed to predict level [${resp.statusCode}]: $respBody');
    }
  }

  /// 예상 시간 계산 트리거
  Future<void> expectedTime(int projectId) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    if (token == null) throw Exception('Not logged in');

    final url = Uri.parse('$baseUrl/api/project/$projectId/expected-time');
    final resp = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept'       : 'application/json; charset=utf-8',
      },
    );
    final respBody = utf8.decode(resp.bodyBytes);
    debugPrint('expectedTime → ${resp.statusCode}: $respBody');

    if (resp.statusCode != 200) {
      throw Exception('Failed to trigger expected time [${resp.statusCode}]: $respBody');
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
}
