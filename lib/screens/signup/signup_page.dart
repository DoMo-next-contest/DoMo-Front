import 'package:flutter/material.dart';
import 'package:domo/utils/responsive.dart';
import 'package:domo/utils/constants.dart';
import 'package:domo/screens/welcome/components/background.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _password = '';

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      debugPrint('Signing up with Name: $_name, Email: $_email, Password: $_password');
      // Navigate or show next step. For now, just pop.
      Navigator.pushReplacementNamed(context, '/onboardingStep2');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Screen size for responsive layout
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;

    return Background(
      child: SafeArea(
        child: Responsive(
          mobile: Center(
            child: Container(
              width: containerWidth,
              height: screenHeight, // Fill entire screen height
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: _buildSignUpContent(context),
            ),
          ),
          tablet: Center(
            child: Container(
              width: 393.0,
              height: screenHeight,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: _buildSignUpContent(context),
            ),
          ),
          desktop: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: Container(
                  width: 393.0,
                  height: constraints.maxHeight, // Fill available desktop height
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: _buildSignUpContent(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the actual sign-up fields, progress bar, and buttons.
  Widget _buildSignUpContent(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          // Progress bar
          Container(
            width: double.infinity,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE), // Light gray bar
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 80, // ~1/4 of the bar for "Step 1/4"
                height: 4,
                color: kPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Step text
          const Text(
            'Step 1/4',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // Title
          const Center(
            child: Text(
              'Domo에 가입하세요',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // "Your name *" field
          const Text(
            'Your name *',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            child: TextFormField(
              decoration: const InputDecoration.collapsed(
                hintText: 'Enter your name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your name";
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
          ),

          const SizedBox(height: 24),
          // "Your email *" field
          const Text(
            'Your email *',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            child: TextFormField(
              decoration: const InputDecoration.collapsed(
                hintText: 'hello@relume.io',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your email";
                }
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                  return "Enter a valid email";
                }
                return null;
              },
              onSaved: (value) => _email = value!,
            ),
          ),

          const SizedBox(height: 24),
          // "Your password *" field
          const Text(
            'Your password *',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            child: TextFormField(
              decoration: const InputDecoration.collapsed(
                hintText: '********',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your password";
                }
                if (value.length < 6) {
                  return "Password should be at least 6 characters";
                }
                return null;
              },
              onSaved: (value) => _password = value!,
            ),
          ),

          const SizedBox(height: 24),
          // Action buttons: Cancel and Next
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cancel
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    // Cancel -> navigate back to login, for example
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Next
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: const ShapeDecoration(
                  color: kPrimaryLightColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                child: TextButton(
                  onPressed: _onSubmit,
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
