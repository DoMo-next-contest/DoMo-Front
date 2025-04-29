class Subtask {
  String title;
  bool isDone;
  
  Subtask({ required this.title, this.isDone = false });
}

class Task {
  final String name;
  final DateTime deadline;
  final List<Subtask> subtasks;
  
  Task({
    required this.name,
    required this.deadline,
    this.subtasks = const [],
  });

  /// Returns a value in [0.0, 1.0] corresponding to
  /// the fraction of subtasks marked done.
  double get progress {
    if (subtasks.isEmpty) return 0.0;
    final doneCount = subtasks.where((s) => s.isDone).length;
    return doneCount / subtasks.length;
  }
}

List<Task> globalTaskList = [
  Task(
    name: 'Project Alpha',
    deadline: DateTime(2025, 5, 12),
    subtasks: [
      Subtask(title: 'Design UI'),
      Subtask(title: 'Implement backend'),
    ],
  ),
  Task(
    name: 'Project Beta',
    deadline: DateTime(2025, 5, 10),
    subtasks: [
      Subtask(title: 'Gather requirements'),
      Subtask(title: 'Draft proposal'),
    ],
  ),
  Task(
    name: 'Project Gamma',
    deadline: DateTime(2025, 5, 15),
    subtasks: [
      Subtask(title: 'Develop features'),
      Subtask(title: 'Write tests'),
    ],
  ),
];
