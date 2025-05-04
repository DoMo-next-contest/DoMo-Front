// lib/screens/add/add_page.dart

import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:domo/services/task_service.dart';


class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  AddPageState createState() => AddPageState();
}

class AddPageState extends State<AddPage> {
  List<String> get _categories => Task.allCategories;
  String _selectedCategory = '기타';
  List<Subtask> _generatedSubtasks = [];

  DateTime? _selectedDeadline;
  final _dateController = TextEditingController();
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  final _subtaskController = TextEditingController();
  final _requirementController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _detailsController.dispose();
    _subtaskController.dispose();
    _requirementController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadlineDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildChip(String label) {
    final isSelected = label == _selectedCategory;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? '기타' : label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFF2AC57) : const Color(0x331D1B20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 16,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF757575),
            fontSize: 14,
            height: 1,
          ),
        ),
      ),
    );
  }

  Future<List<Subtask>> _generateSubtasksWithAI() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Subtask(
          title: '리서치 자료 수집',
          expectedDuration: const Duration(hours: 3, minutes: 15)),
      Subtask(title: '초안 작성', expectedDuration: const Duration(hours: 2)),
      Subtask(
          title: '검토 및 수정', expectedDuration: const Duration(hours: 1, minutes: 30)),
    ];
  }

  Future<void> _onGenerateSubtaskPressed() async {
    if (_nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _detailsController.text.isEmpty ||
        _requirementController.text.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Incomplete Fields'),
          content: const Text('Please fill in all fields before generating a task.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
          ],
        ),
      );
      return;
    }
    final newTask = Task(
      name: _nameController.text,
      deadline: _selectedDeadline!,
      category: _selectedCategory,
      subtasks: _generatedSubtasks,
    );
    globalTaskList.add(newTask);
    try {
      await TaskService().createTask(newTask);
      Navigator.pushReplacementNamed(context, '/project');
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('저장 실패'),
          content: Text('에러: $e'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
        ),
      );
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Task generated'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );

    Navigator.pushReplacementNamed(context, '/project');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(0),
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // Close button
              Positioned(
                right: 5,
                top: 13.5,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF767E8C)),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/dashboard'),
                ),
              ),

              // Title
              const Positioned(
                left: 20,
                top: 20,
                child: Text(
                  '새 프로젝트 추가',
                  style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.64,
                  ),
                ),
              ),

              // Form area
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                bottom: 135,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & details
                      Container(
                        height: 140,
                        padding: const EdgeInsets.all(12),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          shadows: const [
                            BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 16,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: '프로젝트 이름',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: Color(0x4CB1B1B1)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: TextField(
                                controller: _detailsController,
                                decoration: const InputDecoration.collapsed(
                                    hintText: '프로젝트 설명'),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Date picker
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          shadows: const [
                            BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 16,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFFC78E48)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _dateController.text.isEmpty
                                    ? 'YYYY / MM / DD'
                                    : _dateController.text,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ),
                            InkWell(onTap: _selectDeadlineDate, child: const Icon(Icons.edit, size: 20)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Category chips
                      SizedBox(
                        height: 56,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories
                                .map((lbl) => Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _buildChip(lbl),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Requirements
                      const Text(
                        '하위작업 요구사항',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          shadows: const [
                            BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 16,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: TextField(
                          controller: _requirementController,
                          maxLines: null,
                          decoration: const InputDecoration.collapsed(
                              hintText: '포함했으면 하는 하위작업 등'),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Generated subtasks
                      if (_generatedSubtasks.isNotEmpty) ...[
                        Column(
                          children: _generatedSubtasks.map((sub) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                height: 75,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape:
                                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 16,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sub.title,
                                            style: const TextStyle(
                                                fontSize: 14, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 4),
                                            decoration: ShapeDecoration(
                                              color: const Color(0x19BF622C),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4)),
                                            ),
                                            child: Text(
                                              '${sub.expectedDuration.inHours}H ${sub.expectedDuration.inMinutes.remainder(60)}M',
                                              style: const TextStyle(
                                                  color: Color(0xFFBF622C),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 24),
                                      onPressed: () {
                                        setState(() {
                                          _generatedSubtasks.remove(sub);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],


                      // AI button
                      DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(8),
                        dashPattern: const [6, 4],
                        color: Colors.black,
                        strokeWidth: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 71,
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final generated = await _generateSubtasksWithAI();
                                setState(() => _generatedSubtasks = generated);
                              },
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.auto_awesome,
                                        color: Color(0xFFF2AC57)),
                                    SizedBox(width: 8),
                                    Opacity(
                                        opacity: 0.5,
                                        child: Text('AI로 하위작업 생성하기',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Save button
              Positioned(
                left: 50,
                right: 50,
                bottom: 75,
                child: GestureDetector(
                  onTap: _onGenerateSubtaskPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x1E1D1B20),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 10,
                            offset: Offset(0, 5))
                      ],
                    ),
                    child: const Center(
                      child: Opacity(
                        opacity: 0.38,
                        child: Text(
                          '프로젝트 저장하기',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom nav
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavButton(icon: Icons.home, label: '홈', active: false,
                          onTap: () => Navigator.pushNamed(context, '/dashboard')),
                      _NavButton(icon: Icons.format_list_bulleted, label: '프로젝트', active: false,
                          onTap: () => Navigator.pushNamed(context, '/project')),
                      _NavButton(icon: Icons.control_point, label: '추가', active: true,
                          onTap: () => Navigator.pushNamed(context, '/add')),
                      _NavButton(icon: Icons.pets, label: '캐릭터', active: false, 
                          onTap: () => Navigator.pushNamed(context, '/decor')),
                      _NavButton(icon: Icons.person_outline, label: '프로필', active: false,
                          onTap: () => Navigator.pushNamed(context, '/profile')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// reuse the same _NavButton from project_page.dart above
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFBF622C) : const Color(0xFF9AA5B6);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                height: 1.08,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
