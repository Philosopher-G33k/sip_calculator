import 'package:flutter/material.dart';
import 'package:sip_calculator/screens/splash_screen/splash_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
