import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';
import 'dart:ui' show PointerDeviceKind;

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  ProjectPageState createState() => ProjectPageState();
}

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

class ProjectPageState extends State<ProjectPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;

    // Sort tasks by deadline using the global list.
    globalTaskList.sort((a, b) => a.deadline.compareTo(b.deadline));

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

                  Positioned(
                    left: 0, right: 0, top: 70,
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
                    top: 130,
                    left: 0,
                    right: 0,
                    bottom: 80,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: globalTaskList.length,
                      itemBuilder: (context, index) {
                        final task = globalTaskList[index];
                        final daysLeft = task.deadline.difference(DateTime.now()).inDays;
                        final progress = task.progress; // 0.0 to 1.0
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/task',
                              arguments: task.name,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 89,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          task.name,
                                          style: const TextStyle(
                                            color: Color(0xFF121212),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: ShapeDecoration(
                                            color: const Color(0xBFF2AC57),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            shadows: [
                                              BoxShadow(
                                                color: Color(0x19000000),
                                                blurRadius: 16,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Text(
                                            '업무',
                                            style: TextStyle(
                                              color: Color(0xFFF5F5F5),
                                              fontSize: 12,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: ShapeDecoration(
                                          color: const Color(0x331D1B20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          '${daysLeft}d',
                                          style: const TextStyle(
                                            color: Color(0xFF121212),
                                            fontSize: 11,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 4,
                                          backgroundColor: Color(0x33F2AC57),
                                          valueColor: AlwaysStoppedAnimation(Color(0xFFF2AC57)),
                                        ),
                                      ),
                                    ],
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
