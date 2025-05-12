// lib/screens/profile/detail_preference.dart

import 'package:flutter/material.dart';
import 'package:domo/models/profile.dart';
import 'package:domo/services/profile_service.dart';
import 'package:domo/widgets/custom_button.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';

class DetailPreferencePage extends StatefulWidget {
  final Profile profile;
  const DetailPreferencePage({super.key, required this.profile});

  @override
  _DetailPreferencePageState createState() => _DetailPreferencePageState();
}

class _DetailPreferencePageState extends State<DetailPreferencePage> {
  static const labels = ['구체적으로', '보통으로', '대략적으로'];
  late double _sliderValue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sliderValue = labels
      .indexOf(widget.profile.subtaskPreference ?? '보통으로')
      .clamp(0, labels.length - 1)
      .toDouble();
  }

  String _toApiValue(String label) {
    switch (label) {
      case '구체적으로': return 'MANY_TASKS';
      case '보통으로':   return 'BALANCED_TASKS';
      case '대략적으로': return 'FEW_TASKS';
      default:           return 'BALANCED_TASKS';
    }
  }

  Future<void> _onApply() async {
    final newLabel = labels[_sliderValue.toInt()];
    if (newLabel == widget.profile.subtaskPreference) {
      Navigator.pop(context, widget.profile);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ProfileService()
        .updateDetailPreference(_toApiValue(newLabel))
        .timeout(const Duration(seconds: 10));

      final updated = widget.profile.copyWith(subtaskPreference: newLabel);
      Navigator.pop(context, updated);
    } catch (e) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('오류: $e')));
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
              // Header with back button
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

              // Main content
              Expanded(
                child: Container(
                  width: 335,
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title + Slider
                      Column(
                        children: [
                          SizedBox(
                            width: 335,
                            child: const Text(
                              '입력한 프로젝트가 어느 정도로\n세분화되길 바라시나요?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.40),
                            ),
                          ),
                          const SizedBox(height: 68),
                          // Slider section
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

                      // Apply button
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

              // Bottom nav
              SizedBox(height: 68, child: BottomNavBar(activeIndex: 4)),
            ],
          ),
        ),
      ),
    );
  }
}
