// lib/screens/dashboard/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:domo/models/task.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';
import 'package:domo/services/character_service.dart';
import 'package:domo/services/task_service.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final Flutter3DController _controller = Flutter3DController();
  String? _modelSrc;
  bool _loadingModel = true;
  final _service = TaskService(); 
  late Future<Task> _recentFuture;

  @override
  void initState() {
    super.initState();
    _controller.onModelLoaded.addListener(() {
      if (_controller.onModelLoaded.value) {
        debugPrint('✅ Model loaded successfully');
      }
    });

     _recentFuture = _service.fetchRecent();
    
    CharacterService.fetchModelUrl()
      .then((url) {
        setState(() {
          //_modelSrc = url;
          _modelSrc = 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
          _loadingModel = false;
        });
      })
      .catchError((err) {
            debugPrint('❌ Error fetching model URL: $err');
            setState(() => _loadingModel = false);
      });

   
  }

  @override
  Widget build(BuildContext context) {
    // 가장 최근 활동한 프로젝트를 찾습니다.
    /*
    final Task recent = globalTaskList.reduce(
      (a, b) => a.lastActivity.isAfter(b.lastActivity) ? a : b,
    );
    final double progress = recent.progress;
    */
    
    return Scaffold(
      backgroundColor: Colors.transparent, // MobileFrame 배경 보이도록
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
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
                              ? ModelViewer(key: ValueKey(_modelSrc),        // ← rebuild on URL change
                                                          
                                                    src: _modelSrc!,
                                                    alt: '3D model of Cutie',
                                                    autoRotate: true,
                                                    cameraControls: true,
                                                    disableZoom: true,
                                                    disablePan: true,
                                                    backgroundColor: Colors.transparent,
                                                    poster: 'assets/png/cutie.png',
                                                    loading: Loading.eager,
                                                    reveal: Reveal.auto,
                                                    shadowIntensity: 0.4,
                                                    )

                              : Center(child: Text('Failed to load model URL'))),
                      ),
                    ),
                  ),

                  // 인사말
                  const Positioned(
                    top: 150,
                    left: 0,
                    right: 0,
                    child: Text(
                      '반가워요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                        letterSpacing: -0.64,
                      ),
                    ),
                  ),

                  FutureBuilder<Task>(
                  future: _recentFuture,
                  builder: (ctx, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      // still loading
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text('Error: ${snap.error}'),
                      );
                    }

                    // here’s your actual Task
                    final recent = snap.data!;
                    final progress = recent.progress;

                    // now return _exactly_ your old Positioned(...) widget,
                    // but using `recent` instead of `_recentFuture`:
                    return Positioned(
                      left: 30,
                      right: 30,
                      bottom: 140,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/task',
                          arguments: recent,      // pass the Task
                        ),
                        child: Container(
                          height: 81,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      recent.name,        // ← use the Task’s name
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF21272A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 1),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF2AC57),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
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
                                    child: Text(
                                      recent.category,    // ← and its category
                                      style: const TextStyle(
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
                              // 진행률 바
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
                                            borderRadius:
                                                BorderRadius.circular(10),
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

                  // Bottom navigation
                  
                  // Bottom nav
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
