// lib/screens/add/add_page.dart

import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:domo/services/task_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';



class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  AddPageState createState() => AddPageState();
}



class AddPageState extends State<AddPage> {

Future<void> _showStyledDialog({
  required String title,
  required String message,
  String buttonText = '확인',
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black26,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC78E48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(buttonText, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

   int _listVersion = 0;
// …into real mutable fields:
  List<String> _categories = [];
  String _selectedCategory = '기타';
  List<Subtask> _generatedSubtasks = [];
  int? _projectId;          // <-- add this
  bool   _hasSaved = false;

  @override
  void initState() {
    super.initState();

    // 2) seed immediately from whatever is already in Task.allCategories
    _categories = List.from(Task.allCategories);
    // if that list had something, pick the first as default
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }

    // 3) now asynchronously re‑load from the server
    Task.loadCategories().then((_) {
      setState(() {
        _categories = List.from(Task.allCategories);
        // if our previously selected category no longer exists, pick a safe default:
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = _categories.isNotEmpty ? _categories.first : '기타';
        }
      });
    }).catchError((_) {
      // optional: swallow errors or show a snackbar
    });
  }

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
    if (_projectId != null && !_hasSaved) {
      // fire-and-forget, no UI blocking
      TaskService().deleteProject(_projectId!);
    }
    super.dispose();
  }

  Future<void> _selectDeadlineDate() async {
  DateTime selectedDate = _selectedDeadline ?? DateTime.now();
  DateTime focusedDay = selectedDate;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag‑handle
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),

