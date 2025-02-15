import 'package:flutter/material.dart';
import 'package:kaloriku/view/screen/bottom_navbar.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:kaloriku/view/screen/home_page.dart';
import 'package:kaloriku/view/screen/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isAuthenticated = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    bool authStatus = await AuthManager.isLoggedIn();
    setState(() {
      isAuthenticated = authStatus;
      isLoading = false;
    });
  }

 @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaloriKu',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isAuthenticated ? const DynamicBottomNavbar() : const LoginPage(),
    );
  }
}
