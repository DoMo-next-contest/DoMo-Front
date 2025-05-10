// lib/screens/profile/detail_preference.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:domo/models/profile.dart';
import 'package:domo/services/profile_service.dart';
import 'package:domo/widgets/custom_button.dart';
import 'package:domo/screens/profile/profile_page.dart'; // pop 시 결과 전달용
import 'package:domo/widgets/bottom_nav_bar.dart';

class DetailPreferencePage extends StatefulWidget {
  final Profile profile;
  const DetailPreferencePage({Key? key, required this.profile}) : super(key: key);

  @override
  _DetailPreferencePageState createState() => _DetailPreferencePageState();
}

class _DetailPreferencePageState extends State<DetailPreferencePage> {
  double _sliderValue = 1;
  bool _isLoading = false;
  static const labels = ['구체적으로', '보통으로', '대략적으로'];

  @override
  void initState() {
    super.initState();
    _sliderValue = labels.indexOf(widget.profile.subtaskPreference ?? '보통으로').toDouble().clamp(0, 2);
  }

  String _toApiValue(String label) {
    switch (label) {
      case '구체적으로': return 'MANY_TASKS';
      case '보통으로':   return 'NORMAL_TASKS';
      case '대략적으로': return 'FEW_TASKS';
      default:           return 'NORMAL_TASKS';
    }
  }

  Future<void> _onApply() async {
  final newLabel = labels[_sliderValue.toInt()];

  // 1) If it’s the same as before, skip the PATCH and just pop
  if (newLabel == widget.profile.subtaskPreference) {
    Navigator.pop(context, widget.profile);
    return;
  }

  // 2) Otherwise, do the normal update flow
  setState(() => _isLoading = true);
  final apiValue = _toApiValue(newLabel);
  try {
    await ProfileService()
      .updateDetailPreference(apiValue)
      .timeout(const Duration(seconds: 10));
    widget.profile.subtaskPreference = newLabel;
    Navigator.pop(context, widget.profile);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('오류: $e')),
    );
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
                      // 제목 + 슬라이더
                      Column(
                        children: [
                          SizedBox(
                            width: 335,
                            child: const Text(
                              '입력한 프로젝트가 어느 정도로\n세분화되길 바라시나요?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 68),

                          // 슬라이더 영역
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '하위작업 세분화 선호도',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.40),
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
                                  Text('구체적으로', style: TextStyle(fontSize: 13, color: Color(0xFF545F70), height: 1.69)),
                                  Text('보통으로',   style: TextStyle(fontSize: 13, color: Color(0xFF545F70), height: 1.69)),
                                  Text('대략적으로', style: TextStyle(fontSize: 13, color: Color(0xFF545F70), height: 1.69)),
                                ],
                              ),
                            ],
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