                // calendar
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => isSameDay(day, selectedDate),
                  onDaySelected: (day, focus) {
                    setModalState(() {
                      selectedDate = day;
                      focusedDay = focus;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Color(0xFFC78E48), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFFF2AC57), shape: BoxShape.circle),
                  ),
                ),
                const SizedBox(height: 12),

                // confirm
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDeadline = selectedDate;
                      _dateController.text =
                        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2,'0')}-${selectedDate.day.toString().padLeft(2,'0')}';
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2AC57),
                    foregroundColor: Colors.white,  
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                    //minimumSize: const Size.fromHeight(48),
                    fixedSize: const Size(200, 48), 
                  ),
                  child: const Text(
                    '확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
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
  /*
  Future<List<Subtask>> _generateSubtasksWithAI() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      
      Subtask(
          id :1,
          order : 1,
          title: '리서치 자료 수집1',
          expectedDuration: const Duration(hours: 3, minutes: 15)),
      Subtask(id :2,
          order : 2,title: '초안 작성2', expectedDuration: const Duration(hours: 2)),
      Subtask(id :3,
          order : 3,
          title: '검토 및 수정3', expectedDuration: const Duration(hours: 1, minutes: 30)),
      
    ];
  }
  */
  Future<void> _onGenerateAI() async {
  // 1) Validate required fields
  if (_nameController.text.isEmpty ||
      _dateController.text.isEmpty ||
      _detailsController.text.isEmpty ||
      _requirementController.text.isEmpty) {
    await _showStyledDialog(
      title: '필수 항목 미입력',
      message: 'AI 생성을 진행하기 전에 모든 필드를 입력해 주세요.',
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // 2) Create the project on the backend
    final newTask = Task(
      id: 0, // server will assign
      name: _nameController.text,
      deadline: _selectedDeadline!,
      category: _selectedCategory,
      requirements: _detailsController.text,
      description: _requirementController.text,
      completed: false,
    );
    final pid = await TaskService().createTask(newTask);
    _projectId = pid;

    // 3) Generate subtasks via AI for that project
    final generated = await TaskService().generateSubtasksWithAI(pid);
    await TaskService().updateSubtasks(pid, generated);

    // 4) Close loader, update state
    Navigator.pop(context);
    setState(() {
      _generatedSubtasks = generated;
      _listVersion++;
    });

    // 5) Inform user
    await _showStyledDialog(
      title: 'AI 생성 완료',
      message: '프로젝트와 하위작업이 생성되었습니다.',
    );
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AI 생성 실패: $e')),
    );
  }
}


  Future<void> _onGenerateSubtaskPressed() async {
  // 1) Make sure we have an AI‐created project
  if (_projectId == null) {
    await _showStyledDialog(
      title: '프로젝트 없음',
      message: '먼저 AI 버튼으로 프로젝트를 생성해주세요.',
      buttonText: 'OK',
    );
    return;
  }

  // 2) Make sure we actually have generated subtasks
  if (_generatedSubtasks.isEmpty) {
    await _showStyledDialog(
      title: '하위작업 없음',
      message: '먼저 AI로 하위작업을 생성해주세요.',
      buttonText: 'OK',
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // 3) Push each subtask to the server for the existing project
    for (final sub in _generatedSubtasks) {
      await TaskService().createSubtasks(_projectId!, sub);
    }
    _hasSaved = true;
    Navigator.pop(context); // dismiss loader
    await _showStyledDialog(
      title: '저장 성공',
      message: '하위작업이 프로젝트에 저장되었습니다.',
    );
    Navigator.pushReplacementNamed(context, '/project');

  } catch (e) {
    Navigator.pop(context);
    await _showStyledDialog(
      title: '저장 실패',
      message: '에러: $e',
    );
  }
}

Future<void> _editSubtask(Subtask sub, int index) async {
  final titleCtrl = TextEditingController(text: sub.title);
  final hoursCtrl = TextEditingController(text: sub.expectedDuration.inHours.toString());
  final minutesCtrl = TextEditingController(
    text: sub.expectedDuration.inMinutes.remainder(60).toString(),
  );

  await showDialog(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadows: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '하위작업 수정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF2AC57),
            
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hoursCtrl,
                    decoration: InputDecoration(
                      labelText: '시간(시)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: minutesCtrl,
                    decoration: InputDecoration(
                      labelText: '분',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(color: Colors.grey[600]),
                    foregroundColor: Colors.black,
                  ),
                  child: Text('취소'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      sub.title = titleCtrl.text;
                      sub.expectedDuration = Duration(
                        hours: int.tryParse(hoursCtrl.text) ?? 0,
                        minutes: int.tryParse(minutesCtrl.text) ?? 0,
                      );
                      _generatedSubtasks[index] = sub;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2AC57),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('저장', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_projectId != null && !_hasSaved) {
            TaskService().deleteProject(_projectId!);
        }
        return true;
      },
      child: Scaffold(
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
                  top: 30,
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
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0x80000000),
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500,)
                              ),
                              const SizedBox(height: 8),
                              const Divider(color: Color(0x4CB1B1B1)),
                              const SizedBox(height: 8),
                              Expanded(
                                child: TextField(
                                  controller: _detailsController,
                                  decoration: const InputDecoration.collapsed(
                                      hintText: '프로젝트 설명',
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0x80000000),
                                      ),
                                    ),
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: _dateController.text.isEmpty
                                      ? Color(0x80000000)   // placeholder일 때만 반투명
                                      : Color(0xFF1E1E1E),  // 실제 날짜는 진한 색
                                  ),
                                ),
                              ),
                              InkWell(onTap: _selectDeadlineDate, child: const Icon(Icons.edit, size: 20)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

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

                        const SizedBox(height: 12),

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
                                hintText: '포함했으면 하는 하위작업 등',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0x80000000),
                                ),),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          '하위작업 ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 12),
                        // Generated subtasks

                        if (_generatedSubtasks.isNotEmpty) ...[
    ReorderableListView(
      key: ValueKey(_listVersion),
      buildDefaultDragHandles: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final max = _generatedSubtasks.length;
          if (newIndex > max) newIndex = max;
          if (newIndex > oldIndex) newIndex--;
          final moved = _generatedSubtasks.removeAt(oldIndex);
          _generatedSubtasks.insert(newIndex, moved);
          for (var i = 0; i < _generatedSubtasks.length; i++) {
            _generatedSubtasks[i].order = i + 1;
          }
        });
      },
      children: List.generate(_generatedSubtasks.length + 1, (i) {
        // ① “새 하위작업 추가” 버튼
        if (i == _generatedSubtasks.length) {
          return Container(
            key: const ValueKey('add-subtask'),
            margin: const EdgeInsets.only(bottom: 12),
            height: 75,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              shadows: const [
                BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0, 2))
              ],
            ),
            child: InkWell(
              onTap: () async {
                final titleCtrl = TextEditingController();
                final hoursCtrl = TextEditingController();
                final minsCtrl = TextEditingController();
                await showDialog(
                  context: context,
                  barrierColor: Colors.black26,
                  builder: (_) => Dialog(
                    insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        shadows: const [
                          BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0,4))
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '새 하위작업 추가',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF2AC57),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: titleCtrl,
                            decoration: InputDecoration(
                              labelText: '제목',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: hoursCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: '시간(시)',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: minsCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: '분',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(foregroundColor: Colors.black),
                                child: const Text('취소'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  final title = titleCtrl.text.trim();
                                  final h = int.tryParse(hoursCtrl.text) ?? 0;
                                  final m = int.tryParse(minsCtrl.text) ?? 0;
                                  if (title.isEmpty) return;
                                  setState(() {
                                    _generatedSubtasks.add(Subtask(
                                      id: _generatedSubtasks.length + 1,
                                      order: _generatedSubtasks.length + 1,
                                      title: title,
                                      expectedDuration: Duration(hours: h, minutes: m),
                                      tag: 'DEFAULT',
                                    ));
                                    _listVersion++;
                                  });
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF2AC57),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text('저장', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add, color: Color(0xFFF2AC57)),
                    SizedBox(width: 8),
                    Text(
                      '새 하위작업 추가',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFF2AC57)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ② 기존 생성된 하위작업 항목
        final sub = _generatedSubtasks[i];
        return Container(
          key: ValueKey(sub.id),
          margin: const EdgeInsets.only(bottom: 12),
          height: 75,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shadows: const [
              BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: i,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.drag_handle, size: 24),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: ShapeDecoration(
                        color: const Color(0x19BF622C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text(
                        '${sub.expectedDuration.inHours}H ${sub.expectedDuration.inMinutes.remainder(60)}M',
                        style: const TextStyle(
                          color: Color(0xFFBF622C),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 24),
                onPressed: () => _editSubtask(sub, i),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 24),
                onPressed: () => setState(() => _generatedSubtasks.removeAt(i)),
              ),
            ],
          ),
        );
      }),
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
                              height: 69,
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _onGenerateAI,
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
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                // Save button
                Positioned(
                  left: 50,
                  right: 50,
                  bottom: 80,
                  child: GestureDetector(
                    onTap: _onGenerateSubtaskPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC78E48),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '프로젝트 저장하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,    // ← fully white text
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
                      child: SizedBox(
                        height: 68,
                        child: BottomNavBar(activeIndex: 2),
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
