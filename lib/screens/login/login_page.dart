// lib/screens/login/login_page.dart

import 'package:domo/screens/onboarding/signup_step1.dart';
import 'package:flutter/material.dart';
import 'package:domo/widgets/labeled_input.dart';
import 'package:domo/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    // TODO: 로그인 로직 처리
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // MobileFrame 배경 보이도록
      body: Center(
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
              Positioned(
                left: 29,
                top: 250,
                child: SizedBox(
                  width: 335,
                  height: 505,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1) 타이틀
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Domo에 로그인하세요 !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),

                      // 2) 간격
                      const SizedBox(height: 55),

                      // 3) ID 입력
                      LabeledInput(
                        label: 'ID',
                        placeholder: '아이디를 입력하세요',
                        controller: _idCtrl,
                      ),

                      // 4) 간격
                      const SizedBox(height: 20),

                      // 5) 비밀번호 입력
                      LabeledInput(
                        label: '패스워드',
                        placeholder: '********',
                        controller: _pwCtrl,
                        obscureText: true,
                      ),

                      const SizedBox(height: 50),

                      // 6) 하단: 회원가입 텍스트 + 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 회원가입 링크
                            GestureDetector(
                              onTap: () {
                                // 직접 SignupPage로 네비게이트
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupStep1(),
                                  ),
                                );
                              },
                              child: const Text(
                                '회원가입하기',
                                style: TextStyle(
                                  color: Color(0xFFAB4E18),
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  decoration: TextDecoration.underline,
                                  height: 1.25,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ),

                            // 로그인 버튼
                            SizedBox(
                              height: 40,
                              child: CustomButton(
                                text: '로그인',
                                type: ButtonType.primary,
                                onPressed: _onLogin,
                              ),
                            ),
                          ],
                        ),
                      ),
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