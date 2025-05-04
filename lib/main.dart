// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:domo/utils/mobile_frame.dart';
import 'package:domo/models/task.dart';
import 'package:domo/models/profile.dart';

import 'screens/welcome/welcome_page.dart';
import 'screens/login/login_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/add_page.dart';
import 'screens/project_page.dart';
import 'screens/task_page.dart';
import 'screens/onboarding/signup_step1.dart';
import 'screens/onboarding/signup_step2.dart';
import 'screens/onboarding/signup_step3.dart';
import 'screens/onboarding/signup_step4.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved categories (if any) and override the default list
  final prefs = await SharedPreferences.getInstance();
  final savedCats = prefs.getStringList('userCategories');
  if (savedCats != null && savedCats.isNotEmpty) {
    Task.allCategories = savedCats;
  }

  runApp(
    MobileFrame(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoMo App',
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',

      // Static routes for screens that don't need arguments
      routes: {
        '/': (ctx) => const WelcomeScreen(),
        '/login': (ctx) => const LoginPage(),
        '/signup': (ctx) => const SignupStep1(),
        '/dashboard': (ctx) => const DashboardPage(),
        '/add': (ctx) => const AddPage(),
        '/project': (ctx) => const ProjectPage(),
        '/task': (ctx) => const TaskPage(),
      },

      // Handle onboarding steps 2, 3, and 4 (all require a Profile)
      onGenerateRoute: (settings) {
        if (settings.name == '/signupStep2' ||
            settings.name == '/signupStep3' ||
            settings.name == '/signupStep4') {
          final args = settings.arguments;
          if (args is! Profile) {
            // If no Profile passed, send back to Step1
            return MaterialPageRoute(
              builder: (_) => const SignupStep1(),
              settings: settings,
            );
          }
          switch (settings.name) {
            case '/signupStep2':
              return MaterialPageRoute(
                builder: (_) => SignupStep2(profile: args),
                settings: settings,
              );
            case '/signupStep3':
              return MaterialPageRoute(
                builder: (_) => SignupStep3(profile: args),
                settings: settings,
              );
            case '/signupStep4':
              return MaterialPageRoute(
                builder: (_) => SignupStep4(profile: args),
                settings: settings,
              );
          }
        }

        // Fallback to static routes
        final pageBuilder = routes[settings.name];
        if (pageBuilder != null) {
          return MaterialPageRoute(
            builder: pageBuilder,
            settings: settings,
          );
        }

        // Unknown route → back to welcome
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
      },
    );
  }

  // Mirror of static routes for use in onGenerateRoute fallback
  static final Map<String, WidgetBuilder> routes = {
    '/': (ctx) => const WelcomeScreen(),
    '/login': (ctx) => const LoginPage(),
    '/signup': (ctx) => const SignupStep1(),
    '/dashboard': (ctx) => const DashboardPage(),
    '/add': (ctx) => const AddPage(),
    '/project': (ctx) => const ProjectPage(),
    '/task': (ctx) => const TaskPage(),
  };
}
