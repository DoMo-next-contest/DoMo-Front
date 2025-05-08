import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:domo/services/task_service.dart'; // for baseUrl

class ProjectTag {
  final int id;
  final String rawName;
  ProjectTag({ required this.id, required this.rawName });
  factory ProjectTag.fromJson(Map<String, dynamic> json) => ProjectTag(
    id: json['projectTagId'] as int,
    rawName: json['projectTagName'] as String,
  );
}

class Subtask {
  String title;
  bool isDone;

  /// How long you expect this subtask to take.
  Duration expectedDuration;

  /// How long it actually took.
  Duration actualDuration;
  DateTime? runningSince;

  Subtask({
    required this.title,
    this.isDone = false,
    this.expectedDuration = Duration.zero,
    this.actualDuration = Duration.zero,
  });

  /// current total elapsed
  Duration get elapsed =>
      actualDuration +
      (runningSince != null
          ? DateTime.now().difference(runningSince!)
          : Duration.zero);

  void start() {
    runningSince ??= DateTime.now();
  }

  void pause() {
    if (runningSince != null) {
      actualDuration = elapsed;
      runningSince = null;
    }
  }

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      title: json['title'] ?? '',
      isDone: json['isDone'] ?? false,
      expectedDuration: Duration(seconds: json['expectedDuration'] ?? 0),
      actualDuration: Duration(seconds: json['actualDuration'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
        'expectedDuration': expectedDuration.inSeconds,
        'actualDuration': actualDuration.inSeconds,
      };
  
}

// ✅ Task model with dynamic (user-defined) category
/// A task with dynamic (user-defined) categories and optional subtasks.
/// A Task whose database‑assigned id may be null until saved.
class Task {
  final int id;            // ← nullable
  String name;
  DateTime deadline;
  String description;
  String requirements;
  List<Subtask> subtasks;
  String category;
  DateTime lastActivity;

  Task({
    required this.id,
    required this.name,
    required this.deadline,
    required this.category,
    this.description = '',
    this.requirements = '',
    this.subtasks = const [],
  }) : lastActivity = DateTime.now();

  /*
  /// All built‑in UI categories
  static List<String> allCategories = [
    '업무', '학업', '일상', '운동', '자기계발', '기타',
  ];
  */

  

  /// UI‐side list of categories
  static List<String> allCategories = [];

  static const Map<String,String> rawToUi = {
    'WORK': '업무',
    'STUDY': '학업',
    'LIFE': '일상',
    'EXERCISE': '운동',
    'SELF_IMPROVEMENT': '자기계발',
  };

  static Future<void> loadCategories() async {
    final rawList = await TaskService().getProjectTags();  // List<String>
  }

  double get progress =>
      subtasks.isEmpty ? 0.0 : subtasks.where((s) => s.isDone).length / subtasks.length;

  void touch() => lastActivity = DateTime.now();

  factory Task.fromJson(Map<String, dynamic> json) {
    const tagMap = {
      'WORK': '업무',
      'STUDY': '학업',
      'LIFE': '일상',
      'EXERCISE': '운동',
      'SELF_IMPROVEMENT': '자기계발',
    };
    final rawTag = json['projectTagName'] as String? ?? '';
    final category = tagMap[rawTag] ?? rawTag;

    return Task(
      id: json['projectId'] as int,
      name: json['projectName'] as String? ?? '',
      deadline: DateTime.parse(json['projectDeadline'] as String),
      category: category,
      description: json['description'] as String? ?? '',
      requirements: json['requirements'] as String? ?? '',
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    )..lastActivity = json['lastActivity'] != null
        ? DateTime.parse(json['lastActivity'] as String)
        : DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'projectName': name,
      'projectDeadline': deadline.toIso8601String(),
      'projectTagName': _categoryToRawTag(category),
      'description': description,
      'requirements': requirements,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'lastActivity': lastActivity.toIso8601String(),
    };
    return m;
  }

  static String categoryToRawTag(String uiCategory) {
    const reverseMap = {
      '업무':             'WORK',
      '학업':             'STUDY',
      '일상':             'LIFE',
      '운동':             'EXERCISE',
      '자기계발':          'SELF_IMPROVEMENT',
      // if you ever allow free‐form categories, fall back to the UI string itself:
    };
    //return reverseMap[uiCategory] ?? uiCategory;
    return reverseMap[uiCategory] ?? reverseMap['업무']!;
  }

  static String _categoryToRawTag(String cat) {
    const reverseMap = {
      '업무': 'WORK',
      '학업': 'STUDY',
      '일상': 'LIFE',
      '운동': 'EXERCISE',
      '자기계발': 'SELF_IMPROVEMENT',
    };
    return reverseMap[cat] ?? cat;
  }
}


List<Task> globalTaskList = [
  Task(
    id: 0,
    name: 'Project Alpha',
    deadline: DateTime(2025, 5, 12),
    category: '업무',
    description: '',
    requirements: '',
    subtasks: [
      Subtask(
        title: 'Design UI',
        expectedDuration: Duration(hours: 2, minutes: 15),
      ),
      Subtask(title: 'Implement backend', expectedDuration: Duration(hours: 3)),
    ],
  )
];



extension TaskJson on Task {
  Map<String, dynamic> toJson() => {
    'name': name,
    'deadline': deadline.toIso8601String(),
    'category': category,
    'lastActivity': lastActivity.toIso8601String(),
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
  };

  static Task fromJson(Map<String, dynamic> json) => Task(
    id: 0,
    name: json['name'],
    deadline: DateTime.parse(json['deadline']),
    category: json['category'],
    requirements: '',
    description: '',
    
    subtasks: (json['subtasks'] as List)
      .map((s) => SubtaskJson.fromJson(s))
      .toList(),
  )..lastActivity = DateTime.parse(json['lastActivity']);
}

extension SubtaskJson on Subtask {
  Map<String, dynamic> toJson() => {
    'title': title,
    'isDone': isDone,
    'expectedDuration': expectedDuration.inSeconds,
    'actualDuration': actualDuration.inSeconds,
  };

  static Subtask fromJson(Map<String, dynamic> json) => Subtask(
    title: json['title'],
    isDone: json['isDone'] ?? false,
    expectedDuration: Duration(seconds: json['expectedDuration']),
    actualDuration: Duration(seconds: json['actualDuration']),
  );
}
