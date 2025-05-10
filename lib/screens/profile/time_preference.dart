// lib/screens/profile/time_preference.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:domo/models/profile.dart';
import 'package:domo/services/profile_service.dart';
import 'package:domo/widgets/custom_button.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';

class TimePreferencePage extends StatefulWidget {
  final Profile profile;
  const TimePreferencePage({Key? key, required this.profile}) : super(key: key);

  @override
  _TimePreferencePageState createState() => _TimePreferencePageState();
}

class _TimePreferencePageState extends State<TimePreferencePage> {
  double _sliderValue = 1;
  bool _isLoading = false;
  static const labels = ['타이트하게', '적당하게', '여유롭게'];

  @override
  void initState() {
    super.initState();
    _sliderValue = labels
        .indexOf(widget.profile.timePreference ?? '적당하게')
        .toDouble()
        .clamp(0, 2);
  }

  String _toApiValue(String label) {
    switch (label) {
      case '타이트하게':
        return 'TIGHTLY';
      case '적당하게':
        return 'MODERATELY';
      case '여유롭게':
        return 'LENIENTLY';
      default:
        return 'MODERATELY';
    }
  }

  Future<void> _onApply() async {
    final newLabel = labels[_sliderValue.toInt()];

    // If unchanged, just pop without calling API
    if (newLabel == widget.profile.timePreference) {
      Navigator.pop(context, widget.profile);
      return;
    }

    setState(() => _isLoading = true);
    final apiValue = _toApiValue(newLabel);

    try {
      await ProfileService()
          .updateTimePreference(apiValue)
          .timeout(const Duration(seconds: 10));
      widget.profile.timePreference = newLabel;
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
                              '예상 소요 시간에 얼마나 여유를 두고 계산하길 바라시나요?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 68),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '예상소요시간 계산 선호도',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400, height: 1.40),
                              ),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  inactiveTrackColor: const Color(0x28787880),
                                  activeTrackColor: const Color(0x7FBF622C),
                                  thumbColor: Colors.white,
                                  thumbShape:
                                      const RoundSliderThumbShape(enabledThumbRadius: 10),
                                  overlayShape:
                                      const RoundSliderOverlayShape(overlayRadius: 0),
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
                                  Text('타이트하게',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF545F70),
                                          height: 1.69)),
                                  Text('적당하게',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF545F70),
                                          height: 1.69)),
                                  Text('여유롭게',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF545F70),
                                          height: 1.69)),
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
