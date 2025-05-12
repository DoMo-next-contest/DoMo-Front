import 'package:flutter/material.dart';
import 'package:domo/widgets/step_progress.dart';
import 'package:domo/widgets/labeled_input.dart';
import 'package:domo/widgets/custom_button.dart';
import 'package:domo/services/profile_service.dart';
import 'package:domo/models/profile.dart';


class SignupStep1 extends StatefulWidget {
  const SignupStep1({super.key});

  @override
  State<SignupStep1> createState() => _SignupStep1State();
}

class _SignupStep1State extends State<SignupStep1> {
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _onNext() async {
    final name = _nameCtrl.text.trim();
    final username = _idCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _pwCtrl.text;

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final Profile profile = await ProfileService().createProfile(
        username: username,  // ✅ matches parameter name
        password: password,
        name: name,
        email: email,
      );

      // Optionally store token/password securely here
      Navigator.pushNamed(
        context,
        '/signupStep2',
        arguments: profile,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              Positioned(
                left: 29,
                top: 0,
                child: SizedBox(
                  width: 335,
                  height: 852,
                  child: Column(
                    children: [
                      StepProgress(currentStep: 1, totalSteps: 4),
                      const SizedBox(height: 101),
                      const Text(
                        '지금 Domo에 가입하세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      LabeledInput(
                        label: '이름',
                        placeholder: '홍길동',
                        controller: _nameCtrl,
                      ),
                      const SizedBox(height: 28),
                      LabeledInput(
                        label: 'ID',
                        placeholder: 'userid',
                        controller: _idCtrl,
                      ),
                      const SizedBox(height: 28),
                      LabeledInput(
                        label: '이메일',
                        placeholder: 'example@gmail.com',
                        controller: _emailCtrl,
                      ),
                      const SizedBox(height: 28),
                      LabeledInput(
                        label: '패스워드',
                        placeholder: '********',
                        controller: _pwCtrl,
                        obscureText: true,
                      ),
                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    text: '취소',
                                    type: ButtonType.secondary,
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const SizedBox(width: 16),
                                  CustomButton(
                                    text: '다음',
                                    onPressed: _onNext,
                                  ),
                                ],
                              ),
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