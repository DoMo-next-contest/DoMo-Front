// lib/screens/project/completed_projects_page.dart

import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';
import 'package:domo/services/task_service.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';

class CompletedProjectsPage extends StatefulWidget {
  const CompletedProjectsPage({super.key});

  @override
  _CompletedProjectsPageState createState() => _CompletedProjectsPageState();
}

class _CompletedProjectsPageState extends State<CompletedProjectsPage> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  // filters & sort state just like ProjectPage
  List<String> get categories => Task.allCategories;
  Set<String> selectedCategories = {...Task.allCategories};

  final List<String> _sortOptions = ['가나다순', '마감일순'];
  String _selectedSort = '가나다순';

  @override
  void initState() {
    super.initState();
    _loadTasks();
    Task.loadCategories().then((_) {
      setState(() => selectedCategories = {...Task.allCategories});
    }).catchError((_) {
      setState(() => selectedCategories = {...Task.allCategories});
    });
  }

  Future<void> _loadTasks() async {
  try {
    final completed = await TaskService().getCompletedProjects();
    setState(() {
      _tasks     = completed;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('❌ error loading completed tasks: $e');
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final filtered = _tasks.where((t) => selectedCategories.contains(t.category)).toList();
    switch (_selectedSort) {
      case '가나다순':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case '마감일순':
        filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [

              // — Title —
              const Positioned(
                left: 20,
                top: 30,
                child: Text(
                  '완료한 프로젝트',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                    height: 1.00,
                    letterSpacing: -0.64,
                  ),
                ),
              ),

              // — 1) Filter chips —
              Positioned(
                left: 0,
                right: 0,
                top: 80,
                height: 30,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      final on = selectedCategories.contains(cat);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (on) {
                              selectedCategories.remove(cat);
                            } else {
                              selectedCategories.add(cat);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: ShapeDecoration(
                            color: on ? const Color(0xFFF2AC57) : const Color(0x331D1B20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: on ? Colors.white : const Color(0xFF757575),
                              fontFamily: 'Inter',
                              fontSize: 14,
                              height: 1.0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // — 2) Sort dropdown —
              Positioned(
                left: 16,
                top: 130,
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  color: Colors.white,
                  elevation: 4,
                  onSelected: (v) => setState(() => _selectedSort = v),
                  itemBuilder: (_) => _sortOptions.map((opt) {
                    return PopupMenuItem(value: opt, child: Text(opt));
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sort, size: 18),
                        const SizedBox(width: 4),
                        Text(_selectedSort, style: TextStyle(color: Colors.grey.shade800)),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // — 3) Completed project list —
              Positioned(
                left: 0, right: 0, top: 170, bottom: 82,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, idx) {
                          final t = filtered[idx];
                          final date = '${t.deadline.month.toString().padLeft(2,'0')}/'
                              '${t.deadline.day.toString().padLeft(2,'0')}';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Container(
                              height: 90,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0,2))],
                              ),
                              child: Row(
                                children: [
                                  // task name & tag
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(t.name,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: ShapeDecoration(
                                            color: const Color(0xBFF2AC57),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          ),
                                          child: Text(t.category,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFFF5F5F5)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // date badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: ShapeDecoration(
                                      color: const Color(0x331D1B20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Text(date, style: const TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // — 4) Bottom nav —
              const Positioned(
                left: 0, right: 0, bottom: 0,
                child: SizedBox(height: 68, child: BottomNavBar(activeIndex: 4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
