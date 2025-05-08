import 'package:flutter/material.dart';
import 'package:domo/models/profile.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class DecorItem {
  final String modelSrc;
  final String thumbnail; // 그리드용 미리보기 이미지 경로

  DecorItem({required this.modelSrc, required this.thumbnail});
}

class DecorPage extends StatefulWidget {
  const DecorPage({Key? key, required this.profile}) : super(key: key);

  final Profile profile;

  @override
  DecorPageState createState() => DecorPageState();
}

class DecorPageState extends State<DecorPage> {
  final Flutter3DController _controller = Flutter3DController();

  // 모델 + 썸네일 정보
  final List<DecorItem> availableDecors = [
    DecorItem(
      modelSrc: 'assets/character.glb',
      thumbnail: 'assets/cutie.png',
    ),
    DecorItem(
      modelSrc: 'assets/tiger_with_car.glb',
      thumbnail: 'assets/car.png',
    ),
  ];

  // 현재 표시할 모델 경로
  String currentModelSrc = 'assets/character.glb';

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
                child: _BottomNavBar(activeIndex: 3),
              ),
            ],
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
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: List.generate(5, (i) {
          final color = i == activeIndex
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
