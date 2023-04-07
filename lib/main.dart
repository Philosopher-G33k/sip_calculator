import 'package:flutter/material.dart';
import './screens/emi_calculator_screen/emi_calculator_screen.dart';
import './screens/monthly_sip_screen/monthly_sip_screen.dart';
import './screens/lumpsum_sip_screen/lumpsum_sip_screen.dart';
import './screens/target_sip_screen/target_sip_screen.dart';

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
      home: const EMICalculatorScreen(),
    );
  }
}
