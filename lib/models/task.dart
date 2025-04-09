class Subtask {
  String title;
  bool isDone;
  
  Subtask({required this.title, this.isDone = false});
}

class Task {
  final String name;
  final DateTime deadline;
  List<Subtask> subtasks; // A mutable list of subtasks
  
  Task({
    required this.name,
    required this.deadline,
    this.subtasks = const [],
  });
}

List<Task> globalTaskList = [
  Task(
    name: 'Project Alpha',
    deadline: DateTime(2025, 4, 12),
    subtasks: [
      Subtask(title: 'Design UI'),
      Subtask(title: 'Implement backend'),
    ],
  ),
  Task(
    name: 'Project Beta',
    deadline: DateTime(2025, 4, 10),
    subtasks: [
      Subtask(title: 'Gather requirements'),
      Subtask(title: 'Draft proposal'),
    ],
  ),
  Task(
    name: 'Project Gamma',
    deadline: DateTime(2025, 4, 15),
    subtasks: [
      Subtask(title: 'Develop features'),
      Subtask(title: 'Write tests'),
    ],
  ),
];
