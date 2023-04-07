import 'dart:math';

import 'package:flutter/material.dart';
import '../reusable/sip_form.dart';
import '../reusable/sip_maturity.dart';

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
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
      double targetSavings, double duration, double returnPercentage) {
    final convertedPercentage = returnPercentage / 1200;
    final convertedDuration = duration * 12;
    final monthlyInvestment = (targetSavings) /
        ((pow(1 + convertedPercentage, convertedDuration) - 1) *
            ((1 + convertedPercentage).toInt() / (convertedPercentage)).ceil());

    setState(() {
      sipMaturityValue = monthlyInvestment.toInt();
      initialInvestmentAmount = (monthlyInvestment * 12 * 20).toInt();
      estimatedReturns = (targetSavings - monthlyInvestment * 12 * 20).toInt();
      isSIPCalculationReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EMI Calculator"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SipForm(
                calculateSIPWith: calculateMonthlySIP,
                resetHandler: resetHanlder,
                investmentFieldTitle: "Loan Amount",
                percentageFieldTitle: "Interest Rate",
              ),
              if (isSIPCalculationReady)
                SipMaturity(
                  sipMaturityValue: sipMaturityValue.toString(),
                  estimatedReturns: estimatedReturns.toString(),
                  initialInvestmentAmount: initialInvestmentAmount.toString(),
                  title1Text: "Your monthly EMI's would be",
                ),
            ],
          ),
        ),
      ),
    );
  }
}
