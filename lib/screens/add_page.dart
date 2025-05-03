import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:ui' show PointerDeviceKind;


class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  AddPageState createState() => AddPageState();
}

class AddPageState extends State<AddPage> {

  // 1) List of all possible categories, including “기타”
  List<String> get _categories => Task.allCategories;
  // 2) The one currently selected
  String _selectedCategory = '기타';
  late List<Subtask> _generatedSubtasks = [];

  DateTime? _selectedDeadline;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();


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
      _requirementController.text.isEmpty) {
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
      deadline: _selectedDeadline!,
      category: _selectedCategory,
      subtasks: _generatedSubtasks,
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

Widget _buildChip(String label) {
  final bool isSelected = label == _selectedCategory;
  return GestureDetector(
    onTap: () {
      setState(() {
        // if you tap the already‑selected, revert to “기타”
        if (isSelected) {
          _selectedCategory = '기타';
        } else {
          _selectedCategory = label;
        }
      });
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: isSelected ? const Color(0xFFF2AC57) : const Color(0x331D1B20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: const [ BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0,2)) ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFFF5F5F5) : const Color(0xFF757575),
          fontSize: 14,
          height: 1,
        ),
      ),
    ),
  );
}

  Future<List<Subtask>> _generateSubtasksWithAI() async {
    // TODO: replace with your real AI call
    await Future.delayed(const Duration(seconds: 1));
    return [
      Subtask(title: '리서치 자료 수집', expectedDuration: Duration(hours: 3, minutes: 15)),
      Subtask(title: '초안 작성', expectedDuration: Duration(hours: 2 )),
      Subtask(title: '검토 및 수정', expectedDuration: Duration(hours: 1, minutes: 30)),
    ];
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // For phone devices, use 90% of width; else fixed width.
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;

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
                  // Clickable "X" at the top left to return to Dashboard.
                  Positioned(
                    right: 5,
                    top: 13.5,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF767E8C)),
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
                      '새 프로젝트 추가',
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
                    top: 100,
                    left: 0,
                    right: 0,
                    bottom: 135,
                    child: SingleChildScrollView(
                    child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                            // 1) 프로젝트 이름 + 설명 카드
                            ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 240, minHeight: 80),
                              child: Container(
                                width: double.infinity,
                                height: 140,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  shadows: const [
                                    BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0, 2))
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
                                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(color: Color(0x4CB1B1B1), thickness: 1),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _detailsController,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: '프로젝트 설명',
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
                                        maxLines: null,
                                        expands: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 2) 날짜 선택 박스
                            Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                shadows: const [
                                  BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0, 2))
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Color(0xFFC78E48)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _dateController.text.isEmpty ? 'YYYY / MM / DD' : _dateController.text,
                                      style: const TextStyle(color: Color(0xFFB3B3B3), fontSize: 16, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  InkWell(onTap: _selectDeadlineDate, child: const Icon(Icons.edit, size: 20)),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 3) 카테고리 태그 버튼들
                            SizedBox(
                              height: 56,
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(
                                  dragDevices: { PointerDeviceKind.touch, PointerDeviceKind.mouse },
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      for (var label in _categories) ...[
                                        _buildChip(label),
                                        const SizedBox(width: 10),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 4) 하위작업 요구사항
                            const Text('하위작업 요구사항', style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.w400)),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 80),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  shadows: const [
                                    BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0, 2))
                                  ],
                                ),
                                child: TextField(
                                  controller: _requirementController,
                                  maxLines: null,
                                  decoration: const InputDecoration.collapsed(
                                    hintText: '포함했으면 하는 하위작업 등',
                                    hintStyle: TextStyle(color: Color(0xFFB3B3B3), fontSize: 16, fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 5) AI 하위작업 생성하기 버튼 박스
                            const Text('하위작업', style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.w400)),

                            const SizedBox(height: 8),

                            // 6) Generated subtasks list
                        
                            if (_generatedSubtasks.isNotEmpty) 
    ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(vertical: 8),
      // show one extra row (the “add” row) only when there are tasks
      itemCount: _generatedSubtasks.length + 1,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final sub = _generatedSubtasks.removeAt(oldIndex);
          _generatedSubtasks.insert(newIndex, sub);
        });
      },
      itemBuilder: (context, index) {
        if (index < _generatedSubtasks.length) {
          final sub = _generatedSubtasks[index];
          return Padding(
            key: ValueKey(sub.title),
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                shadows: const [
                  BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0,2)),
                ],
              ),
              child: Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, size: 24, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(sub.title,
                             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                             maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: ShapeDecoration(
                            color: const Color(0x19BF622C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Text(
                            '${sub.expectedDuration.inHours}H ${sub.expectedDuration.inMinutes.remainder(60)}M',
                            style: const TextStyle(color: Color(0xFFBF622C), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 24), onPressed: () {
    final sub = _generatedSubtasks[index];
    final titleCtrl = TextEditingController(text: sub.title);
    final hoursCtrl = TextEditingController(text: sub.expectedDuration.inHours.toString());
    final minsCtrl  = TextEditingController(text: sub.expectedDuration.inMinutes.remainder(60).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('하위작업 편집'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hoursCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '시간 (H)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: minsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '분 (M)'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              setState(() {
                sub.title = titleCtrl.text.trim();
                final h = int.tryParse(hoursCtrl.text) ?? 0;
                final m = int.tryParse(minsCtrl.text) ?? 0;
                sub.expectedDuration = Duration(hours: h, minutes: m);
              });
              Navigator.pop(ctx);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  },),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 24), onPressed: () => setState(() => _generatedSubtasks.removeAt(index))),
                ],
              ),
            ),
          );
        }

        // only reached when index == _generatedSubtasks.length, i.e. “add” row,
        // and only if there is at least one task
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
                      _generatedSubtasks.add(Subtask(title: text, expectedDuration: Duration.zero));
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
                                          Icon(Icons.auto_awesome, color: Color(0xFFF2AC57)),
                                          SizedBox(width: 8),
                                          Opacity(opacity: 0.5, child: Text('AI로 하위작업 생성하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
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
                  ),
                 

                  // 프로젝트 저장하기 버튼 (새 스타일)
                  Positioned(
                    left: 50,
                    right: 50,
                    bottom: 75,
                    child: GestureDetector(
                      onTap: _onGenerateSubtaskPressed,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0x1E1D1B20),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: 0.38,
                              child: Text(
                                '프로젝트 저장하기',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

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
                              child: SizedBox(
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
                              child: SizedBox(
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
                                        color: Color(0xFF9AA5B6), // Changed to black
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
                                            color: const Color(0xFF9AA5B6), // Changed to darker color
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400, // Changed to bold
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
                              child: SizedBox(
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
                                        color: Color(0xFFBF622C), // Set color or remove if you need default
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
                                            color: const Color(0xFFBF622C),
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
                          // '캐릭터' button
                          Expanded(
                            child: SizedBox(
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
                                        color: Color(0xFF9AA5B6), // Set color or remove if you need default
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
                            child: SizedBox(
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
                                        color: Color(0xFF9AA5B6), // Set color or remove if you need default
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

