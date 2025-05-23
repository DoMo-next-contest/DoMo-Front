// lib/screens/login/login_page.dart

import 'package:domo/screens/onboarding/signup_step1.dart';
import 'package:flutter/material.dart';
import 'package:domo/widgets/labeled_input.dart';
import 'package:domo/widgets/custom_button.dart';
import 'package:domo/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _idFocus = FocusNode();               // ← NEW
  final _pwFocus = FocusNode();
  bool _isHoveringSignUp = false;
  String? _loginError;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _idFocus.dispose();                       // ← NEW
    _pwFocus.dispose();
    super.dispose();
  }

  void _onLogin() async {
  try {
    final auth = AuthService();
    final tokens = await auth.login(_idCtrl.text, _pwCtrl.text);



    // Now navigate
    Navigator.pushReplacementNamed(context, '/dashboard');
  } on AuthException catch (e) {
    setState(() => _loginError = '존재하지 않는 아이디입니다');
      _idFocus.requestFocus();
  }
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
                          'Domo에 로그인하세요!',
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
                        textInputAction: TextInputAction.next,
                        focusNode: _idFocus,
                        onSubmitted: (_) => _pwFocus.requestFocus(),
                        errorText: _loginError,
                      ),

                      // 4) 간격
                      const SizedBox(height: 20),

                      // 5) 비밀번호 입력
                      LabeledInput(
                        label: '패스워드',
                        placeholder: '********',
                        controller: _pwCtrl,
                        focusNode: _pwFocus,
                        obscureText: true,
                        textInputAction: TextInputAction.done,  // “Done” button
                        onSubmitted: (_) => _onLogin(),
                      ),

                      const SizedBox(height: 50),

                      // 6) 하단: 회원가입 텍스트 + 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 회원가입 링크
                            MouseRegion(
                              cursor: SystemMouseCursors.click,            // ↳ 커서가 ‘손가락’ 모양으로
                              onEnter: (_) => setState(() => _isHoveringSignUp = true),
                              onExit:  (_) => setState(() => _isHoveringSignUp = false),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SignupStep1()),
                                  );
                                },
                                child: Text(
                                  '회원가입하기',
                                  style: TextStyle(
                                    color: _isHoveringSignUp
                                        ? const Color(0xFFD27A3D)  // hover 시 색 변환
                                        : const Color(0xFFAB4E18),
                                    decoration: TextDecoration.underline,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),

                            // 로그인 버튼
                            SizedBox(
                              height: 48,
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