// lib/screens/task_page.dart

import 'dart:async';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:domo/models/task.dart';
import 'package:domo/utils/mobile_frame.dart';
import 'package:domo/services/task_service.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);
  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  late String taskName;
  late Task currentTask;
  late Future<List<Subtask>> _subsFuture;
  bool _isLoading = true;
  String? _error;
  bool _isEditing = false;
  int _listVersion = 0;
  bool _isCompleting = false;

  final Map<Subtask, Timer?> _timers = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  late String selectedCategory;
  DateTime _focusedDay = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // read the Task object directly
    final passed = ModalRoute.of(context)?.settings.arguments as Task?;
    if (passed == null) {
      throw Exception('No Task passed to TaskPage');
    }
    currentTask = passed;

    _subsFuture = TaskService().getSubtasks(currentTask.id);

    // now you can read both id and name:
    debugPrint('currentTask.id = ${currentTask.id}');
    debugPrint('currentTask.name = ${currentTask.name}');

    selectedCategory = currentTask.category;
    _nameController.text = currentTask.name;
    _descController.text = currentTask.description;
    TaskService().getSubtasks(currentTask.id).then((subs) {
      setState(() {
        currentTask.subtasks = subs;
        for (var s in subs) {
          _timers.putIfAbsent(s, () => null);
        }
        _isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    });
  }

  void _reloadSubtasks() {
    setState(() {
      _subsFuture = TaskService().getSubtasks(currentTask.id);
    });
  }

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer?.cancel();
    }
    _nameController.dispose();
    _subtaskController.dispose();
    _categoryController.dispose();
    _descController.dispose();
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
                        onPressed: () async {
                          final newCat = _categoryController.text.trim();
                          if (newCat.isEmpty || Task.allCategories.contains(newCat)) return;

                          Navigator.pop(context); // close dialog immediately

                          try {
                            // 1) send to server
                            await TaskService().createProjectTag(newCat);

                            // 2) on success, update local list
                            setState(() {
                              Task.allCategories.add(newCat);
                            });
                            _categoryController.clear();

                            // 3) reopen the picker so the user sees it added
                            _showCategoryPicker();
                          } catch (e) {
                            // if the API call failed, show an error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('카테고리 생성에 실패했습니다: $e')),
                            );
                            // optionally reopen the dialog so they can retry
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
                        color: const Color(0xFFF2AC57),
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

  Future<void> _editSubtask(Subtask sub) async {
  final titleCtrl = TextEditingController(text: sub.title);
  final timeCtrl = TextEditingController(text: _formatDuration(sub.actualDuration));

  await showDialog(
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
            Text('하위작업 수정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: '제목', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              decoration: InputDecoration(labelText: '실제 시간 (HH:MM:SS)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 1) apply local edits
                setState(() {
                  sub.title = titleCtrl.text;
                  final parts = timeCtrl.text.split(':').map(int.parse).toList();
                  if (parts.length == 3) {
                    sub.actualDuration = Duration(
                      hours: parts[0], minutes: parts[1], seconds: parts[2]);
                  }
                  currentTask.touch();
                });
                Navigator.pop(context);
                

                // 2) send to server
                try {
                  await TaskService().updateSubtask(sub.id, {
                    'subTaskName': sub.title,
                    'subTaskExpectedTime': sub.expectedDuration.inMinutes,
                    'subTaskTag': sub.tag,
                    'subTaskOrder':        sub.order,
                  });
                  await TaskService().updateSubtaskActualTime(sub.id, sub.elapsed.inMinutes);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('하위작업이 저장되었습니다')),
                  );
                } catch (e) {
                  // revert on failure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('저장 실패: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2AC57),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                fixedSize: const Size(200, 48),
              ),
              child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _addSubtaskDialog() async {
  final titleCtrl = TextEditingController();
  final hoursCtrl = TextEditingController();
  final minsCtrl  = TextEditingController();

  await showDialog(
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
            Text('새 하위작업 추가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // 제목 입력
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            // 예상 시간 입력
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
            const SizedBox(height: 16),

            // 확인 버튼
            ElevatedButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final h = int.tryParse(hoursCtrl.text) ?? 0;
                final m = int.tryParse(minsCtrl.text) ?? 0;
                if (title.isEmpty) return;

                final newSub = Subtask(
                  id:    0,
                  order: currentTask.subtasks.length + 1,
                  title: title,
                  expectedDuration: Duration(hours: h, minutes: m),
                  tag:   'DOCUMENTATION',
                );

                Navigator.pop(context);
                // 1) Optimistically insert locally
                setState(() {
                  currentTask.subtasks.add(newSub);
                  currentTask.touch();
                  _listVersion++; 
                });
                

                // 2) Send to server
                try {
                  await TaskService().createSubtasks(currentTask.id, newSub);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('하위작업이 추가되었습니다')),
                  );
                  /*
                  Navigator.pushReplacementNamed(
                    context,
                    '/task',
                    arguments: currentTask,
                  );
                  */
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('저장 실패: $e')),
                  );
                }
              },
              

              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, 
                backgroundColor: const Color(0xFFF2AC57),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                fixedSize: const Size(200, 48),
              ),
              child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    ),
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
    onPressed: () async {
      if (_isEditing) {
        // 1) Sync any name/desc edits you did via controllers:
        currentTask.name = _nameController.text;
        currentTask.description = _descController.text;

        // 2) Send the *entire* subtask list back:
        try {
          await TaskService().updateSubtasks(currentTask.id, currentTask.subtasks);
          await TaskService().updateProject(currentTask);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('저장되었습니다')),
          );
          // 3) Refresh from server (optional but safer):
          final fresh = await TaskService().getSubtasks(currentTask.id);
          setState(() => currentTask.subtasks = fresh);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
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

                  Positioned(
  top: 120,   // adjust as needed
  left: 20,
  right: 20,
  child: SizedBox(
    height: 32,   // same height as your title field
    child: _isEditing
      ? TextField(
          controller: _descController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintText: '설명이 없습니다',
          ),
          style: const TextStyle(
            color: Color(0xFF767E8C),
            fontSize: 12,
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w400,
            height: 1.25,
          ),
          onChanged: (v) => currentTask.description = v,
        )
      : Align(
          alignment: Alignment.centerLeft,
          child: Text(
            currentTask.description.isEmpty
              ? '설명이 없습니다'
              : currentTask.description,
            style: const TextStyle(
              color: Color(0xFF767E8C),
              fontSize: 12,
              fontFamily: 'Barlow',
              fontWeight: FontWeight.w400,
              height: 1.25,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
  ),
),


                  // deadline
                  Positioned(
                    top: 160,
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
                    top: 220,
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
                                  final moved = currentTask.subtasks.removeAt(oldIndex);
                                  currentTask.subtasks.insert(newIndex, moved);
                                }
                                // 1) renumber the 'order' field for every subtask
                                for (var i = 0; i < currentTask.subtasks.length; i++) {
                                  currentTask.subtasks[i].order = i + 1;
                                }
                                currentTask.touch();
                              });},
                            itemBuilder: (ctx, i) {
                              if (i < currentTask.subtasks.length) {
                                final sub = currentTask.subtasks[i];
                                final elapsed = sub.actualDuration;
                                final isRunning = _timers[sub] != null; 

                                final display = isRunning ? sub.elapsed : sub.actualDuration;

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
                                          child: _isEditing
                                              ? ReorderableDragStartListener(
                                                  index: i,
                                                  child: const Icon(Icons.drag_handle),
                                                )
                                              : Checkbox(
                                                  value: sub.isDone,
                                                  onChanged: (checked) async {
                                                    final newValue = checked!;
                                                    // 1) optimistic update
                                                    setState(() {
                                                      sub.isDone = newValue;
                                                      currentTask.touch();
                                                    });
                                                    // 2) send to server
                                                    try {
                                                      if (newValue) {
                                                        // mark done
                                                        await TaskService().setSubtaskDone(sub.id);
                                                      } else {
                                                        // mark undone
                                                        await TaskService().setSubtaskUndone(sub.id);
                                                      }
                                                    } catch (e) {
                                                      // 3) revert on failure
                                                      setState(() {
                                                        sub.isDone = !newValue;
                                                      });
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('상태 업데이트 실패: $e')),
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
                                                      _formatDuration(display),
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
                                                () => _editSubtask(sub),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () async {
                                              // 1) grab & remove locally
                                              final removed = currentTask.subtasks[i];
                                              setState(() {
                                                currentTask.subtasks.removeAt(i);
                                                // re‑index order fields
                                                for (var j = 0; j < currentTask.subtasks.length; j++) {
                                                  currentTask.subtasks[j].order = j + 1;
                                                }
                                              });

                                              try {
                                                // 2) delete on server
                                                await TaskService().deleteSubtask(removed.id);
                                                // 3) push updated ordering back to server
                                                await TaskService().updateSubtasks(
                                                  currentTask.id,
                                                  currentTask.subtasks,
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('하위작업이 삭제되었습니다')),
                                                );
                                              } catch (e) {
                                                // 4) on failure, revert locally
                                                setState(() {
                                                  currentTask.subtasks.insert(i, removed);
                                                  for (var j = 0; j < currentTask.subtasks.length; j++) {
                                                    currentTask.subtasks[j].order = j + 1;
                                                  }
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('삭제 실패: $e')),
                                                );
                                              }
                                            },
                                          ),
                                        ] else ...[
                                          IconButton(
                                            icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                                            onPressed: () async {
                                              if (isRunning) {
                                                // 1) Stop the timer
                                                _pauseSubtask(sub);

                                                // 2) Save actual time to server (in minutes)
                                                try {
                                                  await TaskService().updateSubtaskActualTime(
                                                    sub.id,
                                                    sub.elapsed.inMinutes,
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('실제 시간 업데이트 실패: $e')),
                                                  );
                                                }

                                                // 3) Refresh UI if needed
                                                setState(() {});
                                              } else {
                                                // 4) Start the timer
                                                setState(() => _startSubtask(sub));
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
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: GestureDetector(
                                  onTap: () => _addSubtaskDialog(),
                                  child: Container(
                                    height: 75,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      shadows: const [
                                        BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0, 2)),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.add, color: Color(0xFFBF622C)),
                                        SizedBox(width: 8),
                                        Text(
                                          '하위작업 추가',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFBF622C)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );;
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
                              onTap: () => showDialog<bool>(
                                context: context,
                                barrierColor: Colors.black26,
                                builder: (_) => Dialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 200),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('프로젝트 삭제', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 12),
                                        const Text('이 프로젝트를 정말 삭제하시겠습니까?'),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('취소'),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: Colors.grey[400]!),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.pop(context, true);
                                                await TaskService().deleteProject(currentTask.id);
                                                Navigator.pushReplacementNamed(context, '/project');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFC78E48),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              child: const Text('삭제', style: TextStyle(color: Colors.white)),
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 8, offset: Offset(0,2))],
                                ),
                                alignment: Alignment.center,
                                child: const Text('프로젝트 삭제하기', style: TextStyle(color: Color(0xFFC78E48), fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 프로젝트 완료하기
                          Expanded(
                            child: StatefulBuilder(
                              // We wrap in a StatefulBuilder only if you want local setState here—otherwise just use the outer state
                              builder: (ctx, setLocalState) {
                                return GestureDetector(
                                  onTap: () async {
                                    // 1) 난이도 선택 dialog
                                    String level = '상';
                                    final chosen = await showDialog<String>(
                                      context: context,
                                      builder: (dCtx) => AlertDialog(
                                        title: const Text('난이도 입력'),
                                        content: StatefulBuilder(
                                          builder: (c2, dialogSetState) {
                                            return DropdownButton<String>(
                                              value: level,
                                              items: ['상','중','하']
                                                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                                                  .toList(),
                                              onChanged: (v) => dialogSetState(() => level = v!),
                                            );
                                          },
                                        ),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(dCtx, null), child: const Text('취소')),
                                          TextButton(onPressed: () => Navigator.pop(dCtx, level), child: const Text('확인')),
                                        ],
                                      ),
                                    );
                                    if (chosen == null) return; // user cancelled

                                    // 2) Call API
                                    setState(() => _isCompleting = true);
                                    try {
                                      final reward = await TaskService()
                                          .completeAndRewardProject(
                                            projectId: currentTask.id, 
                                            level: chosen,
                                          )
                                          .timeout(const Duration(seconds: 10));

                                      // 3) Remove from list, show reward, navigate
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('획득 보상: $reward')));
                                      Navigator.pushReplacementNamed(context, '/project'); 
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('오류: $e')),
                                      );
                                    } finally {
                                      setState(() => _isCompleting = false);
                                    }
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFC78E48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    alignment: Alignment.center,
                                    child: _isCompleting
                                      ? const SizedBox(
                                          width: 20, height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text(
                                          '프로젝트 완료하기',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
