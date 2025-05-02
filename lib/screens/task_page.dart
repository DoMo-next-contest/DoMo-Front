import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';
import 'dart:ui' show PointerDeviceKind;


class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  late String taskName;
  late Task currentTask;
  bool _isEditing = false;   

  // add this:
  late String selectedCategory;

  final TextEditingController _subtaskController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final String? passedTaskName =
        ModalRoute.of(context)?.settings.arguments as String?;
    taskName = passedTaskName ?? 'Unknown Task';

    currentTask = globalTaskList.firstWhere(
      (t) => t.name == taskName,
      orElse: () => Task(
        name: taskName,
        deadline: DateTime.now(),
        subtasks: [],
        category: selectedCategory ?? '기타',
      ),
    );

    // initialize the single‐category here:
    selectedCategory = currentTask.category;
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
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 375,
                    height: 72,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Stack(
                      children: [
                        // back arrow on left
                        Positioned(
                          left: 16,
                          top: 16,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        // edit button on right
                        Positioned(
                          right: 16,
                          top: 16,
                          child: IconButton(
                            icon: Icon(_isEditing ? Icons.check : Icons.edit),
                            onPressed: () => setState(() => _isEditing = !_isEditing),
                          ),
                        ),
                      ],
                    ),
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

                Positioned(
                  right: 20,
                  top: 80,               // adjust as needed
                  child: Container(
                    height: 30,            // same height as your chips
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF2AC57),                           // “on” color
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Center(
                      child: Text(
                        currentTask.category,                                   // dynamic label
                        style: const TextStyle(
                          color: Color(0xFFF5F5F5),                             // “on” text color
                          fontSize: 14,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),


                // 2) 날짜 표시 박스 (읽기 전용)
                Positioned(
                  top: 140,
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
                            top: 200,
                            left: 0,
                            right: 0,
                            bottom: 150,
                            child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header...
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

                      // This Expanded + ReorderableListView is scrollable
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
                                  // … your styling …
                                  child: Row(
                                    children: [
                                      if (_isEditing)
                                        ReorderableDragStartListener(
                                          index: index,
                                          child: const Icon(Icons.drag_handle, size: 24),
                                        ),
                                      if (!_isEditing)
                                        Checkbox(
                                          value: sub.isDone,
                                          onChanged: (c) => setState(() => sub.isDone = c!),
                                        ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          sub.title,
                                          style: TextStyle(
                                            decoration: sub.isDone
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            // …other style…
                                          ),
                                        ),
                                      ),
                                      if (_isEditing)
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 24),
                                          onPressed: () =>
                                              setState(() => currentTask.subtasks.removeAt(index)),
                                        ),
                                      if (!_isEditing)
                                        IconButton(
                                          icon: const Icon(Icons.play_arrow_rounded, size: 24),
                                          onPressed: () {
                                            // TODO: play this subtask
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Add‑new‑subtask row (also scrolls)
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



              Positioned(
  left: 0,
  right: 0,
  bottom: 80,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
    child: Row(
      children: [
        // “프로젝트 삭제하기” (outline style)
        Expanded(
          child: Material(
            color: Colors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFC78E48)),
            ),
            child: TextButton(
              onPressed: () { /* TODO: 삭제 로직 */ },
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(48),    // ← forces 48px height
                foregroundColor: const Color(0xFFC78E48),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: const Text('프로젝트 삭제하기'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // “프로젝트 완료하기” (filled style)
        Expanded(
          child: Material(
            color: const Color(0xFFC78E48),
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton(
              onPressed: () { /* TODO: 완료 로직 */ },
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(48),   // ← forces 48px height
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: const Text('프로젝트 완료하기'),
            ),
          ),
        ),
      ],
    ),
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
