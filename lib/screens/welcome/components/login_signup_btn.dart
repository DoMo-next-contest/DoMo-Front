import 'package:flutter/material.dart';
import 'package:domo/utils/constants.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Login Button using named route navigation
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor, // Defined in constants.dart
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
          ),
          child: const Text(
            "LOGIN",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Signup Button using named route navigation
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/signup');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryLightColor, // Defined in constants.dart
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
          ),
          child: const Text(
            "SIGN UP",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
