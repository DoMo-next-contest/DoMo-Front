import 'package:flutter/foundation.dart';

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
  
}

// ✅ Task model with dynamic (user-defined) category
class Task {
  String name;
  DateTime deadline;
  List<Subtask> subtasks;
  String category;
  DateTime lastActivity;

  Task({
    required this.name,
    required this.deadline,
    required this.category,
    this.subtasks = const [],
  }) : lastActivity = DateTime.now();

  static List<String> allCategories = [
    '업무', '학업', '일상', '운동', '자기계발', '기타'
  ];

  double get progress =>
      subtasks.isEmpty
        ? 0.0
        : subtasks.where((s) => s.isDone).length / subtasks.length;

  /// bump the “last worked” timestamp
  void touch() {
    lastActivity = DateTime.now();
  }
}

List<Task> globalTaskList = [
  Task(
    name: 'Project Alpha',
    deadline: DateTime(2025, 5, 12),
    category: '업무',
    subtasks: [
      Subtask(
        title: 'Design UI',
        expectedDuration: Duration(hours: 2, minutes: 15),
      ),
      Subtask(title: 'Implement backend', expectedDuration: Duration(hours: 3)),
    ],
  ),
  Task(
    name: 'Project Beta',
    deadline: DateTime(2025, 5, 10),
    category: '학업',
    subtasks: [
      Subtask(
        title: 'Gather requirements',
        expectedDuration: Duration(hours: 1, minutes: 30),
      ),
      Subtask(
        title: 'Draft proposal',
        expectedDuration: Duration(hours: 2, minutes: 45),
      ),
    ],
  ),
  Task(
    name: 'Project Gamma',
    deadline: DateTime(2025, 5, 15),
    category: '일상',
    subtasks: [
      Subtask(title: 'Develop features', expectedDuration: Duration(hours: 4)),
      Subtask(
        title: 'Write tests',
        expectedDuration: Duration(hours: 2, minutes: 20),
      ),
    ],
  ),
  Task(
    name: 'Project Delta',
    deadline: DateTime(2025, 5, 16),
    category: '운동',
    subtasks: [
      Subtask(title: 'Workout plan', expectedDuration: Duration(hours: 1)),
      Subtask(title: 'Track progress', expectedDuration: Duration(minutes: 45)),
    ],
  ),
  Task(
    name: 'Project Epsilon',
    deadline: DateTime(2025, 5, 18),
    category: '자기계발',
    subtasks: [
      Subtask(
        title: 'Read book',
        expectedDuration: Duration(hours: 1, minutes: 10),
      ),
      Subtask(
        title: 'Practice coding',
        expectedDuration: Duration(hours: 2, minutes: 30),
      ),
    ],
  ),
];
