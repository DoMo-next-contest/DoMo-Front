// lib/screens/onboarding/signup_step3.dart

import 'package:flutter/material.dart';
import 'package:domo/widgets/step_progress.dart';
import 'package:domo/widgets/custom_button.dart';
import 'package:domo/models/profile.dart';
import 'package:domo/services/profile_service.dart';

class SignupStep3 extends StatefulWidget {
  final Profile profile;
  const SignupStep3({super.key, required this.profile});

  @override
  _SignupStep3State createState() => _SignupStep3State();
}

class _SignupStep3State extends State<SignupStep3> {
  double _sliderValue = 0;
  static const List<String> _labels = ['타이트하게', '적당하게', '여유롭게'];
  final bool _isLoading = false;

  Future<void> _onNext() async {
  widget.profile.timePreference = _labels[_sliderValue.toInt()];
  Navigator.pushNamed(
    context,
    '/signupStep4',
    arguments: widget.profile,
  );
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1) Step progress
                      const StepProgress(currentStep: 3, totalSteps: 4),
                      const SizedBox(height: 200),

                      // 2) Title
                      const Text(
                        '예상 소요 시간에 얼마나 여유를 두고 계산하길 바라시나요?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        color: Colors.black /* Color-Scheme-1-Text */,
                        fontSize: 24,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                        ),
                      ),
                      const SizedBox(height: 68),

                      // 3) Slider Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '예상소요시간 계산 선호도',
                            style: TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 1.40,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              inactiveTrackColor: const Color(0x28787880),
                              activeTrackColor: const Color(0x7FBF622C),
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                            ),
                            child: Slider(
                              value: _sliderValue,
                              min: 0,
                              max: 2,
                              divisions: 2,
                              onChanged: (v) => setState(() => _sliderValue = v),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                '타이트하게',
                                style: TextStyle(
                                  color: Color(0xFF545F70),
                                  fontSize: 13,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.69,
                                ),
                              ),
                              Text(
                                '적당하게',
                                style: TextStyle(
                                  color: Color(0xFF545F70),
                                  fontSize: 13,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.69,
                                ),
                              ),
                              Text(
                                '여유롭게',
                                style: TextStyle(
                                  color: Color(0xFF545F70),
                                  fontSize: 13,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.69,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Spacer(),

                      // 4) Buttons strip
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    text: '이전',
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