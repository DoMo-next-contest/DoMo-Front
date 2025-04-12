import 'package:flutter/material.dart';
import 'package:domo/utils/responsive.dart';
import 'package:domo/screens/welcome/components/background.dart';
import 'package:domo/screens/welcome/components/login_signup_btn.dart';
import 'package:domo/screens/welcome/components/welcome_image.dart';
import 'package:domo/utils/constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Builds a white, rounded card to hold the welcome content.
  Widget _buildWelcomeCard({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
      // Center the content inside the card
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          WelcomeImage(),
          SizedBox(height: defaultPadding),
          LoginAndSignupBtn(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine width; for mobile, use 90% of screen width; otherwise, fixed 393 px.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;
    
    // Set a fixed height for the welcome card (adjust as needed).
    
    return Background(
      child: SafeArea(
        child: Responsive(
          mobile: Center(
            child: _buildWelcomeCard(
              width: containerWidth,
              height: screenHeight,
            ),
          ),
          tablet: Center(
            child: _buildWelcomeCard(
              width: 393.0,
              height: screenHeight,
            ),
          ),
          desktop: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: _buildWelcomeCard(
                  width: 393.0,
                  height: constraints.maxHeight,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
