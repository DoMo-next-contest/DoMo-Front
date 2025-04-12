import 'package:flutter/material.dart';
import 'package:domo/utils/responsive.dart';
import 'package:domo/utils/constants.dart';
import 'package:domo/screens/welcome/components/background.dart';

class OnboardingStep4 extends StatefulWidget {
  const OnboardingStep4({super.key});

  @override
  State<OnboardingStep4> createState() => _OnboardingStep4State();
}

class _OnboardingStep4State extends State<OnboardingStep4> {
  // List of available tags
  final List<String> _tags = ["업무", "학업", "운동", "일상", "자기계발"];
  // Currently selected tag (initially null)
  String? _selectedTag;

  void _next() {
    if (_selectedTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a tag")),
      );
      return;
    }
    debugPrint("Selected project custom tag: $_selectedTag");
    // Navigate to the next screen (for example, the dashboard) or complete onboarding.
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30),
        // Progress bar and step indicator
        Container(
          width: double.infinity,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 400, // Adjust this width to indicate progress for step 4/4
              height: 4,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Step 4/4',
          style: TextStyle(
            color: kTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Title
        const Center(
          child: Text(
            '프로젝트 커스텀 태그 선택',
            style: TextStyle(
              color: kTextColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '원하는 태그를 선택하세요',
          style: TextStyle(
            color: kTextColor,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Wrap the tags using ChoiceChips
        Wrap(
          spacing: defaultPadding,
          runSpacing: defaultPadding,
          alignment: WrapAlignment.center,
          children: _tags.map((tag) {
            return ChoiceChip(
              label: Text(tag),
              labelStyle: const TextStyle(color: Colors.white),
              selected: _selectedTag == tag,
              selectedColor: kPrimaryColor,
              backgroundColor: Colors.grey.shade400,
              onSelected: (bool selected) {
                setState(() {
                  _selectedTag = selected ? tag : null;
                });
              },
            );
          }).toList(),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _next,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
            backgroundColor: kPrimaryColor,
          ),
          child: const Text(
            'NEXT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // For mobile, use 90% of the screen width; for tablet and desktop, a fixed width of 393 px.
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;

    return Background(
      child: SafeArea(
        child: Responsive(
          mobile: Center(
            child: Container(
              width: containerWidth,
              height: screenHeight,
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(kBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: kCardShadow,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _buildContent(),
            ),
          ),
          tablet: Center(
            child: Container(
              width: 393.0,
              height: screenHeight,
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(kBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: kCardShadow,
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _buildContent(),
            ),
          ),
          desktop: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: Container(
                  width: 393.0,
                  height: constraints.maxHeight,
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: kCardShadow,
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
