// lib/screens/project/project_page.dart

import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:domo/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:domo/services/task_service.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';



class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  ProjectPageState createState() => ProjectPageState();
}

class ProjectPageState extends State<ProjectPage> {

  List<Task> _tasks = [];
  bool _isLoading = true;

 @override
void initState() {
  super.initState();

  // kick off your tasks load as before
  _loadTasksFromBackend();

  // now load the tags, and when that's done update both Task.allCategories
  // *and* our selectedCategories inside setState
  Task.loadCategories().then((_) {
    setState(() {
      // allCategories has just been replaced by loadCategories()
      selectedCategories = {...Task.allCategories};
    });
  }).catchError((_) {
    // if load failed, fall back and still setState
    setState(() {
      //Task.allCategories = ['업무','학업','일상','운동','자기계발','기타'];
      selectedCategories  = {...Task.allCategories};
    });
  });
}



Future<void> _loadTasksFromBackend() async {
  try {
    final tasks = await TaskService().getTasks();
    
    setState(() {
      _tasks = tasks.where((t) => t.progress <= 1.0).toList();
    });
    
   
  } catch (e) {
    debugPrint('❌ Error loading tasks: $e');
    setState(() => _isLoading = false);
  }
}


  // 1) Categories for filtering
  List<String> get categories => Task.allCategories;
  Set<String> selectedCategories = {...Task.allCategories};

  // 2) Sort options
  final List<String> _sortOptions = ['가나다순', '진행률순', '마감일순'];
  String _selectedSort = '가나다순';

  /*
  @override
  void initState() {
    super.initState();
    // In case categories were added/removed elsewhere, keep local selection in sync:
    selectedCategories = {...Task.allCategories};
  }
  */

 

  // Persist updated categories list whenever it changes
  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userCategories', Task.allCategories);
  }

  Widget _buildChip(String label) {
    final isOn = selectedCategories.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isOn)
            selectedCategories.remove(label);
          else
            selectedCategories.add(label);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isOn ? const Color(0xFFF2AC57) : const Color(0x331D1B20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isOn ? Colors.white : const Color(0xFF757575),
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // -- 1) Filter --
    /*
    final filtered = globalTaskList
        .where((t) => selectedCategories.contains(t.category))
        .toList();
    */
  
    
    final filtered = _tasks
    .where((t) => selectedCategories.contains(t.category))
    .toList();
    
    /*
    final filtered = _tasks;
    debugPrint('🔍 total tasks: ${_tasks.length}, after filter: ${filtered.length}');
    */

    // -- 2) Sort --
    switch (_selectedSort) {
      case '가나다순':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case '진행률순':
        filtered.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case '마감일순':
        filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // let device–frame show
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(0),
          color: Colors.white,
          child: Stack(
            children: [
              // — Title —
              const Positioned(
                left: 20,
                top: 30,
                child: Text(
                  '프로젝트 목록',
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

              // — 1) Filter chips row —
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
                    itemBuilder: (_, i) => _buildChip(categories[i]),
                  ),
                ),
              ),

              // — 2) Sort dropdown under chips, flush left —
              Positioned(
                left: 16,
                top: 130,
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: Colors.white,
                  elevation: 4,
                  onSelected: (v) {
                    setState(() => _selectedSort = v);
                  },
                  itemBuilder: (_) => _sortOptions.map((opt) {
                    return PopupMenuItem<String>(
                      value: opt,
                      child: Text(
                        opt,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sort, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          _selectedSort,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // — 3) Project list —
              Positioned(
                left: 0,
                right: 0,
                top: 170,
                bottom: 82,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, idx) {
                    final task = filtered[idx];
                    final daysLeft =
                        task.deadline.difference(DateTime.now()).inDays;
                    final progress = task.progress;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/task',
                            arguments: task,
                          );
                          setState(() {});
                        },
                        child: Container(
                          height: 90,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 13),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            shadows: const [
                              BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Task info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      task.name,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF121212),
                                        height: 1.40,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xBFF2AC57),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                      ),
                                      child: Text(
                                        task.category,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFFF5F5F5),
                                          height: 1.00,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Days left & progress
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: ShapeDecoration(
                                      color: const Color(0x331D1B20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                    ),
                                    child: Text(
                                      '${daysLeft}d',
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF121212),
                                        height: 1.00,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 4,
                                      backgroundColor:
                                          const Color(0x33F2AC57),
                                      valueColor:
                                          const AlwaysStoppedAnimation(
                                              Color(0xFFF2AC57)),
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

              // — 4) Bottom navigation bar —
              Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: 68,
                      child: BottomNavBar(activeIndex: 1),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
