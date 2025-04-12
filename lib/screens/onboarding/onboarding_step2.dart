import 'package:flutter/material.dart';
import 'package:domo/utils/responsive.dart';
import 'package:domo/utils/constants.dart';
import 'package:domo/screens/welcome/components/background.dart';

class OnboardingStep2 extends StatefulWidget {
  const OnboardingStep2({super.key});

  @override
  State<OnboardingStep2> createState() => _OnboardingStep2State();
}

class _OnboardingStep2State extends State<OnboardingStep2> {
  int _preference = 2; // Default rating for 하위작업 세부화 선호도

  /// Called when the "NEXT" button is pressed.
  /// Here you could save the value and navigate to the next step.
  void _next() {
    debugPrint("하위작업 세부화 선호도 selected: $_preference");
    // Navigate to Step 3 (update the route as needed)
    Navigator.pushReplacementNamed(context, '/onboardingStep3');
  }

  /// Builds the content for Step 2.
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30),
        // Progress bar and step text
        Container(
          width: double.infinity,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFFEEEEEE), // Light gray progress bar background
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 180, // Indicates progress (adjust as needed)
              height: 4,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Step 2/4',
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
            '하위작업 세부화 선호도',
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
        // Instruction text
        const Text(
          '1: 최소 세부화, 3: 최대 세부화',
          style: TextStyle(
            color: kTextColor,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        // Slider for preference rating
        Slider(
          value: _preference.toDouble(),
          min: 1,
          max: 3,
          divisions: 2,
          label: _preference.toString(),
          activeColor: kPrimaryColor,
          onChanged: (value) {
            setState(() {
              _preference = value.toInt();
            });
          },
        ),
        const Spacer(),
        // NEXT button
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // For mobile, use 90% of screen width; for tablet and desktop, fixed width.
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
