import 'package:flutter/material.dart';
import 'package:domo/utils/constants.dart';
import 'package:domo/screens/welcome/components/already_have_an_account_acheck.dart';
import 'package:domo/screens/login/login_page.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String password = '';
    String confirmPassword = '';

    void onSubmit() {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        if (password != confirmPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Passwords do not match")),
          );
          return;
        }
        debugPrint('Signing up with Name: $name, Email: $email, Password: $password');
        // Navigate to the onboarding Step 2 page
        Navigator.pushReplacementNamed(context, '/onboardingStep2');
      }
    }

    InputDecoration buildInputDecoration(String hintText, IconData icon) {
      return InputDecoration(
        hintText: hintText,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Icon(icon, color: kPrimaryColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      );
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Name field
          TextFormField(
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (value) => name = value!,
            decoration: buildInputDecoration("Your name", Icons.person),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your name";
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          // Email field
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (value) => email = value!,
            decoration: buildInputDecoration("Your email", Icons.email),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              }
              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                return "Enter a valid email";
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          // Password field
          TextFormField(
            textInputAction: TextInputAction.next,
            obscureText: true,
            cursorColor: kPrimaryColor,
            onSaved: (value) => password = value!,
            decoration: buildInputDecoration("Your password", Icons.lock),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your password";
              }
              if (value.length < 6) {
                return "Password should be at least 6 characters";
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          // Confirm Password field
          TextFormField(
            textInputAction: TextInputAction.done,
            obscureText: true,
            cursorColor: kPrimaryColor,
            onSaved: (value) => confirmPassword = value!,
            decoration: buildInputDecoration("Re-enter your password", Icons.lock_outline),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please confirm your password";
              }
              return null;
            },
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
            ),
            child: Text("SIGN UP".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
