import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';


class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  AddPageState createState() => AddPageState();
}

class AddPageState extends State<AddPage> {
  DateTime? _selectedDeadline;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _detailsController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadlineDate() async {
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: _selectedDeadline ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  // Only update if a valid date is picked and it's different from the current selection
  if (pickedDate != null && pickedDate != _selectedDeadline) {
    setState(() {
      _selectedDeadline = pickedDate;
      _dateController.text =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    });
  }
}


  Future<void> _onGenerateSubtaskPressed() async {
  if (_nameController.text.isEmpty ||
      _dateController.text.isEmpty ||
      _detailsController.text.isEmpty ||
      _subtaskController.text.isEmpty) {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Incomplete Fields'),
        content: const Text('Please fill in all fields before generating a task.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } else {
    // Create a new Task.
    final newTask = Task(
      name: _nameController.text,
      deadline: _selectedDeadline!, // ensure this is non-null by proper validation
    );

    // Add the task to the global list.
    globalTaskList.add(newTask);

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Task generated'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the alert.
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Navigate to the ProjectPage.
    Navigator.pushReplacementNamed(context, '/project');
  }
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // For phone devices, use 90% of width; else fixed width.
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: containerWidth,
              height: screenHeight,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  // Clickable "X" at the top left to return to Dashboard.
                  Positioned(
                    right: 5,
                    top: 13.5,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        // Return to dashboard (or previous page).
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                    ),
                  ),
                  // Title
                  const Positioned(
                    left: 20,
                    top: 20,
                    child: Text(
                      '프로젝트 추가',
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.00,
                        letterSpacing: -0.64,
                      ),
                    ),
                  ),
                  // 프로젝트 이름 input
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '프로젝트 이름',
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.00,
                            letterSpacing: -0.64,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                            hintText: 'Enter project name',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 마감 일 input (with date picker)
                  Positioned(
                    top: 200,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '마감 일',
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.00,
                            letterSpacing: -0.64,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectDeadlineDate,
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(),
                                hintText: 'Select deadline date',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 프로젝트 설명 input
                  Positioned(
                    top: 300,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '프로젝트 설명',
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.00,
                            letterSpacing: -0.64,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _detailsController,
                          minLines: 3,
                          maxLines: null,
                          decoration: InputDecoration(
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                            hintText: 'Enter project details',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 하위작업 요구사항 input
                  Positioned(
                    top: 430,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '하위작업 요구사항',
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.00,
                            letterSpacing: -0.64,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _subtaskController,
                          minLines: 3,
                          maxLines: null,
                          decoration: InputDecoration(
                            isDense: false,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                            hintText: 'Enter subtask requirements',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Generate Subtask button fixed at bottom
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black,
                      ),
                      onPressed: _onGenerateSubtaskPressed,
                      child: const Text(
                        'Generate Subtask',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

