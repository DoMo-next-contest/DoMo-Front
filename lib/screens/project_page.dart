import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  ProjectPageState createState() => ProjectPageState();
}

class ProjectPageState extends State<ProjectPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;

    // Sort tasks by deadline using the global list.
    globalTaskList.sort((a, b) => a.deadline.compareTo(b.deadline));

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
                  // Close button at the top right.
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
                  // Title.
                  const Positioned(
                    left: 20,
                    top: 20,
                    child: Text(
                      '프로젝트 목록',
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
                  // Task list container.
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    bottom: 80, // Leave space for bottom navigation.
                    child: ListView.builder(
                      itemCount: globalTaskList.length,
                      itemBuilder: (context, index) {
                        final task = globalTaskList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/task',
                                  arguments: task.name);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFEEF0F4),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Task name.
                                  Text(
                                    task.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1E1E1E),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  // Deadline formatted as YYYY-MM-DD.
                                  Text(
                                    "${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1E1E1E),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Bottom Navigation Bar.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 56,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFFEEF0F4),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // '홈' button.
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/dashboard');
                              },
                              child: Container(
                                height: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFFEEF0F4),
                                    ),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 26,
                                      top: 8,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Image.asset(
                                          '../../assets/cutie.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      left: -6,
                                      top: 38,
                                      child: SizedBox(
                                        width: 88,
                                        height: 14,
                                        child: Text(
                                          '홈',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF9AA5B6),
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
                          // '프로젝트' button.
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/project');
                              },
                              child: Container(
                                height: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFFEEF0F4),
                                    ),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 26,
                                      top: 8,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Image.asset(
                                          '../../assets/cutie.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      left: -6,
                                      top: 38,
                                      child: SizedBox(
                                        width: 88,
                                        height: 14,
                                        child: Text(
                                          '프로젝트',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF545F70),
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
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
                          // '추가' button.
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/add');
                              },
                              child: Container(
                                height: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFFEEF0F4),
                                    ),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 26,
                                      top: 8,
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Image.asset(
                                          '../../assets/cutie.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const Positioned(
                                      left: -6,
                                      top: 38,
                                      child: SizedBox(
                                        width: 88,
                                        height: 14,
                                        child: Text(
                                          '추가',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF9AA5B6),
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
                          // '캐릭터' button.
                          Expanded(
                            child: Container(
                              height: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFEEF0F4),
                                  ),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 26,
                                    top: 8,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Placeholder(), // Replace with your icon widget.
                                    ),
                                  ),
                                  const Positioned(
                                    left: -6,
                                    top: 38,
                                    child: SizedBox(
                                      width: 88,
                                      height: 14,
                                      child: Text(
                                        '캐릭터',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF9AA5B6),
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
                          // '프로필' button.
                          Expanded(
                            child: Container(
                              height: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFEEF0F4),
                                  ),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  const Positioned(
                                    left: 26,
                                    top: 8,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Placeholder(), // Replace with your icon widget.
                                    ),
                                  ),
                                  const Positioned(
                                    left: -6,
                                    top: 38,
                                    child: SizedBox(
                                      width: 88,
                                      height: 14,
                                      child: Text(
                                        '프로필',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF9AA5B6),
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
