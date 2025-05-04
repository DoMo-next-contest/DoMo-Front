// lib/services/task_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:domo/models/task.dart';

class TaskService {
  final String baseUrl;

  TaskService({this.baseUrl = 'http://localhost:5000'});

  Future<void> createTask(Task task) async {
    final url = Uri.parse('$baseUrl/tasks');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Task creation failed: ${response.body}');
    }
  }

  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load tasks: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Task.fromJson(json as Map<String, dynamic>)).toList();

  }
}
