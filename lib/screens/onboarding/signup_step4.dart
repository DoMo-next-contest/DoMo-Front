// lib/screens/onboarding/signup_step4.dart

import 'package:flutter/material.dart';
import 'package:domo/widgets/step_progress.dart';
import 'package:domo/widgets/custom_button.dart';
import 'package:domo/models/profile.dart';
import 'package:domo/services/profile_service.dart';
import 'package:domo/services/task_service.dart';

class SignupStep4 extends StatefulWidget {
  final Profile profile;
  const SignupStep4({super.key, required this.profile});

  @override
  _SignupStep4State createState() => _SignupStep4State();
}

class _SignupStep4State extends State<SignupStep4> {
  final List<String> _allCategories = [
    '업무',
    '학업',
    '일상',
    '운동',
    '자기계발',
  ];
  late Set<String> _selected;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.profile.categories != null
        ? Set<String>.from(widget.profile.categories!)
        : <String>{};
  }

  String _mapSubtaskPref(String? value) {
  switch (value) {
    case '구체적으로':
      return 'MANY_TASKS';
    case '보통으로':
      return 'BALANCED_TASKS';
    case '대략적으로':
      return 'FEW_TASKS';
    default:
      return 'BALANCED_TASKS';
  }
}

String _mapTimePref(String? value) {
  switch (value) {
    case '빠듯하게':
      return 'TIGHT';
    case '적당히':
      return 'BALANCED';
    case '여유롭게':
      return 'RELAXED';
    default:
      return 'BALANCED';
  }
}

List<String> _mapTags(List<String>? rawTags) {
  if (rawTags == null) return [];
  final mapping = {
    '업무': 'WORK',
    '학업': 'STUDY',
    '운동': 'EXERCISE',
    '일상': 'LIFE',
    '자기계발': 'SELF_IMPROVEMENT',
  };

  return rawTags.map((k) => mapping.containsKey(k) ? mapping[k]! : k).toList();
}



  Future<void> _onDone() async {
  setState(() => _isLoading = true);
  try {
    // Store selected categories in profile
    widget.profile.categories = _selected.toList();

    // Send full onboarding data in one API call
    await ProfileService().submitOnboardingPreferences(
      detailPreference: _mapSubtaskPref(widget.profile.subtaskPreference),
      workPace: _mapTimePref(widget.profile.timePreference),
      interestedTags: _mapTags(widget.profile.categories),
    );

    // Navigate to dashboard
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard',
      (route) => false,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('온보딩 실패: $e')),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

Future<void> _showAddCategoryDialog() async {
  String newCategory = '';
  final controller = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('새 카테고리 추가'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: '카테고리 이름'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () {
            newCategory = controller.text.trim();
            Navigator.pop(context);
          },
          child: const Text('추가'),
        ),
      ],
    ),
  );

  if (newCategory.isNotEmpty) {
    try {
      setState(() => _isLoading = true);
      await TaskService().createProjectTag(newCategory); // 🔗 Call backend API
      setState(() {
        _allCategories.add(newCategory);
        _selected.add(newCategory);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 추가 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 55),
                      const StepProgress(currentStep: 4, totalSteps: 4),
                      const SizedBox(height: 200),

                      // Title + subtitle
                      const Text(
                        '원하는 카테고리를 선택하세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '카테고리는 언제든지 추가하거나 삭제할 수 있습니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Category chips wrap
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final cat in _allCategories)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selected.contains(cat)) {
                                    _selected.remove(cat);
                                  } else {
                                    _selected.add(cat);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: ShapeDecoration(
                                  color: _selected.contains(cat)
                                      ? const Color(0xFFF2AC57)
                                      : const Color(0x331D1B20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 16,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      cat,
                                      style: TextStyle(
                                        color: _selected.contains(cat)
                                            ? Colors.white
                                            : const Color(0xFF757575),
                                        fontSize: 14,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        height: 1,
                                      ),
                                    ),
                                    if (_selected.contains(cat)) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                          // "카테고리 추가" button
                          GestureDetector(
                            onTap: _showAddCategoryDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFB1B1B1),
                                  ),
                                ),
                              ),
                              child: const Text(
                                '카테고리 추가',
                                style: TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Previous / Done buttons
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
                                    text: '완료',
                                    onPressed: _onDone,
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
