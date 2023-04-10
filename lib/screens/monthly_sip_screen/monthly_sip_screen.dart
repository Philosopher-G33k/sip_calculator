import 'dart:math';

import 'package:flutter/material.dart';
import '../reusable/sip_form.dart';
import '../reusable/sip_maturity.dart';
import '../../utils/utils.dart';

import 'package:in_app_review/in_app_review.dart';

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

  void calculateMonthlySIP(double monthlyInvestment, double duration,
      double returnPercentage) async {
    final convertedPercentage = returnPercentage / 1200;
    final convertedDuration = duration * 12;
    final sipMaturityValue = (monthlyInvestment *
        (pow(1 + convertedPercentage, convertedDuration) - 1) *
        ((1 + convertedPercentage) / (convertedPercentage)));

    setState(() {
      this.sipMaturityValue = sipMaturityValue.toInt();
      initialInvestmentAmount = (monthlyInvestment * convertedDuration).toInt();
      estimatedReturns = this.sipMaturityValue - initialInvestmentAmount;
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
        title: const Text("Monthly SIP Calculator"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SipForm(
                calculateSIPWith: calculateMonthlySIP,
                resetHandler: resetHanlder,
                investmentFieldTitle: "Monthly Investment",
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
