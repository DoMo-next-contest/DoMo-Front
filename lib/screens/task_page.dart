// lib/screens/task_page.dart

import 'dart:async';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:domo/models/task.dart';
import 'package:domo/utils/mobile_frame.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);
  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  late String taskName;
  late Task currentTask;
  bool _isEditing = false;

  final Map<Subtask, Timer?> _timers = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  late String selectedCategory;
  DateTime _focusedDay = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final passed = ModalRoute.of(context)?.settings.arguments as String?;
    taskName = passed ?? 'Unknown Task';
    currentTask = globalTaskList.firstWhere(
      (t) => t.name == taskName,
      orElse:
          () => Task(
            name: taskName,
            deadline: DateTime.now(),
            subtasks: [],
            category: '기타',
          ),
    );
    selectedCategory = currentTask.category;
    _nameController.text = currentTask.name;
    for (var sub in currentTask.subtasks) {
      _timers.putIfAbsent(sub, () => null);
    }
  }

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer?.cancel();
    }
    _nameController.dispose();
    _subtaskController.dispose();
    _categoryController.dispose();
    super.dispose();
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
    _timers[sub] = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  void _pauseSubtask(Subtask sub) {
    final t = _timers[sub];
    if (t != null) {
      t.cancel();
      _timers[sub] = null;
      sub.pause();
    }
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
              horizontal: 24,
              vertical: 80,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '카테고리 관리',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      shrinkWrap: true,
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
                            onPressed: () {
                              setState(() {
                                Task.allCategories.removeAt(idx);
                                if (selectedCategory == cat) {
                                  selectedCategory = Task.allCategories.first;
                                  currentTask.category = selectedCategory;
                                }
                              });
                              Navigator.pop(context);
                              _showCategoryPicker();
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
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            hintText: '새 카테고리 추가',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 28),
                        color: const Color(0xFFBF622C),
                        onPressed: () {
                          final newCat = _categoryController.text.trim();
                          if (newCat.isNotEmpty &&
                              !Task.allCategories.contains(newCat)) {
                            setState(() => Task.allCategories.add(newCat));
                            _categoryController.clear();
                            Navigator.pop(context);
                            _showCategoryPicker();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
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
              padding: const EdgeInsets.all(0),
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
                        color: Color(0xFFF2AC57),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFFBF622C),
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
                      backgroundColor: const Color(0xFFBF622C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(48),
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

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
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
                          Positioned(
                            right: 16,
                            top: 16,
                            child: IconButton(
                              icon: Icon(_isEditing ? Icons.check : Icons.edit),
                              onPressed:
                                  () =>
                                      setState(() => _isEditing = !_isEditing),
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
                      height: 32, // enough to fit your 24pt text
                      child:
                          _isEditing
                              ? TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  height: 1.12,
                                ),
                                onChanged: (v) => currentTask.name = v,
                              )
                              : Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currentTask.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1.12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF2AC57),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          currentTask.category,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  // deadline
                  Positioned(
                    top: 140,
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
                    top: 200,
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
                            buildDefaultDragHandles: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: currentTask.subtasks.length + 1,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                final max = currentTask.subtasks.length;
                                if (newIndex > max) newIndex = max;
                                if (oldIndex < max) {
                                  if (newIndex > oldIndex) newIndex -= 1;
                                  final moved = currentTask.subtasks.removeAt(
                                    oldIndex,
                                  );
                                  currentTask.subtasks.insert(newIndex, moved);
                                  currentTask.touch();
                                }
                              });
                            },
                            itemBuilder: (ctx, i) {
                              if (i < currentTask.subtasks.length) {
                                final sub = currentTask.subtasks[i];
                                final elapsed = sub.elapsed;
                                final isRunning = _timers[sub] != null;

                                return Padding(
                                  key: ValueKey(sub.title),
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    height: 75,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 13,
                                    ),
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
                                                    onChanged:
                                                        (c) => setState(() {
                                                          sub.isDone = c!;
                                                          currentTask.touch();
                                                        }),
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
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  decoration:
                                                      sub.isDone
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
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
                                                      _formatDuration(elapsed),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                            onPressed:
                                                () => currentTask.touch(),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                currentTask.subtasks.removeAt(
                                                  i,
                                                );
                                                currentTask.touch();
                                              });
                                            },
                                          ),
                                        ] else ...[
                                          IconButton(
                                            icon: Icon(
                                              isRunning
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                            ),
                                            onPressed:
                                                () => setState(
                                                  () =>
                                                      isRunning
                                                          ? _pauseSubtask(sub)
                                                          : _startSubtask(sub),
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }
                              // add-subtask row
                              return Padding(
                                key: const ValueKey('add-subtask'),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
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
                                        final text =
                                            _subtaskController.text.trim();
                                        if (text.isNotEmpty) {
                                          setState(() {
                                            currentTask.subtasks.add(
                                              Subtask(title: text),
                                            );
                                            _subtaskController.clear();
                                            currentTask.touch();
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

                  // delete/complete row
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 80,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final ok =
                                    await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: const Text('프로젝트 삭제'),
                                            content: const Text('정말 삭제하시겠습니까?'),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: const Text('취소'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                                child: const Text('삭제'),
                                              ),
                                            ],
                                          ),
                                    ) ??
                                    false;
                                if (ok) {
                                  setState(
                                    () => globalTaskList.remove(currentTask),
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side: const BorderSide(
                                  color: Color(0xFFC78E48),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                '프로젝트 삭제하기',
                                style: TextStyle(
                                  color: Color(0xFFC78E48),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => currentTask.touch(),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: const Color(0xFFC78E48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                '프로젝트 완료하기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
