import 'dart:math';

import 'package:flutter/material.dart';
import '../history_screen/history_screen.dart';
import './sip_form.dart';

class MonthlySipScreen extends StatefulWidget {
  const MonthlySipScreen({super.key});

  @override
  State<MonthlySipScreen> createState() => _MonthlySipScreenState();
}

class _MonthlySipScreenState extends State<MonthlySipScreen> {
  void calculateMonthlySIP(
      double monthlyInvestment, double duration, double returnPercentage) {
    final convertedPercentage = returnPercentage / 1200;
    final convertedDuration = duration;
    final sipMaturityValue = (monthlyInvestment *
        (pow(1 + convertedPercentage, convertedDuration) - 1) *
        ((1 + convertedPercentage) / (convertedPercentage)));

    print("sipMaturityValue");
    print(sipMaturityValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sip Calculator"),
      ),
      body: Center(
        child: Column(
          children: [
            SipForm(
              calculateSIPWith: calculateMonthlySIP,
            ),
            TextButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalculationHistory()),
                ),
              },
              child: const Text("History"),
            )
          ],
        ),
      ),
    );
  }
}
