import 'package:flutter/material.dart';
import 'screens/welcome/welcome_page.dart';
import 'screens/login/login_page.dart';
import 'screens/signup/signup_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/add_page.dart';
import 'screens/project_page.dart';
import 'screens/task_page.dart';
import 'screens/onboarding/onboarding_step2.dart';
import 'screens/onboarding/onboarding_step3.dart';
import 'screens/onboarding/onboarding_step4.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoMo App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/', // Set the initial route to the welcome page
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/add': (context) => const AddPage(),
        '/project': (context) => const ProjectPage(),
        '/task': (context) => const TaskPage(),
        '/onboardingStep2': (context) => const OnboardingStep2(),
        '/onboardingStep3': (context) => const OnboardingStep3(),
        '/onboardingStep4': (context) => const OnboardingStep4(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
