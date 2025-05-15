import 'package:domo/services/task_service.dart'; // for baseUrl

class ProjectTag {
  final int id;
  final String rawName;
  ProjectTag({ required this.id, required this.rawName });
  factory ProjectTag.fromJson(Map<String, dynamic> json) => ProjectTag(
    id: json['projectTagId'] as int,
    rawName: json['projectTagName'] as String,
  );


  static List<ProjectTag> rawList = [];

}




class Subtask {
  final int id;
  int order;
  String title;
  bool isDone;
  Duration expectedDuration;
  Duration actualDuration;
  String tag;
  

  DateTime? runningSince;

  Subtask({
    required this.id,
    required this.order,
    required this.title,
    this.isDone = false,
    this.expectedDuration = Duration.zero,
    this.actualDuration = Duration.zero,
    this.tag = '',
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['subTaskId'] as int,
      order: json['subTaskOrder'] as int,
      title: json['subTaskName'] as String? ?? '',
      isDone: json['subTaskIsDone'] as bool? ?? false,
      expectedDuration:
          Duration(seconds: json['subTaskExpectedTime']*60 as int? ?? 0),
      actualDuration:
          Duration(seconds: json['subTaskActualTime']*60 as int? ?? 0),
      tag: json['subTaskTag'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'subTaskId': id,
        'subTaskOrder': order,
        'subTaskName': title,
        'subTaskIsDone': isDone,
        'subTaskExpectedTime': expectedDuration*60,
        'subTaskActualTime': actualDuration*60,
        'subTaskTag': tag,
      };
  
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
}
/*
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
*/

extension TaskProgressExt on Task {
  /// Prefer the backend’s projectProgressRate if it’s non-null and > 0,
  /// otherwise recompute as done/total.
  double get computedProgress {
    // 1) Try the server value
    final server = (progress > 0.0) ? progress : null;
    if (server != null) return server;

    // 2) Fallback: no subtasks → zero
    if (subtasks.isEmpty) return 0.0;

    // 3) Compute done/total
    final done = subtasks.where((s) => s.isDone).length;
    return done / subtasks.length;
  }
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
  double progress;
  bool completed;

  Task({
    required this.id,
    required this.name,
    required this.deadline,
    required this.category,
    this.description = '',
    this.requirements = '',
    this.subtasks = const [],
    this.progress = 0.0,
    required this.completed,
  }) : lastActivity = DateTime.now();

  /*
  /// All built‑in UI categories
  static List<String> allCategories = [
    '업무', '학업', '일상', '운동', '자기계발', '기타',
  ];
  */


  /// UI‐side list of categories
  static List<String> allCategories = [];

  static List<ProjectTag> rawList = [];

  static const Map<String,String> rawToUi = {
    'WORK': '업무',
    'STUDY': '학업',
    'LIFE': '일상',
    'EXERCISE': '운동',
    'SELF_IMPROVEMENT': '자기계발',
  };

  /// UI label → raw tag
  static String categoryToRawTag(String ui) {
    return rawToUi.entries
        .firstWhere(
          (kv) => kv.value == ui,
          orElse: () => MapEntry(ui, ui),  // fallback to itself
        )
        .key;
  }

  static Future<void> loadCategories() async {
    final rawList = await TaskService().getProjectTags();  // List<String>
  }

  //double get progressRate =>
    //  subtasks.isEmpty ? 0.0 : subtasks.where((s) => s.isDone).length / subtasks.length;

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
      progress: ((json['projectProgressRate'] as num?)?.toDouble() ?? 0.0) / 100.0,
      description: json['projectDescription'] as String? ?? '',
      requirements: json['projectRequirements'] as String? ?? '',
      completed: json['completed'],
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
  /*
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
  */
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

  factory Task.fromRecentJson(Map<String, dynamic> json) {
    final rawTag = json['projectTagName'] as String? ?? '';
    final uiCategory = rawToUi[rawTag] ?? rawTag;

    return Task(
      id: json['projectId'] as int,
      name: json['projectName'] as String,
      deadline: DateTime.parse(json['projectDeadline'] as String),      // or some sensible default
      category: uiCategory,          // <- here
      description: json['projectDescription'],
      requirements: '',
      subtasks: const [],
      progress: ((json['projectProgressRate'] as num?)?.toDouble() ?? 0.0) / 100.0,
      completed: json['completed'],
    )..lastActivity = DateTime.now();
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
    completed: true,
    subtasks: [
      Subtask(
        order:0,
        id: 0,
        title: 'Design UI',
        expectedDuration: Duration(hours: 2, minutes: 15),
      ),
      Subtask(order:0,
        id: 0,title: 'Implement backend', expectedDuration: Duration(hours: 3)),
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
    completed: json['completed'],
    
    subtasks: (json['subtasks'] as List)
      .map((s) => SubtaskJson.fromJson(s))
      .toList(),
  )..lastActivity = DateTime.parse(json['lastActivity']);
}

extension SubtaskJson on Subtask {
  Map<String, dynamic> toJson() => {
    'title': title,
    'isDone': isDone,
    'expectedDuration': expectedDuration*60,
    'actualDuration': actualDuration*60,
  };

  static Subtask fromJson(Map<String, dynamic> json) => Subtask(
    id: json['subTaskId'] as int,
      order: json['subTaskOrder'] as int,
      title: json['subTaskName'] as String? ?? '',
      isDone: json['subTaskIsDone'] as bool? ?? false,
      expectedDuration:
          Duration(seconds: json['subTaskExpectedTime'*60] as int? ?? 0),
      actualDuration:
          Duration(seconds: json['subTaskActualTime']*60 as int? ?? 0),
      tag: json['subTaskTag'] as String? ?? '',
  );
}
