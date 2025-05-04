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
import 'screens/profile_page.dart';
import 'screens/decor_page.dart';
import 'screens/onboarding/signup_step1.dart';
import 'screens/onboarding/signup_step2.dart';
import 'screens/onboarding/signup_step3.dart';
import 'screens/onboarding/signup_step4.dart';

/// A built-in “demo” profile, used if you don’t explicitly pass one.
final _defaultProfile = Profile(
  id: '0',
  name: '홍길동',
  username: 'userid',
  email: 'you@domain.com',
  subtaskPreference: '보통으로',
  timePreference: '타이트하게',
  categories: Task.allCategories,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved categories (if any)
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

      // Static routes that never need extra args:
      routes: {
        '/': (ctx) => const WelcomeScreen(),
        '/login': (ctx) => const LoginPage(),
        '/signup': (ctx) => const SignupStep1(),
        '/dashboard': (ctx) => const DashboardPage(),
        '/add': (ctx) => const AddPage(),
        '/project': (ctx) => const ProjectPage(),
        '/task': (ctx) => const TaskPage(),
      },

      onGenerateRoute: (settings) {
        // — Onboarding steps (require a Profile arg) —
        if (settings.name == '/signupStep2' ||
            settings.name == '/signupStep3' ||
            settings.name == '/signupStep4') {
          final args = settings.arguments;
          if (args is! Profile) {
            // If somehow no Profile was passed, restart onboarding
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

        // — Profile page — always supply a Profile, falling back to our default
        if (settings.name == '/profile') {
          final maybeProfile = settings.arguments;
          final profile = (maybeProfile is Profile) ? maybeProfile : _defaultProfile;
          return MaterialPageRoute(
            builder: (_) => ProfilePage(profile: profile),
            settings: settings,
          );
        }

        if (settings.name == '/decor') {
                  final maybeProfile = settings.arguments;
                  final profile = (maybeProfile is Profile) ? maybeProfile : _defaultProfile;
                  return MaterialPageRoute(
                    builder: (_) => DecorPage(profile: profile),
                    settings: settings,
                  );
                }

        // — Fallback to any other static route —
        final pageBuilder = routes[settings.name];
        if (pageBuilder != null) {
          return MaterialPageRoute(
            builder: pageBuilder,
            settings: settings,
          );
        }

        // — Unknown? Go home —
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
      },
    );
  }

  /// Mirror of our static `routes` map, for use in onGenerateRoute lookup
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
