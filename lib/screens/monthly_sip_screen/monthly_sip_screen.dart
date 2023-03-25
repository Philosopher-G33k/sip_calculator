import 'dart:math';

import 'package:flutter/material.dart';
import './sip_form.dart';
import '../reusable /sip_maturity.dart';

class MonthlySipScreen extends StatefulWidget {
  const MonthlySipScreen({super.key});

  @override
  State<MonthlySipScreen> createState() => _MonthlySipScreenState();
}

class _MonthlySipScreenState extends State<MonthlySipScreen> {
  var isSIPCalculationReady = false;

  var sipMaturityValue = 0;
  var initialInvestmentAmount = 0;
  var estimatedReturns = 0;

  void resetHanlder() {
    setState(() {
      isSIPCalculationReady = false;
    });
  }

  void calculateMonthlySIP(
      double monthlyInvestment, double duration, double returnPercentage) {
    final convertedPercentage = returnPercentage / 1200;
    final convertedDuration = duration;
    final sipMaturityValue = (monthlyInvestment *
        (pow(1 + convertedPercentage, convertedDuration) - 1) *
        ((1 + convertedPercentage) / (convertedPercentage)));

    print("sipMaturityValue");
    print(sipMaturityValue);

    setState(() {
      this.sipMaturityValue = sipMaturityValue.toInt();
      initialInvestmentAmount = (monthlyInvestment * duration).toInt();
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
                calculateSIPWith: calculateMonthlySIP,
                resetHandler: resetHanlder,
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
