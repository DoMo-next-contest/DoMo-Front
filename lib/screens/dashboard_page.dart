import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:domo/models/task.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';
import 'package:domo/services/item_service.dart';
import 'package:domo/services/task_service.dart';
import 'package:domo/services/profile_service.dart';
import 'package:domo/models/profile.dart';
import 'package:domo/models/item.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final Flutter3DController _controller = Flutter3DController();
  String? _modelSrc;
  bool _loadingModel = true;
  final _taskService = TaskService();
  late Future<Task> _recentFuture;
  late Future<Profile> _profileFuture;


  Future<void> _loadInitialModel() async {
  try {
    // Try to fetch most recently equipped deco
    final recentItem = await ItemService.fetchRecentEquippedItem();

    // Equip and show it
    await ItemService.equipItem(recentItem.id);
    setState(() {
      _modelSrc = recentItem.imageUrl;
      _loadingModel = false;
    });
  } catch (e) {
    debugPrint('⚠️ Failed to load recent item, falling back to ID 9: $e');

    // Fallback to default item (id: 9)
    try {
      await ItemService.equipItem(9);
      final fallbackItem = await ItemService.getItemById(9);
      setState(() {
        _modelSrc = fallbackItem.imageUrl;
        _loadingModel = false;
      });
    } catch (e2) {
      debugPrint('❌ Error loading fallback item: $e2');
      setState(() => _loadingModel = false);
    }
  }
}


  @override
void initState() {
  super.initState();

  // 1️⃣ Listen to model load status
  _controller.onModelLoaded.addListener(() {
    if (_controller.onModelLoaded.value) {
      debugPrint('✅ Model loaded successfully');
    }
  });

  // 2️⃣ Fetch recent task and profile
  _recentFuture = _taskService.fetchRecent();
  _profileFuture = ProfileService().fetchProfile();

  // 3️⃣ Load most recently equipped item or fallback
  _loadInitialModel();

  Task.loadCategories();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Center(
            child: Container(
              width: 393,
              height: 852,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // 3D 캐릭터
                  Positioned(
                    top: 220,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: _loadingModel
                          ? const CircularProgressIndicator()
                          : (_modelSrc != null
                              ? ModelViewer(
                                  key: ValueKey(_modelSrc),
                                  src: _modelSrc!,
                                  alt: '3D model',
                                  autoRotate: true,
                                  cameraControls: true,
                                  disableZoom: true,
                                  disablePan: true,
                                  backgroundColor: Colors.transparent,
                                  //poster: 'assets/png/cutie.png',
                                  loading: Loading.eager,
                                  reveal: Reveal.auto,
                                  shadowIntensity: 0.4,
                                )
                              : const Center(child: Text('Failed to load model'))),
                      ),
                    ),
                  ),

                  // 인사말
                  FutureBuilder<Profile>(
                    future: _profileFuture,
                    builder: (ctx, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Positioned(
                          top: 150,
                          left: 0,
                          right: 0,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snap.hasError) {
                        return Positioned(
                          top: 150,
                          left: 0,
                          right: 0,
                          child: Center(child: Text('Error: \${snap.error}')),
                        );
                      }
                      final profile = snap.data!;
                      return Positioned(
                        top: 150,
                        left: 0,
                        right: 0,
                        child: Text(
                          '반가워요, ${profile.name}님!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF1E1E1E),
                            fontSize: 32,
                          ),
                        ),
                      );
                    },
                  ),

                  // … inside your Stack children, replacing the old FutureBuilder<Task> …

                  // 최근 작업 또는 새 프로젝트 만들기
                  FutureBuilder<Task>(
                    future: _recentFuture,
                    builder: (ctx, snap) {
                      // 1) Still loading?
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // 2) Error *or* completed==true → show “새 프로젝트 만들기”
                      if (snap.hasError || (snap.hasData && snap.data!.completed)) {
                        return Positioned(
                          left: 30,
                          right: 30,
                          bottom: 140,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x19000000), // subtle shadow
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              //elevation: 1,
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.pushReplacementNamed(context, '/add'),
                                child: Container(
                                  height: 80, // 카드 높이
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ① 한 줄 텍스트
                                      Text(
                                        '최근 접속한 프로젝트가 없습니다.',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E1E1E),
                                        ),
                                      ),

                                      const Spacer(), // 텍스트와 버튼 사이 공간

                                      // ② 오른쪽 하단 버튼
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: TextButton(
                                          onPressed: () => Navigator.pushReplacementNamed(context, '/add'),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                '새로운 프로젝트',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFFBF622C),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.open_in_new,
                                                size: 20,
                                                color: Color(0xFFBF622C),
                                              ),
                                            ],
                                          ),
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

                      // 3) We have an active, uncompleted project → render as before
                      final recent = snap.data!;
                      final progress = recent.progress;
                      return Positioned(
                        left: 30, right: 30, bottom: 140,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/task',
                            arguments: recent,
                          ),
                          child: Container(
                            height: 81,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
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
                                )
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        recent.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF21272A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF2AC57),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x19000000),
                                            blurRadius: 16,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        recent.category,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFFF5F5F5),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF9AA5B6),
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 294,
                                  height: 8,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFC1C7CD),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Container(
                                          width: 294 * progress,
                                          height: 8,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFAB4E18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Bottom Navigation
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: 68,
                      child: BottomNavBar(activeIndex: 0),
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
