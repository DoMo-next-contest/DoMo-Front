import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';
import 'dart:ui' show PointerDeviceKind;
import 'dart:async';



class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  late String taskName;
  late Task currentTask;
  bool _isEditing = false;   

  final Map<Subtask, Timer?> _timers = {};
  final Map<Subtask, DateTime> _startTimes = {};

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatDuration(Duration d) {
    final h = _twoDigits(d.inHours);
    final m = _twoDigits(d.inMinutes.remainder(60));
    final s = _twoDigits(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  late TextEditingController _nameController;
  // ── CATEGORY CONTROLLER ─────────────────────────────────────────────────────
  // Used to type a new category name in the bottom‑sheet
  final TextEditingController _categoryController = TextEditingController();
 


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }




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
    _nameController.text = currentTask.name;
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  void _showCategoryPicker(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text(
          '카테고리 관리',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // existing categories
              ...Task.allCategories.map((cat) {
                final isSel = cat == selectedCategory;
                return ListTile(
                  title: Text(cat),
                  leading: isSel ? const Icon(Icons.check) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        Task.allCategories.remove(cat);
                        if (selectedCategory == cat) {
                          selectedCategory = Task.allCategories.first;
                          currentTask.category = selectedCategory;
                        }
                      });
                      Navigator.pop(context);
                      _showCategoryPicker(context);
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
              }),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        hintText: '새 카테고리 추가',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      final newCat = _categoryController.text.trim();
                      if (newCat.isNotEmpty &&
                          !Task.allCategories.contains(newCat)) {
                        setState(() {
                          Task.allCategories.add(newCat);
                        });
                        _categoryController.clear();
                        Navigator.pop(context);
                        _showCategoryPicker(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
      );
    },
  );
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
                child: _isEditing
                  ? SizedBox(
                      width: 250,                // adjust to taste
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 1.00,
                          letterSpacing: -0.64,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,        // removes the default underline
                          enabledBorder: InputBorder.none, // ensures no border when unfocused
                          focusedBorder: InputBorder.none, // ensures no border when focused
                        ),
                        onChanged: (v) => currentTask.name = v,
                      ),
                    )
                  : Text(
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
  top: 80,
  child: InkWell(
    // only respond when in edit mode
    onTap: _isEditing
      ? () => _showCategoryPicker(context)
      : null,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: const Color(0xFFF2AC57),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Center(
        child: Text(
          currentTask.category,
          style: const TextStyle(
            color: Color(0xFFF5F5F5),
            fontSize: 14,
            height: 1,
          ),
        ),
      ),
    ),
  ),
),



     
                // 2) 날짜 표시 박스 (편집 시 팝업 가능)
                Positioned(
                  top: 140,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.transparent,            // provide the “ink” surface
                    borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    // only tappable when editing
                    onTap: _isEditing
                      ? () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: currentTask.deadline,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (picked != null) {
                            setState(() {
                              currentTask.deadline = picked;
                            });
                          }
                        }
                      : null,
                    child: Container(
                      width: double.infinity,
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
                          Icon(Icons.calendar_today, color: Color(0xFFC78E48)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),

                // Main content: Subtasks list and new subtask input.

                Positioned(
                  top: 200,
                  left: 0,
                  right: 0,
                  bottom: 135,
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
                              final isRunning = _timers[sub] != null;
                                                  final displayDuration = isRunning
                                                    ? sub.actualDuration + DateTime.now().difference(_startTimes[sub]!)
                                                    : sub.actualDuration;
                              return Padding(
                                key: ValueKey(sub.title),
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  width: 330,
                                  height: 75,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x19000000),
                                        blurRadius: 16,
                                        offset: Offset(0, 2),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Left part: checkbox or drag‑handle + title + expected duration badge
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // toggle between checkbox / drag handle
                                            if (!_isEditing)
                                              Checkbox(
                                                value: sub.isDone,
                                                onChanged: (c) => setState(() => sub.isDone = c!),
                                              ),
                                            if (_isEditing)
                                              ReorderableDragStartListener(
                                                index: index,
                                                child: const Icon(Icons.drag_handle, size: 24),
                                              ),

                                            const SizedBox(width: 16),

                                            // Title + expected‑duration badge
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
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
                                                  const SizedBox(height: 4),
                                                  
                                                  

                                                  // In the Column where badges are shown, replace the Row with:
                                                  Row(
                                                    children: [
                                                      // expected badge
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
                                                      // only show actual when non-zero or running
                                                      if (displayDuration > Duration.zero) ...[
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                          decoration: ShapeDecoration(
                                                            color: const Color(0x19BF622C),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                          ),
                                                          child: Text(
                                                            // show hours if >=1h, always show mm:ss
                                                            displayDuration.inHours > 0
                                                              ? '${displayDuration.inHours}: ${displayDuration.inMinutes.remainder(60)}: ${displayDuration.inSeconds.remainder(60)}'
                                                              : _formatDuration(displayDuration),
                                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      if (_isEditing)
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 24),
                                          onPressed: () {
                                            final sub = currentTask.subtasks[index];
                                            final titleCtrl = TextEditingController(text: sub.title);
                                            final hoursCtrl = TextEditingController(text: sub.actualDuration.inHours.toString());
                                            final minsCtrl = TextEditingController(text: sub.actualDuration.inMinutes.remainder(60).toString());
                                            final secsCtrl = TextEditingController(text: sub.actualDuration.inSeconds.remainder(60).toString());

                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Edit Subtask'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller: titleCtrl,
                                                      decoration: const InputDecoration(labelText: 'Title'),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextField(
                                                            controller: hoursCtrl,
                                                            keyboardType: TextInputType.number,
                                                            decoration: const InputDecoration(labelText: 'Hours'),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: TextField(
                                                            controller: minsCtrl,
                                                            keyboardType: TextInputType.number,
                                                            decoration: const InputDecoration(labelText: 'Minutes'),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: TextField(
                                                            controller: secsCtrl,
                                                            keyboardType: TextInputType.number,
                                                            decoration: const InputDecoration(labelText: 'Seconds'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        sub.title = titleCtrl.text.trim();
                                                        final h = int.tryParse(hoursCtrl.text) ?? 0;
                                                        final m = int.tryParse(minsCtrl.text) ?? 0;
                                                        final s = int.tryParse(secsCtrl.text) ?? 0;
                                                        sub.actualDuration = Duration(hours: h, minutes: m, seconds: s);
                                                      });
                                                      Navigator.pop(ctx);
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),





                                      if (_isEditing)
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 24),
                                          onPressed: () => setState(() => currentTask.subtasks.removeAt(index)),
                                        ),
                                      if (!_isEditing)
                                        IconButton(
                                          icon: Icon(
                                            _timers[sub] == null
                                              ? Icons.play_arrow_rounded
                                              : Icons.pause_rounded,
                                            size: 24),
                                          onPressed: () {
                                            setState(() {
                                              if (_timers[sub] == null) {
                                                // start timing
                                                _startTimes[sub] = DateTime.now();
                                                _timers[sub] = Timer.periodic(const Duration(seconds: 1), (_) {
                                                  setState(() {});              // only rebuild, don’t add here
                                                });
                                              } else {
                                                // pause timing
                                                _timers[sub]!.cancel();
                                                _timers[sub] = null;
                                                final started = _startTimes.remove(sub)!;
                                                sub.actualDuration += DateTime.now().difference(started);
                                              }
                                            });
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
                  bottom: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    child: Row(
                      children: [
                        // “프로젝트 삭제하기” (outline style)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Material(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Color(0xFFC78E48)),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  // 1) show confirmation dialog
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('프로젝트 삭제'),
                                      content: const Text('정말 이 프로젝트를 삭제하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(false),
                                          child: const Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('삭제'),
                                        ),
                                      ],
                                    ),
                                  );
                                  // 2) if confirmed, remove and navigate back
                                  if (shouldDelete == true) {
                                    setState(() {
                                      globalTaskList.remove(currentTask);
                                    });
                                    Navigator.of(context).pop(); // go back to previous screen
                                  }
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  foregroundColor: const Color(0xFFC78E48),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                child: const Text('프로젝트 삭제하기'),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),
                        // “프로젝트 완료하기” (filled style)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Material(
                              color: const Color(0xFFC78E48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextButton(
                                onPressed: () { /* TODO: 완료 로직 */ },
                                style: TextButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                child: const Text('프로젝트 완료하기'),
                              ),
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
                                        color: Color(0xFFBF622C), // Changed to black
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
                                        color: Color(0xFFBF622C), // Changed to black
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
