import 'package:flutter/material.dart';

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
      // Navigate to the dashboard after login success.
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // For phone devices, use 90% of width; else fixed width.
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : 393.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 32, 47),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: containerWidth,
              height: screenHeight,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(color: Colors.white),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    // Title
                    const Center(
                      child: Text(
                        'Login to Domo',
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
                    // Email field
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
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Colors.black),
                        ),
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Enter your email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                              .hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value!,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Password field
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
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Colors.black),
                        ),
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Enter your password',
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
                    // Action buttons: Sign Up and Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/signup');
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: ShapeDecoration(
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                          child: TextButton(
                            onPressed: _submit,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
