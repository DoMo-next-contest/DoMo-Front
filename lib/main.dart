import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/add_page.dart';
import 'screens/project_page.dart';
import 'screens/task_page.dart';


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
      initialRoute: '/dashboard',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/add':(context) => const AddPage(),
        '/project':(context) => const ProjectPage(),
        '/task': (context) => const TaskPage(),
        // Add other routes as needed
      },
      debugShowCheckedModeBanner: false,
    );
  }
}