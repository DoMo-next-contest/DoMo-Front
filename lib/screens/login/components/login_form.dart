import 'package:flutter/material.dart';
import 'package:domo/utils/constants.dart';
import 'package:domo/screens/signup/signup_page.dart';
import 'package:domo/screens/welcome/components/already_have_an_account_acheck.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final FormFieldSetter<String> onEmailSaved;
  final FormFieldSetter<String> onPasswordSaved;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.onSubmit,
    required this.onEmailSaved,
    required this.onPasswordSaved,
  });

  InputDecoration _buildInputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Icon(icon),
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Text(
            "LOGIN",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 40),

          // Email field
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: onEmailSaved,
            decoration: _buildInputDecoration("Your email", Icons.email),
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
            textInputAction: TextInputAction.done,
            obscureText: true,
            cursorColor: kPrimaryColor,
            onSaved: onPasswordSaved,
            decoration: _buildInputDecoration("Your password", Icons.lock),
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
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
            ),
            child: Text(
              "LOGIN".toUpperCase(),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignupPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
