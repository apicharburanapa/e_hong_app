import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _logText = "ready in 3...";

  @override
  void initState() {
    super.initState();
    showLogAndNavigate();
  }

  void showLogAndNavigate() async {
    await Future.delayed(Duration(milliseconds: 1000));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
