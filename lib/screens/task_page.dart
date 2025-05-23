// lib/screens/task_page.dart

import 'dart:async';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:domo/models/task.dart';
import 'package:domo/utils/mobile_frame.dart';
import 'package:domo/services/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});
  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> with WidgetsBindingObserver {
  late String taskName;
  late Task currentTask;
  late Future<List<Subtask>> _subsFuture;
  bool _isLoading = true;
  String? _error;
  bool _isEditing = false;
  int _listVersion = 0;
  bool _isCompleting = false;
  bool _visible = true;
  Timer? _ticker;

  final Map<Subtask, Timer?> _timers = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  late String selectedCategory;
  final DateTime _focusedDay = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1) Grab & assign the passed Task exactly once
    final passed = ModalRoute.of(context)!.settings.arguments as Task;
    currentTask = passed;

    // 2) Pre‐fill your controllers and UI fields
    _nameController.text = currentTask.name;
    _descController.text = currentTask.description;
    selectedCategory = currentTask.category;
    TaskService().markProjectAsAccessed(currentTask.id);

    // 3) Fetch subtasks from your backend
    TaskService().getSubtasks(currentTask.id).then((subs) {
      setState(() {
        currentTask.subtasks = subs;
        _isLoading = false;
      });
      // now that currentTask.subtasks exists we restore from prefs:
      for (var sub in currentTask.subtasks) {
        _loadSubtaskState(sub);
      }
    });
  }

  void _reloadSubtasks() {
    setState(() {
      _subsFuture = TaskService().getSubtasks(currentTask.id);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTicker();
  }

  @override
  void dispose() {
    _stopTicker();
    WidgetsBinding.instance.removeObserver(this);
    // 2) save all at dispose
    for (var s in currentTask.subtasks) {
      _saveSubtaskState(s);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    _onVisibilityChange(resumed);
  }

  void _onVisibilityChange(bool visible) {
    _visible = visible;
    if (visible) {
      _startTicker();
      setState(() {}); // 복귀 즉시 갱신
    } else {
      _stopTicker();
      for (var s in currentTask.subtasks) {
        _saveSubtaskState(s);
      }
    }
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(Duration(seconds: 1), (_) {
      if (_visible) setState(() {});
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _startSubtask(Subtask sub) {
    // pause any other running
    _timers.forEach((other, timer) {
      if (other != sub && timer != null) {
        other.pause();
        timer.cancel();
        _timers[other] = null;
      }
    });
    sub.start();
  }

  void _pauseSubtask(Subtask sub) {
    sub.pause();
  }

  /// 서브태스크의 startMs/accumulatedMs 를 SharedPreferences 에 저장
  Future<void> _saveSubtaskState(Subtask s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sub_${s.id}_startMs', s.startMs ?? -1);
    await prefs.setInt('sub_${s.id}_accumMs', s.accumulatedMs);
  }

  /// SharedPreferences 에 저장된 startMs/accumulatedMs 를 불러와 복원
  Future<void> _loadSubtaskState(Subtask s) async {
    final prefs = await SharedPreferences.getInstance();
    final sm = prefs.getInt('sub_${s.id}_startMs') ?? -1;
    s.startMs = sm >= 0 ? sm : null;
    s.accumulatedMs = prefs.getInt('sub_${s.id}_accumMs') ?? 0;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  String _formatDuration(Duration d) {
    final h = _twoDigits(d.inHours);
    final m = _twoDigits(d.inMinutes.remainder(60));
    final s = _twoDigits(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  void _showCategoryPicker() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 80,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 405),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '카테고리 관리',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),

                    // Scrollable list
                    Expanded(
                      child: ListView.separated(
                        itemCount: Task.allCategories.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, idx) {
                          final cat = Task.allCategories[idx];
                          final isSel = cat == selectedCategory;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            leading:
                                isSel
                                    ? const Icon(
                                      Icons.check,
                                      color: Color(0xFFBF622C),
                                    )
                                    : const SizedBox(width: 24),
                            title: Text(
                              cat,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: isSel ? Colors.black : Colors.grey[700],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.grey[500],
                              onPressed: () async {
                                final rawIdx = Task.allCategories.indexOf(cat);
                                if (rawIdx < 0) return;

                                final toDelete = Task.rawList[rawIdx];

                                try {
                                  await TaskService().deleteProjectTag(
                                    toDelete.id,
                                  );

                                  setState(() {
                                    Task.rawList.removeAt(rawIdx);
                                    Task.allCategories.removeAt(rawIdx);
                                    if (selectedCategory == cat &&
                                        Task.allCategories.isNotEmpty) {
                                      selectedCategory =
                                          Task.allCategories.first;
                                      currentTask.category = selectedCategory;
                                    }
                                  });

                                  Navigator.pop(context);
                                  _showCategoryPicker();
                                } catch (e) {
                                  // 삭제 실패: 팝업 띄우기
                                  await showDialog<void>(
                                    context: context,
                                    barrierColor: Colors.black26,
                                    builder:
                                        (_) => Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                          insetPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 30,
                                                vertical: 200,
                                              ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 32,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  size: 48,
                                                  color: Color(0xFFC78E48),
                                                ),
                                                const SizedBox(height: 16),
                                                const Text(
                                                  '삭제할 수 없습니다',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                const Text(
                                                  '해당 태그를 사용하는 프로젝트가 존재합니다.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFFC78E48,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 14,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      '확인',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  );
                                }
                              },
                            ),
                            onTap: () {
                              setState(() {
                                selectedCategory = cat;
                                currentTask.category = cat;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),

                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // “카테고리 추가” button
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          final newCat = await _showAddCategoryDialog();
                          if (newCat != null) {
                            setState(() => _isLoading = true);
                            try {
                              await TaskService().createProjectTag(newCat);
                              Task.allCategories.add(newCat);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('카테고리 추가 실패: $e')),
                              );
                              return;
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                            Navigator.pop(context);
                            _showCategoryPicker();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF2AC57),
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                '카테고리 추가',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<String?> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    String? newCategory;

    await showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 200,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '새 카테고리 추가',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '카테고리 이름',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFB1B1B1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: '입력하세요',
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFB1B1B1)),
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final t = controller.text.trim();
                          if (t.isNotEmpty) {
                            newCategory = t;
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('추가'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2AC57),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
    );

    return newCategory;
  }

  /// Trendy calendar bottom sheet
  Future<void> _showCalendarPicker() async {
    DateTime selectedDate = currentTask.deadline;
    DateTime focusedDay = currentTask.deadline;

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
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TableCalendar(
                    firstDay: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
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
                        color: Color(0xFFC78E48),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFFF2AC57),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentTask.deadline = selectedDate;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2AC57),
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      //minimumSize: const Size.fromHeight(48),
                      fixedSize: const Size(200, 48),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

  Future<bool> _editSubtask(Subtask sub) async {
    final titleCtrl = TextEditingController(text: sub.title);
    final hoursCtrl = TextEditingController(
      text: sub.actualDuration.inHours.toString(),
    );
    final minutesCtrl = TextEditingController(
      text: sub.actualDuration.inMinutes.remainder(60).toString(),
    );

    final saved = await showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 200,
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x22000000),
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
                      color: Color(0xFFF2AC57),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 하위작업 이름
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '하위작업 이름',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: '제목',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 실제 소요시간
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '실제 소요시간',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '시간(시)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: hoursCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration.collapsed(
                                      hintText: '',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '분',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: minutesCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration.collapsed(
                                      hintText: '',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            sub.title = titleCtrl.text;
                            sub.actualDuration = Duration(
                              hours: int.tryParse(hoursCtrl.text) ?? 0,
                              minutes: int.tryParse(minutesCtrl.text) ?? 0,
                            );
                            currentTask.touch();
                          });
                          Navigator.pop(context);


                          try {
                            await TaskService().updateSubtask(sub.id, {
                              'subTaskName': sub.title,
                              'subTaskExpectedTime':
                                  sub.expectedDuration.inMinutes,
                              'subTaskTag': sub.tag,
                              'subTaskOrder': sub.order,
                            });
                            await TaskService().updateSubtaskActualTime(
                              sub.id,
                              sub.actualDuration.inMinutes,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('하위작업이 저장되었습니다')),
                            );
                            
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('저장 실패: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2AC57),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          '저장',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );

    setState(() {}); // refresh list immediately
    return saved == true;
  }
Future<void> _addSubtaskDialog() async {
  final titleCtrl = TextEditingController();
  final hoursCtrl = TextEditingController();
  final minsCtrl = TextEditingController();

  // 1) Show dialog and await whether the user tapped “저장” (true) or “취소” (false)
  final didSave = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black26,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '새 하위작업 추가',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // 제목 섹션
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '하위작업 이름',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            // 예상 소요시간 섹션
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '예상 소요시간',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hoursCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '시간 (H)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: minsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '분 (M)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    Navigator.pop(context, true);
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
  ) ?? false; // default to false if dialog dismissed

  // 2) If the user tapped “저장,” update state and send to server
  if (didSave) {
    final title = titleCtrl.text.trim();
    final h = int.tryParse(hoursCtrl.text) ?? 0;
    final m = int.tryParse(minsCtrl.text) ?? 0;
    final newSub = Subtask(
      id: 0,
      order: currentTask.subtasks.length + 1,
      title: title,
      expectedDuration: Duration(hours: h, minutes: m),
      tag: 'DEFAULT',
    );

    setState(() {
      currentTask.subtasks.add(newSub);
      currentTask.touch();
      _listVersion++;
    });
    _reloadSubtasks();

    try {
      await TaskService().createSubtasks(currentTask.id, newSub);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('하위작업이 추가되었습니다')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }
  
}



  bool _areAllSubtasksComplete(Task task) {
    return task.subtasks.every((s) => s.isDone == true); // ✅ CORRECT
  }

  @override
  Widget build(BuildContext context) {
    
    return VisibilityDetector(
      key: const Key('task-page-visibility'),
      onVisibilityChanged: (VisibilityInfo info) {
        // 화면에 안 보이면 visibleFraction == 0
        final isVisible = info.visibleFraction > 0;
        _onVisibilityChange(isVisible);
      },
      child: MobileFrame(
        child: Scaffold(
          backgroundColor: Colors.transparent, // show frame bg
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                child: Stack(
                  children: [
                    // top bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: 72,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 16,
                              top: 16,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                onPressed:
                                    () => Navigator.pushReplacementNamed(
                                      context,
                                      '/project',
                                    ),
                              ),
                            ),
                            if (!currentTask.completed)
                              Positioned(
                                right: 16,
                                top: 16,
                                child: IconButton(
                                  icon: Icon(
                                    _isEditing ? Icons.check : Icons.edit,
                                  ),
                                  onPressed: () async {
                                    if (_isEditing) {
                                      // 1) Sync any name/desc edits you did via controllers:
                                      currentTask.name = _nameController.text;
                                      currentTask.description =
                                          _descController.text;

                                      // 2) Send the *entire* subtask list back:
                                      try {
                                        await TaskService().updateSubtasks(
                                          currentTask.id,
                                          currentTask.subtasks,
                                        );
                                        await TaskService().updateProject(
                                          currentTask,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('저장되었습니다'),
                                          ),
                                        );
                                        // 3) Refresh from server (optional but safer):
                                        final fresh = await TaskService()
                                            .getSubtasks(currentTask.id);
                                        setState(
                                          () => currentTask.subtasks = fresh,
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('저장 실패: $e')),
                                        );
                                      }
                                    }
                                    // 4) Finally, toggle edit mode
                                    setState(() => _isEditing = !_isEditing);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Title & category pill, fixed size & position for both states
                    Positioned(
                      top: 80,
                      left: 20,
                      right: 90, // leave room for the pill on the right
                      child: SizedBox(
                        height: 32,
                        child: TextField(
                          controller: _nameController,
                          enabled: _isEditing,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: _isEditing ? null : '프로젝트 이름',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            // when not editing, show it as plain text style
                            hintStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.12,
                              color: Colors.black,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.12,
                            color: _isEditing ? Colors.black : Colors.black,
                          ),
                          onChanged: (v) => currentTask.name = v,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      right: 20,
                      child: InkWell(
                        onTap: _isEditing ? _showCategoryPicker : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF2AC57),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentTask.category,
                                style: const TextStyle(color: Colors.white),
                              ),
                              if (_isEditing) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 125,
                      left: 20,
                      right: 80,
                      bottom: 695,  // leave room for your calendar below
                      child: SingleChildScrollView(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isEditing)
                              TextField(
                                controller: _descController,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                  hintText: '설명을 입력하세요',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF767E8C),
                                  fontSize: 16,
                                  height: 1.25,
                                ),
                                onChanged: (v) => currentTask.description = v,
                              )
                            else
                              Text(
                                // show placeholder if empty
                                currentTask.description.isEmpty
                                  ? '설명을 입력하세요'
                                  : currentTask.description,
                                softWrap: true,
                                style: TextStyle(
                                  color: currentTask.description.isEmpty
                                    ? Colors.grey    // placeholder color
                                    : const Color(0xFF767E8C),
                                  fontSize: 12,
                                  height: 1.5,
                                  fontStyle: currentTask.description.isEmpty
                                    ? FontStyle.normal
                                    : FontStyle.normal,
                                ),
                              ),

                          
                          ],
                        ),
                      ),
                    ),

                    // deadline
                    Positioned(
                      top: 175,
                      left: 16,
                      right: 16,
                      child: InkWell(
                        onTap: _isEditing ? _showCalendarPicker : null,
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
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
                              const Icon(
                                Icons.calendar_today,
                                color: Color(0xFFC78E48),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${currentTask.deadline.year.toString().padLeft(4, '0')}'
                                ' / ${currentTask.deadline.month.toString().padLeft(2, '0')}'
                                ' / ${currentTask.deadline.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // subtasks
                    Positioned(
                      top: 230,
                      left: 0,
                      right: 0,
                      bottom: 135,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              '하위작업',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ReorderableListView.builder(
                              key: ValueKey(_listVersion),
                              buildDefaultDragHandles: false,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: currentTask.subtasks.length + 1,
                              onReorder: (oldIndex, newIndex) async {
                                setState(() {
                                  final max = currentTask.subtasks.length;
                                  if (newIndex > max) newIndex = max;
                                  if (oldIndex < max) {
                                    if (newIndex > oldIndex) newIndex -= 1;
                                    final moved = currentTask.subtasks.removeAt(
                                      oldIndex,
                                    );
                                    currentTask.subtasks.insert(
                                      newIndex,
                                      moved,
                                    );
                                  }
                                  // 1) renumber the 'order' field for every subtask
                                  for (
                                    var i = 0;
                                    i < currentTask.subtasks.length;
                                    i++
                                  ) {
                                    currentTask.subtasks[i].order = i + 1;
                                  }
                                  currentTask.touch();
                                });
                              },
                              itemBuilder: (ctx, i) {
                                if (i < currentTask.subtasks.length) {
                                  final sub = currentTask.subtasks[i];
                                  final elapsed = sub.actualDuration;
                                  final isRunning = sub.startMs != null;

                                  // instead of just using sub.elapsedMs:
                                  final display = Duration(
                                    milliseconds: sub.actualDuration.inMilliseconds + sub.elapsedMs,
                                  );
                                  return Padding(
                                    key: ValueKey(sub.id),
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      height: 75,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                                          // fixed 40px slot
                                          SizedBox(
                                            width: 40,
                                            child:
                                                _isEditing
                                                    ? ReorderableDragStartListener(
                                                      index: i,
                                                      child: const Icon(
                                                        Icons.drag_handle,
                                                      ),
                                                    )
                                                    : Checkbox(
                                                      value: sub.isDone,
                                                      onChanged: (
                                                        checked,
                                                      ) async {
                                                        final newValue =
                                                            checked!;
                                                        setState(() {
                                                          sub.isDone = newValue;
                                                          currentTask.touch();
                                                        });

                                                        try {
                                                          if (newValue) {
                                                            await TaskService()
                                                                .setSubtaskDone(
                                                                  sub.id,
                                                                );
                                                          } else {
                                                            await TaskService()
                                                                .setSubtaskUndone(
                                                                  sub.id,
                                                                );
                                                          }

                                                          // ** New: compute and push overall progress **

                                                          final doneCount =
                                                              currentTask
                                                                  .subtasks
                                                                  .where(
                                                                    (s) =>
                                                                        s.isDone,
                                                                  )
                                                                  .length;
                                                          final total =
                                                              currentTask
                                                                  .subtasks
                                                                  .length;
                                                          final rate =
                                                              total == 0
                                                                  ? 0.0
                                                                  : doneCount /
                                                                      total;

                                                          await TaskService()
                                                              .updateProgressRate(
                                                                currentTask.id,
                                                                rate,
                                                              );
                                                          //await TaskService().updateProgressRate(currentTask.id, progress);
                                                        } catch (e) {
                                                          // roll back on failure
                                                          setState(() {
                                                            sub.isDone =
                                                                !newValue;
                                                          });
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                '상태 업데이트 실패: $e',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                          ),
                                          const SizedBox(width: 16),
                                          // title + durations
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sub.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    decoration:
                                                        sub.isDone
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 4,
                                                          ),
                                                      decoration: ShapeDecoration(
                                                        color: const Color(
                                                          0x19BF622C,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '${sub.expectedDuration.inHours}H '
                                                        '${sub.expectedDuration.inMinutes.remainder(60)}M',
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFFBF622C,
                                                          ),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 4,
                                                          ),
                                                      decoration: ShapeDecoration(
                                                        color: const Color(
                                                          0x19BF622C,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        _formatDuration(display),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: isRunning 
                                                              ? Colors.black     // 타이머 작동 중일 때
                                                              : Colors.grey[600] // 타이머 멈췄을 때
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // trailing buttons
                                          if (_isEditing) ...[
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              onPressed: () async {
                                                final updated = await _editSubtask(sub);
                                                if (updated) {
                                                  setState(() {}); // Rebuilds the task/subtask list
                                                }
                                                _reloadSubtasks(); // ← updates the Future and triggers a rebuild
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () async {
                                                // 1) grab & remove locally
                                                final removed =
                                                    currentTask.subtasks[i];
                                                setState(() {
                                                  currentTask.subtasks.removeAt(
                                                    i,
                                                  );
                                                  // re‑index order fields
                                                  for (
                                                    var j = 0;
                                                    j <
                                                        currentTask
                                                            .subtasks
                                                            .length;
                                                    j++
                                                  ) {
                                                    currentTask
                                                        .subtasks[j]
                                                        .order = j + 1;
                                                  }
                                                });

                                                try {
                                                  // 2) delete on server
                                                  await TaskService()
                                                      .deleteSubtask(
                                                        removed.id,
                                                      );
                                                  // 3) push updated ordering back to server
                                                  await TaskService()
                                                      .updateSubtasks(
                                                        currentTask.id,
                                                        currentTask.subtasks,
                                                      );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        '하위작업이 삭제되었습니다',
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  // 4) on failure, revert locally
                                                  setState(() {
                                                    currentTask.subtasks.insert(
                                                      i,
                                                      removed,
                                                    );
                                                    for (
                                                      var j = 0;
                                                      j <
                                                          currentTask
                                                              .subtasks
                                                              .length;
                                                      j++
                                                    ) {
                                                      currentTask
                                                          .subtasks[j]
                                                          .order = j + 1;
                                                    }
                                                  });
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '삭제 실패: $e',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ] else ...[
                                            sub.isDone
                                              // 1) If it’s done, show the play icon in grey and disable taps:
                                              ? IconButton(
                                                  icon: const Icon(Icons.play_arrow),
                                                  color: Colors.grey[400],
                                                  onPressed: null,
                                                )
                                              // 2) Otherwise show your normal start/pause control:
                                              : IconButton(
  icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
  onPressed: () async {
    if (isRunning) {
      // — Pause & persist the tapped one (same as before) —
      sub.pause();
      final sessionMs = sub.accumulatedMs;
      final totalDur  = sub.actualDuration + Duration(milliseconds: sessionMs);
      final totalMins = (totalDur.inSeconds + 59) ~/ 60;

      try {
        await TaskService().updateSubtaskActualTime(sub.id, totalMins);
        setState(() {
          sub.actualDuration = Duration(minutes: totalMins);
          sub.accumulatedMs   = 0;
          sub.startMs         = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('실제 시간 업데이트 실패: $e')),
        );
      }
    } else {
      // — Pause & persist *all* the others first —
      for (final other in currentTask.subtasks) {
        if (other != sub && other.startMs != null) {
          // locally pause
          other.pause();

          // compute their total
          final oTotalMs   = other.accumulatedMs;
          final oTotalDur  = other.actualDuration + Duration(milliseconds: oTotalMs);
          final oTotalMins = (oTotalDur.inSeconds + 59) ~/ 60;

          try {
            await TaskService().updateSubtaskActualTime(other.id, oTotalMins);
            setState(() {
              other.actualDuration = Duration(minutes: oTotalMins);
              other.accumulatedMs   = 0;
              other.startMs         = null;
            });
          } catch (e) {
            // you might batch errors or show one per‐failure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Subtask ${other.id} 업데이트 실패: $e')),
            );
          }

          // cancel its UI timer
          _timers[other]?.cancel();
          _timers[other] = null;
        }
      }

      // — Now start the tapped one —
      sub.start();
      _timers[sub]?.cancel();
      _timers[sub] = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );

      setState(() {}); // swap play→pause icon
    }
  },
),



                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  key: const ValueKey('add-subtask'),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _addSubtaskDialog(),
                                    child: Container(
                                      height: 75,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 13,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.add,
                                            color: Color(0xFFBF622C),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '하위작업 추가',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFBF622C),
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
                        ],
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 80,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            // 프로젝트 삭제하기 (custom dialog + API)
                            Expanded(
                              child: GestureDetector(
                                onTap:
                                    () => showDialog<bool>(
                                      context: context,
                                      barrierColor: Colors.black26,
                                      builder:
                                          (_) => Dialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            insetPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 30,
                                                  vertical: 200,
                                                ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    '프로젝트 삭제',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  const Text(
                                                    '이 프로젝트를 정말 삭제하시겠습니까?',
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      OutlinedButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        style: OutlinedButton.styleFrom(
                                                          side: BorderSide(
                                                            color:
                                                                Colors
                                                                    .grey[400]!,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        child: const Text('취소', style: TextStyle(color: Colors.black)),
                                                        
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          );
                                                          await TaskService()
                                                              .deleteProject(
                                                                currentTask.id,
                                                              );
                                                          Navigator.pushReplacementNamed(
                                                            context,
                                                            '/project',
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                0xFFC78E48,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          '삭제',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ),
                                child: Container(
                                  height: 38,
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
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '프로젝트 삭제하기',
                                    style: TextStyle(
                                      color: Color(0xFFC78E48),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // 프로젝트 완료하기
                            // Inside your Row of buttons:
                            Expanded(
                              child: StatefulBuilder(
                                builder: (ctx, setLocalState) {
                                  return GestureDetector(
                                    onTap:
                                        _isCompleting
                                            ? null
                                            : () async {
                                              if (currentTask.completed) {
                                                await showDialog<void>(
                                                  context: context,
                                                  barrierColor: Colors.black26,
                                                  builder:
                                                      (_) => Dialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        insetPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 30,
                                                              vertical: 200,
                                                            ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 24,
                                                                vertical: 32,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .info_outline,
                                                                size: 48,
                                                                color: Color(
                                                                  0xFFC78E48,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 16,
                                                              ),
                                                              const Text(
                                                                '이미 완료된 프로젝트입니다',
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              const Text(
                                                                '이 프로젝트는 이미 완료되었습니다.\n다시 완료할 수 없습니다.',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 24,
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                child: ElevatedButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                      ),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        Color(
                                                                          0xFFC78E48,
                                                                        ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              14,
                                                                        ),
                                                                  ),
                                                                  child: const Text(
                                                                    '확인',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                );
                                                return;
                                              }
                                              if (!_areAllSubtasksComplete(
                                                currentTask,
                                              )) {
                                                await showDialog<void>(
                                                  context: context,
                                                  barrierColor: Colors.black26,
                                                  builder:
                                                      (_) => Dialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        insetPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 30,
                                                              vertical: 200,
                                                            ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 24,
                                                                vertical: 32,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .warning_amber_rounded,
                                                                size: 48,
                                                                color: Color(
                                                                  0xFFC78E48,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 16,
                                                              ),
                                                              const Text(
                                                                '하위작업 미완료',
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              const Text(
                                                                '모든 하위작업을 완료해야\n프로젝트를 마칠 수 있습니다.',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 24,
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                child: ElevatedButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                      ),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        const Color(
                                                                          0xFFC78E48,
                                                                        ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              14,
                                                                        ),
                                                                  ),
                                                                  child: const Text(
                                                                    '확인',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                );
                                                return;
                                              }

                                              // 1) 확인 다이얼로그 띄우기
                                              final confirm = await showDialog<
                                                bool
                                              >(
                                                context: context,
                                                barrierColor: Colors.black26,
                                                builder:
                                                    (_) => Dialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      insetPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 200,
                                                          ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              16,
                                                            ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Text(
                                                              '프로젝트 완료',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 12,
                                                            ),
                                                            const Text(
                                                              '이 프로젝트를 정말 완료하시겠습니까?',
                                                            ),
                                                            const SizedBox(
                                                              height: 16,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                OutlinedButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                        false,
                                                                      ),
                                                                  style: OutlinedButton.styleFrom(
                                                                    side: BorderSide(
                                                                      color:
                                                                          Colors
                                                                              .grey[400]!,
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Text(
                                                                        '취소', style: TextStyle(color: Colors.black)
                                                                      ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                        true,
                                                                      ),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        const Color(
                                                                          0xFFC78E48,
                                                                        ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  child: const Text(
                                                                    '확인',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                              );

                                              if (confirm != true) return;

                                              // 2) API 호출 & 로딩 처리
                                              setLocalState(
                                                () => _isCompleting = true,
                                              );
                                              try {
                                                // (선택) predictLevel 에러 무시
                                                try {
                                                  await TaskService()
                                                      .predictLevel(
                                                        currentTask.id,
                                                      );
                                                  debugPrint(
                                                    'predictLevel succeeded',
                                                  );
                                                } catch (_) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '레벨 예측 실패:',
                                                      ),
                                                    ),
                                                  );
                                                }

                                                try {
                                                  await TaskService()
                                                      .expectedTime(
                                                        currentTask.id,
                                                      );
                                                  debugPrint(
                                                    'predictLevel succeeded',
                                                  );
                                                } catch (_) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '레벨 예측 실패1:',
                                                      ),
                                                    ),
                                                  );
                                                }

                                                final result =
                                                    await TaskService()
                                                        .completeProject(
                                                          currentTask.id,
                                                        );

                                                final message =
                                                    result['message']
                                                        as String? ??
                                                    '완료 성공';
                                                final coin =
                                                    result['coin'] as int ?? 0;

                                                // 3) 결과 다이얼로그
                                                await showDialog<void>(
                                                  context: context,
                                                  barrierColor: Colors.black26,
                                                  builder:
                                                      (_) => Dialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                        ),
                                                        insetPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 30,
                                                              vertical: 200,
                                                            ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 24,
                                                                vertical: 32,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              // 1) Top icon
                                                              Icon(
                                                                Icons
                                                                    .check_circle_outline,
                                                                size: 64,
                                                                color: Color(
                                                                  0xFFC78E48,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 16,
                                                              ),

                                                              // 2) Message
                                                              Text(
                                                                message,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: const TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),

                                                              // 3) Coin count
                                                              Text(
                                                                '획득 코인: $coin',
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 24,
                                                              ),

                                                              // 4) Full-width confirm button
                                                              SizedBox(
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                child: ElevatedButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                      ),
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        const Color(
                                                                          0xFFC78E48,
                                                                        ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              14,
                                                                        ),
                                                                    elevation:
                                                                        8,
                                                                  ),
                                                                  child: const Text(
                                                                    '확인',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                );

                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  '/project',
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('오류 발생: $e'),
                                                  ),
                                                );
                                              } finally {
                                                setLocalState(
                                                  () => _isCompleting = false,
                                                );
                                              }
                                            },
                                    child: Container(
                                      height: 38,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFC78E48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child:
                                          _isCompleting
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                              : const Text(
                                                '프로젝트 완료하기',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // bottom nav
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SizedBox(
                        height: 68,
                        child: _BottomNavBar(activeIndex: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int activeIndex;
  const _BottomNavBar({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home,
      Icons.format_list_bulleted,
      Icons.control_point,
      Icons.pets,
      Icons.person_outline,
    ];
    const labels = ['홈', '프로젝트', '추가', '캐릭터', '프로필'];
    const routes = ['/dashboard', '/project', '/add', '/decor', '/profile'];

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: List.generate(5, (i) {
          final color =
              i == activeIndex
                  ? const Color(0xFFBF622C)
                  : const Color(0xFF9AA5B6);
          final weight = i == activeIndex ? FontWeight.w600 : FontWeight.w400;
          return Expanded(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, routes[i]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icons[i], color: color, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: weight,
                      color: color,
                      height: 1.08,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
