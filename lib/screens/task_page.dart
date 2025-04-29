import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';
import 'dart:ui' show PointerDeviceKind;


Widget _buildChip(String label, bool selected) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: ShapeDecoration(
      color: selected ? const Color(0xFFF2AC57) : const Color(0x331D1B20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadows: const [ BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0,2)) ],
    ),
    child: Text(
      label,
      style: TextStyle(
        color: selected ? const Color(0xFFF5F5F5) : const Color(0xFF757575),
        fontSize: 14,
        height: 1,
      ),
    ),
  );
}

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
      backgroundColor: Colors.grey.shade200,
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
                      Navigator.pushReplacementNamed(context, '/project');
                    },
                  ),
                ),
                // Task Title.
                Positioned(
                  left: 20,
                  top: 80,
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


                // 2) 날짜 표시 박스 (읽기 전용)
                Positioned(
                  top: 180,
                  left: 16,
                  right: 16,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 16,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFFC78E48)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            // format the deadline from currentTask
                            '${currentTask.deadline.year.toString().padLeft(4, '0')}'
                            ' / ${currentTask.deadline.month.toString().padLeft(2, '0')}'
                            ' / ${currentTask.deadline.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.32,
                            ),
                          ),
                        ),
                        // no edit icon for read-only display
                      ],
                    ),
                  ),
                ),

                // Main content: Subtasks list and new subtask input.

                Positioned(
                    left: 0, right: 0, top: 110,
                    child: SizedBox(
                      height: 56,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,   // ← enable mouse drags
                          },
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _buildChip('업무', true),
                              const SizedBox(width: 10),
                              _buildChip('학업', true),
                              const SizedBox(width: 10),
                              _buildChip('일상', false),
                              const SizedBox(width: 10),
                              _buildChip('운동', false),
                              const SizedBox(width: 10),
                              _buildChip('자기계발', false),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

              Positioned(
  top: 240,
  left: 0,
  right: 0,
  bottom: 0,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          '학위작업',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ),

      // Reorderable list with add row
      Expanded(
        child: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: currentTask.subtasks.length + 1,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final maxIndex = currentTask.subtasks.length;
              if (newIndex > maxIndex) newIndex = maxIndex;
              if (oldIndex < maxIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                final moved = currentTask.subtasks.removeAt(oldIndex);
                currentTask.subtasks.insert(newIndex, moved);
              }
            });
          },
          itemBuilder: (context, index) {
  if (index < currentTask.subtasks.length) {
    final sub = currentTask.subtasks[index];
    return Padding(
      key: ValueKey(sub.title),
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 16,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1) Drag handle
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, size: 24),
            ),

            const SizedBox(width: 8),

            // 2) Checkbox
            Checkbox(
              value: sub.isDone,
              onChanged: (checked) => setState(() {
                sub.isDone = checked!;
              }),
            ),

            const SizedBox(width: 8),

            // 3) Title text, strikethrough when done
            Expanded(
              child: Text(
                sub.title,
                style: TextStyle(
                  color: const Color(0xFF121212),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: sub.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 4) Delete button
            IconButton(
              icon: const Icon(Icons.delete, size: 24),
              onPressed: () => setState(() {
                currentTask.subtasks.removeAt(index);
              }),
            ),
          ],
        ),
      ),
    );
  }

            // Add new subtask row
            return Padding(
              key: const ValueKey('add-subtask'),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(
                        hintText: '새로운 하위작업 직접 추가하기',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final text = _subtaskController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          currentTask.subtasks.add(Subtask(title: text));
                          _subtaskController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  ),
),



                


                // Bottom Navigation Bar.

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 375,
                      height: 56,
                      //padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey[300]!, // Light gray color
                            width: 1.0,              // Thickness of the line
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/dashboard'); // Change route as needed.
                              },
                              child: Container(
                                height: double.infinity,
                                
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 26,
                                      top: 8,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: const Icon(
                                        Icons.home,
                                        size: 24, // Adjust size as needed
                                        color: Color(0xFF9AA5B6), // Changed to gray
                                      ),
                                      ),
                                    ),
                                    Positioned(
                                      left: -6,
                                      top: 38,
                                      child: SizedBox(
                                        width: 88,
                                        height: 14,
                                        child: Text(
                                          '홈',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF9AA5B6), // Changed to gray
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400, // Changed to regular
                                            height: 1.08,
                                            letterSpacing: -0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 'project' button
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/project'); // Change route as needed.
                              },
                              child: Container(
                                height: double.infinity,
                                
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 26,
                                      top: 8,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: const Icon(
                                        Icons.format_list_bulleted,
                                        size: 24, // Adjust size as needed
                                        color: const Color(0xFFBF622C), // Changed to black
                                      ),
                                      ),
                                    ),
                                    Positioned(
                                      left: -6,
                                      top: 38,
                                      child: SizedBox(
                                        width: 88,
                                        height: 14,
                                        child: Text(
                                          '프로젝트',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFFBF622C), // Changed to darker color
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600, // Changed to bold
                                            height: 1.08,
                                            letterSpacing: -0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // '추가' button
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/add'); // change route as needed
                              }, 
                              child: Container(
                                height: double.infinity,
                                
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 26,
                                      top: 8,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: const Icon(
                                        Icons.control_point,
                                        size: 24, // Adjust size as needed
                                        color: const Color(0xFF9AA5B6), // Set color or remove if you need default
                                      ),
                                      ),
                                    ),
                                    Positioned(
                                      left: -6,
                                      top: 38,
                                      child: SizedBox(
                                        width: 88,
                                        height: 14,
                                        child: Text(
                                          '추가',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF9AA5B6),
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.08,
                                            letterSpacing: -0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // '캐릭터' button
                          Expanded(
                            child: Container(
                              height: double.infinity,
                              
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 26,
                                    top: 8,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: const Icon(
                                        Icons.pets,
                                        size: 24, // Adjust size as needed
                                        color: const Color(0xFF9AA5B6), // Set color or remove if you need default
                                      ), // Replace with your icon widget.
                                    ),
                                  ),
                                  Positioned(
                                    left: -6,
                                    top: 38,
                                    child: SizedBox(
                                      width: 88,
                                      height: 14,
                                      child: Text(
                                        '캐릭터',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF9AA5B6),
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.08,
                                          letterSpacing: -0.50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // '프로필' button
                          Expanded(
                            child: Container(
                              height: double.infinity,
                              
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 26,
                                    top: 8,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: const Icon(
                                        Icons.person_outline,
                                        size: 24, // Adjust size as needed
                                        color: const Color(0xFF9AA5B6), // Set color or remove if you need default
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: -6,
                                    top: 38,
                                    child: SizedBox(
                                      width: 88,
                                      height: 14,
                                      child: Text(
                                        '프로필',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF9AA5B6),
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.08,
                                          letterSpacing: -0.50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
      // Bottom Navigation Bar.

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 375,
                      height: 56,
                      //padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey[300]!, // Light gray color
                            width: 1.0,              // Thickness of the line
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/dashboard'); // Change route as needed.
                              },
                              child: Container(
                                height: double.infinity,
                                
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 26,
                                      top: 8,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: const Icon(
                                        Icons.home,
                                        size: 24, // Adjust size as needed
                                        color: Color(0xFF9AA5B6), // Changed to gray
                                      ),
                                      ),
                                    ),
                                    Positioned(
                                      left: -6,
                                      top: 38,
                                      child: SizedBox(
                                        width: 88,
                                        height: 14,
                                        child: Text(
                                          '홈',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF9AA5B6), // Changed to gray
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400, // Changed to regular
                                            height: 1.08,
                                            letterSpacing: -0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 'project' button
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/project'); // Change route as needed.
                              },
                              child: Container(
                                height: double.infinity,
                                
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 26,
                                      top: 8,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: const Icon(
                                        Icons.format_list_bulleted,
                                        size: 24, // Adjust size as needed
                                        color: const Color(0xFFBF622C), // Changed to black
                                      ),
                                      ),
                                    ),
                                    Positioned(
                                      left: -6,
                                      top: 38,
                                      child: SizedBox(
                                        width: 88,
                                        height: 14,
                                        child: Text(
                                          '프로젝트',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFFBF622C), // Changed to darker color
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600, // Changed to bold
                                            height: 1.08,
                                            letterSpacing: -0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // '추가' button
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/add'); // change route as needed
                              }, 
                              child: Container(
                                height: double.infinity,
                                
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 26,
                                      top: 8,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: const Icon(
                                        Icons.control_point,
                                        size: 24, // Adjust size as needed
                                        color: const Color(0xFF9AA5B6), // Set color or remove if you need default
                                      ),
                                      ),
                                    ),
                                    Positioned(
                                      left: -6,
                                      top: 38,
                                      child: SizedBox(
                                        width: 88,
                                        height: 14,
                                        child: Text(
                                          '추가',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF9AA5B6),
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.08,
                                            letterSpacing: -0.50,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // '캐릭터' button
                          Expanded(
                            child: Container(
                              height: double.infinity,
                              
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 26,
                                    top: 8,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: const Icon(
                                        Icons.pets,
                                        size: 24, // Adjust size as needed
                                        color: const Color(0xFF9AA5B6), // Set color or remove if you need default
                                      ), // Replace with your icon widget.
                                    ),
                                  ),
                                  Positioned(
                                    left: -6,
                                    top: 38,
                                    child: SizedBox(
                                      width: 88,
                                      height: 14,
                                      child: Text(
                                        '캐릭터',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF9AA5B6),
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.08,
                                          letterSpacing: -0.50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // '프로필' button
                          Expanded(
                            child: Container(
                              height: double.infinity,
                              
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 26,
                                    top: 8,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: const Icon(
                                        Icons.person_outline,
                                        size: 24, // Adjust size as needed
                                        color: const Color(0xFF9AA5B6), // Set color or remove if you need default
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: -6,
                                    top: 38,
                                    child: SizedBox(
                                      width: 88,
                                      height: 14,
                                      child: Text(
                                        '프로필',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF9AA5B6),
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.08,
                                          letterSpacing: -0.50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
