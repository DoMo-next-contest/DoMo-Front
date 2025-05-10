// lib/screens/profile/change_password_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:domo/services/profile_service.dart';
import 'package:domo/widgets/custom_button.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldCtl = TextEditingController();
  final _newCtl = TextEditingController();
  bool _isLoading = false;

  String? _oldPwdError;    // ← 여기에 에러 메시지를 저장

  Future<void> _onApply() async {
    final oldPwd = _oldCtl.text.trim();
    final newPwd = _newCtl.text.trim();

    // 필수 검증
    if (oldPwd.isEmpty || newPwd.isEmpty) {
      setState(() {
        _oldPwdError = oldPwd.isEmpty ? '현재 비밀번호를 입력해주세요' : null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _oldPwdError = null;
    });

    try {
      await ProfileService()
          .updatePassword(oldPassword: oldPwd, newPassword: newPwd)
          .timeout(const Duration(seconds: 10));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
      );
      Navigator.pop(context);
    } on Exception catch (e) {
      // 백엔드에서 401 Unauthorized 를 던져준다면 여기서 잡아서 에러 메시지로 설정
      if (e.toString().contains('403')) {
        setState(() {
          _oldPwdError = '현재 비밀번호가 올바르지 않습니다';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 393,
          height: 852,
          padding: const EdgeInsets.only(top: 53, bottom: 20),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              // ───────── Header ─────────
              Container(
                width: 375,
                height: 72,
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF0F4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Color(0xFF545F70)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ───────── Content ─────────
              Expanded(
                child: Container(
                  width: 335,
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 입력 필드
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '현재 비밀번호',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _oldCtl,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '기존 비밀번호를 입력하세요',
                              errorText: _oldPwdError,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '새 비밀번호',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _newCtl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '새 비밀번호를 입력하세요',
                            ),
                          ),
                        ],
                      ),

                      // 변경사항 적용 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(text: '변경사항 적용', onPressed: _onApply),
                                ],
                              ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // ───────── Bottom Nav ─────────
              SizedBox(
                height: 68,
                child: BottomNavBar(activeIndex: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
