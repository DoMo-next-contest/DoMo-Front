import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  late String taskName;
  late Task currentTask;

  // Controller for adding a new subtask.
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the task name passed via route arguments.
    final String? passedTaskName =
        ModalRoute.of(context)?.settings.arguments as String?;
    taskName = passedTaskName ?? 'Unknown Task';

    // Find the Task object from the global list.
    currentTask = globalTaskList.firstWhere(
      (t) => t.name == taskName,
      orElse: () => Task(name: taskName, deadline: DateTime.now(), subtasks: []),
    );
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth =
        screenWidth < 600 ? screenWidth * 0.9 : 393.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: SafeArea(
        child: Center(
          child: Container(
            width: containerWidth,
            height: screenHeight,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                // Close button to return to Dashboard.
                Positioned(
                  right: 5,
                  top: 13.5,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                  ),
                ),
                // Task Title.
                Positioned(
                  left: 20,
                  top: 20,
                  child: Text(
                    currentTask.name,
                    style: const TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.00,
                      letterSpacing: -0.64,
                    ),
                  ),
                ),
                // Main content: Subtasks list and new subtask input.
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  bottom: 0, // leave room for bottom navigation
                  child: Column(
                    children: [
                      // Reorderable list for subtasks.
                      Expanded(
                        child: ReorderableListView(
                          buildDefaultDragHandles: false,
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final Subtask movedSubtask =
                                  currentTask.subtasks.removeAt(oldIndex);
                              currentTask.subtasks.insert(newIndex, movedSubtask);
                            });
                          },
                          children: [
                            for (int index = 0;
                                index < currentTask.subtasks.length;
                                index++)
                              ListTile(
                                key: ValueKey(currentTask.subtasks[index].title),
                                // Place the drag handle on the left.
                                leading: ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(Icons.drag_handle),
                                ),
                                // Checkbox and title.
                                title: Row(
                                  children: [
                                    Checkbox(
                                      value: currentTask.subtasks[index].isDone,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          currentTask.subtasks[index].isDone =
                                              newValue ?? false;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        currentTask.subtasks[index].title,
                                        style: TextStyle(
                                          color: currentTask.subtasks[index].isDone
                                              ? Colors.grey
                                              : const Color(0xFF1E1E1E),
                                          decoration: currentTask.subtasks[index].isDone
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Delete button.
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      currentTask.subtasks.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Fixed new subtask input widget.
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _subtaskController,
                                decoration: const InputDecoration(
                                  hintText: 'Add new subtask',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                if (_subtaskController.text.trim().isNotEmpty) {
                                  setState(() {
                                    currentTask.subtasks.add(
                                      Subtask(title: _subtaskController.text.trim()),
                                    );
                                    _subtaskController.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
