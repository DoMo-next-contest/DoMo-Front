import 'package:flutter/material.dart';
import 'package:domo/models/profile.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';

class DecorItem {
  final String modelSrc;
  final String thumbnail; // 그리드용 미리보기 이미지 경로

  DecorItem({required this.modelSrc, required this.thumbnail});
}

class DecorPage extends StatefulWidget {
  const DecorPage({super.key, required this.profile});

  final Profile profile;

  @override
  DecorPageState createState() => DecorPageState();
}

class DecorPageState extends State<DecorPage> {
  final Flutter3DController _controller = Flutter3DController();

  // 모델 + 썸네일 정보
  final List<DecorItem> availableDecors = [
    DecorItem(
      modelSrc: 'assets/glb/character.glb',
      thumbnail: 'assets/png/cutie.png',
    ),
    DecorItem(
      modelSrc: 'assets/glb/tiger_with_car.glb',
      thumbnail: 'assets/png/car.png',
    ),
  ];

  // 현재 표시할 모델 경로
  String currentModelSrc = 'assets/glb/character.glb';

  @override
  void initState() {
    super.initState();
    _controller.onModelLoaded.addListener(() {
      if (_controller.onModelLoaded.value) {
        debugPrint('✅ Model loaded: $currentModelSrc');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Main 3D model viewer (with key)
              SizedBox(
                width: double.infinity,
                height: 250,
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: ModelViewer(
                      key: ValueKey(currentModelSrc),
                      src: currentModelSrc,
                      alt: '3D model',
                      autoRotate: true,
                      cameraControls: true,
                      disableZoom: true,
                      disablePan: true,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Coins & 버튼
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.monetization_on,
                        color: Color(0xFFF2AC57)),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.profile.coins} 코인',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2AC57),
                        foregroundColor: Colors.white,           // ← forces white text/icons
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () { /* … */ },
                      child: const Text('새로운 데코 얻기 (40)'),
                    ),

                  ],
                ),
              ),

              

              const SizedBox(height: 8),

              // 하단 그리드: 썸네일 표시
              Expanded(
                child: Container(
                  color: const Color(0xFFFFF5E5),
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: availableDecors.length,
                    itemBuilder: (_, index) {
                      final item = availableDecors[index];
                      final isSelected = item.modelSrc == currentModelSrc;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            currentModelSrc = item.modelSrc;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.amber.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item.thumbnail,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom nav
              SizedBox(
                height: 68,
                child: BottomNavBar(activeIndex: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
