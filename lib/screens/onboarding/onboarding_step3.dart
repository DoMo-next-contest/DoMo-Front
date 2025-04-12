import 'package:flutter/material.dart';
import 'package:domo/utils/responsive.dart';
import 'package:domo/utils/constants.dart';
import 'package:domo/screens/welcome/components/background.dart';

class OnboardingStep3 extends StatefulWidget {
  const OnboardingStep3({super.key});

  @override
  State<OnboardingStep3> createState() => _OnboardingStep3State();
}

class _OnboardingStep3State extends State<OnboardingStep3> {
  int _timePreference = 2; // Default value: 2 out of 1-3

  void _next() {
    debugPrint("시간 여유 성향 selected: $_timePreference");
    // Navigate to Onboarding Step 4; make sure this route is defined in your main.dart.
    Navigator.pushReplacementNamed(context, '/onboardingStep4');
  }

  /// Builds the content of Step 3.
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
              width: 260, // Adjust to represent progress for step 3/4
              height: 4,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Step 3/4',
          style: TextStyle(
            color: kTextColor, // Assume defined in constants.dart
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Title for this step
        const Center(
          child: Text(
            '시간 여유 성향',
            style: TextStyle(
              color: kTextColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        // Instruction text (you can update this as needed)
        const Text(
          '1: 매우 부족, 3: 매우 여유',
          style: TextStyle(
            color: kTextColor,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        // Slider to choose preference value
        Slider(
          value: _timePreference.toDouble(),
          min: 1,
          max: 3,
          divisions: 2,
          label: _timePreference.toString(),
          activeColor: kPrimaryColor,
          onChanged: (value) {
            setState(() {
              _timePreference = value.toInt();
            });
          },
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
    // Responsive layout: use 90% width on mobile, fixed width on tablet and desktop.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;

    return Background(
      child: SafeArea(
        child: Responsive(
          // Mobile layout
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
          // Tablet layout
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
          // Desktop layout
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
