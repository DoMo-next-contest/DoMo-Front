import 'package:flutter/material.dart';
import 'package:domo/utils/responsive.dart';
import 'package:domo/screens/login/components/login_form.dart';
import 'package:domo/utils/constants.dart';
import 'package:domo/screens/welcome/components/background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      debugPrint('Logging in with Email: $_email, Password: $_password');
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  /// Builds the login card that holds the LoginForm.
  /// Padding is added at the top so the white card fills from top to bottom.
  Widget _buildLoginCard({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16), // horizontal margin only
      padding: const EdgeInsets.only(top: 100, left: 24, right: 24), // push form downwards
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Extra space at the top (already added in padding), then the login form.
          const SizedBox(height: 60),
          Expanded(
            child: LoginForm(
              formKey: _formKey,
              onSubmit: _submit,
              onEmailSaved: (value) => _email = value!,
              onPasswordSaved: (value) => _password = value!,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get device dimensions.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // For mobile, use 90% of screen width; otherwise, a fixed width of 393.
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;

    return Background(
      child: SafeArea(
        child: Responsive(
          // Mobile layout.
          mobile: Center(
            child: _buildLoginCard(
              width: screenWidth * 0.9,
              height: screenHeight,
            ),
          ),
          // Tablet layout.
          tablet: Center(
            child: _buildLoginCard(
              width: 393.0,
              height: screenHeight,
            ),
          ),
          // Desktop layout.
          desktop: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: _buildLoginCard(
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
