// ✅ Subtask model
class Subtask {
  String title;
  bool isDone;

  Subtask({
    required this.title,
    this.isDone = false,
  });
}

// ✅ Task model with dynamic (user-defined) category
class Task {
  final String name;
  final DateTime deadline;
  final List<Subtask> subtasks;
  final String category; // now a flexible string

  Task({
    required this.name,
    required this.deadline,
    required this.category,
    this.subtasks = const [],
  });

  double get progress {
    if (subtasks.isEmpty) return 0.0;
    final doneCount = subtasks.where((s) => s.isDone).length;
    return doneCount / subtasks.length;
  }
}

// ✅ Global list of tasks with various categories
List<Task> globalTaskList = [
  Task(
    name: 'Project Alpha',
    deadline: DateTime(2025, 5, 12),
    category: '업무',
    subtasks: [
      Subtask(title: 'Design UI'),
      Subtask(title: 'Implement backend'),
    ],
  ),
  Task(
    name: 'Project Beta',
    deadline: DateTime(2025, 5, 10),
    category: '학업',
    subtasks: [
      Subtask(title: 'Gather requirements'),
      Subtask(title: 'Draft proposal'),
    ],
  ),
  Task(
    name: 'Project Gamma',
    deadline: DateTime(2025, 5, 15),
    category: '일상',
    subtasks: [
      Subtask(title: 'Develop features'),
      Subtask(title: 'Write tests'),
    ],
  ),
  Task(
    name: 'Project Delta',
    deadline: DateTime(2025, 5, 16),
    category: '운동',
    subtasks: [
      Subtask(title: 'Workout plan'),
      Subtask(title: 'Track progress'),
    ],
  ),
  Task(
    name: 'Project Epsilon',
    deadline: DateTime(2025, 5, 18),
    category: '자기계발',
    subtasks: [
      Subtask(title: 'Read book'),
      Subtask(title: 'Practice coding'),
    ],
  ),
];
