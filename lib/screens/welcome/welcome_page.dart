import 'package:flutter/material.dart';
import 'package:domo/widgets/custom_button.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomeScreen> {
  final Flutter3DController _controller = Flutter3DController();

  @override
  void initState() {
    super.initState();
    _controller.onModelLoaded.addListener(() {
      if (_controller.onModelLoaded.value) {
        debugPrint('✅ Model loaded successfully');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // 3D 모델
              Positioned(
                top: 300,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: ModelViewer(
                      src: 'assets/character.glb',
                      alt: '3D model of Cutie',
                      autoRotate: true,
                      cameraControls: true,
                      disableZoom: true,
                      disablePan: true,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),

              // 기존 Welcome UI
              Positioned(
                left: 29,
                top: 0,
                child: SizedBox(
                  width: 335,
                  height: 852,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 150),
                      const Text(
                        'Domo에 오신 것을 환영합니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '앱을 시작하려면 로그인하거나 가입하세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),

                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: CustomButton(
                              text: '로그인',
                              type: ButtonType.secondary,
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: CustomButton(
                              text: '회원가입',
                              type: ButtonType.primary,
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/signup'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
