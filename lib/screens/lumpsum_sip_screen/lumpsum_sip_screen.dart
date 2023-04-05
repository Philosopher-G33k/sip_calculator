import 'dart:math';

import 'package:flutter/material.dart';
import '../reusable/sip_form.dart';
import '../reusable/sip_maturity.dart';

class LumpsumSipScreen extends StatefulWidget {
  const LumpsumSipScreen({super.key});

  @override
  State<LumpsumSipScreen> createState() => _LumpsumSipScreenState();
}

class _LumpsumSipScreenState extends State<LumpsumSipScreen> {
  var isSIPCalculationReady = false;

  var sipMaturityValue = 0;
  var initialInvestmentAmount = 0;
  var estimatedReturns = 0;

  void resetHanlder() {
    setState(() {
      isSIPCalculationReady = false;
    });
  }

  void calculateLumpSumSIP(
      double lumpsumInvestment, double duration, double returnPercentage) {
    final convertedPercentage = returnPercentage / 100;
    final convertedDuration = duration;
    final sipMaturityValue =
        (lumpsumInvestment * (pow(1 + convertedPercentage, convertedDuration)));

    setState(() {
      this.sipMaturityValue = sipMaturityValue.toInt();
      initialInvestmentAmount = (lumpsumInvestment).toInt();
      estimatedReturns = this.sipMaturityValue - initialInvestmentAmount;
      isSIPCalculationReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sip Calculator"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SipForm(
                calculateSIPWith: calculateLumpSumSIP,
                resetHandler: resetHanlder,
                investmentFieldTitle: "Lumpsum Investment",
              ),
              if (isSIPCalculationReady)
                SipMaturity(
                    sipMaturityValue: sipMaturityValue.toString(),
                    estimatedReturns: estimatedReturns.toString(),
                    initialInvestmentAmount:
                        initialInvestmentAmount.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
