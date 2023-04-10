import 'dart:math';

import 'package:flutter/material.dart';
import '../reusable/sip_form.dart';
import '../reusable/sip_maturity.dart';

import '../../utils/utils.dart';
import 'package:in_app_review/in_app_review.dart';

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  var isSIPCalculationReady = false;

  var monthlyEMI = 0;
  var interestPaid = 0;
  var totalAmount = 0;

  final InAppReview _inAppReview = InAppReview.instance;

  void resetHanlder() {
    setState(() {
      isSIPCalculationReady = false;
    });
  }

  void _requestReview() async {
    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
    }
  }

  void calculateMonthlySIP(
      double loanAmount, double duration, double returnPercentage) async {
    final convertedPercentage = returnPercentage / 1200;
    final convertedDuration = duration * 12;
    final monthlyEMI = (loanAmount *
            convertedPercentage *
            (pow(1 + convertedPercentage, convertedDuration))) /
        (pow(1 + convertedPercentage, convertedDuration) - 1);

    setState(() {
      this.monthlyEMI = monthlyEMI.toInt();
      totalAmount = (monthlyEMI * convertedDuration).toInt();
      interestPaid = (totalAmount - loanAmount).toInt();
      isSIPCalculationReady = true;
    });

    int counter = await Utils().readCounter();
    if (counter >= 5) {
      // Show the prompt
      // Reset the counter
      _requestReview();
      await Utils().resetCounter();
    } else {
      await Utils().incrementCounter();
    }
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
                  sipMaturityValue: monthlyEMI.toString(),
                  estimatedReturns: totalAmount.toString(),
                  initialInvestmentAmount: interestPaid.toString(),
                  title1Text: "Your monthly EMI's would be",
                  title2Text: "Interest Paid",
                  title3Text: "Total Amount",
                ),
            ],
          ),
        ),
      ),
    );
  }
}
