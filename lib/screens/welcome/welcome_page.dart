// lib/screens/welcome/welcome_page.dart

import 'package:flutter/material.dart';
import 'package:domo/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

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
              Positioned(
                left: 29,
                top: 0,
                child: SizedBox(
                  width: 335,
                  height: 852,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 200),

                      // 1) 메인 타이틀
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

                      // 2) 서브타이틀
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

                      // 3) 버튼 Column
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

                      const SizedBox(height: 40),
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