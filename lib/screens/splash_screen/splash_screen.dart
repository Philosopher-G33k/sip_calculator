import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'dart:async';

import '../landing_screen/landing_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = Timer(
      const Duration(seconds: 5),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LandingScreen(),
          ),
        );
      },
    );
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Lottie.asset('assets/animations/finance_animation2.json'),
        ),
      ),
    );
  }
}
