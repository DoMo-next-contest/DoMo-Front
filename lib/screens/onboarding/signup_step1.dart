import 'package:flutter/material.dart';
import 'package:domo/widgets/step_progress.dart';
import 'package:domo/widgets/labeled_input.dart';
import 'package:domo/widgets/custom_button.dart';

class SignupStep1 extends StatefulWidget {
  const SignupStep1({Key? key}) : super(key: key);

  @override
  State<SignupStep1> createState() => _SignupStep1State();
}

class _SignupStep1State extends State<SignupStep1> {
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,       // 배경을 흰색으로
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
                      // 1) Step progress
                      StepProgress(currentStep: 1, totalSteps: 4),

                      // 2) Title
                      const SizedBox(height: 101),
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
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
                      ),

                      // 3) Form fields
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

                      // 4) Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Row(
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
                              onPressed: () {
                                // TODO: 다음 단계로 이동
                              },
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
