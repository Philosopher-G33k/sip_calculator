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

  var monthlyEMI = 0;
  var interestPaid = 0;
  var totalAmount = 0;

  void resetHanlder() {
    setState(() {
      isSIPCalculationReady = false;
    });
  }

  void calculateMonthlySIP(
      double loanAmount, double duration, double returnPercentage) {
    final convertedPercentage = returnPercentage / 1200;
    final convertedDuration = duration * 12;
    final monthlyEMI = (loanAmount *
            convertedPercentage *
            (pow(1 + convertedPercentage, convertedDuration))) /
        (pow(1 + convertedPercentage, convertedDuration) - 1);

    setState(() {
      this.monthlyEMI = monthlyEMI.toInt();
      totalAmount = (monthlyEMI * 12 * 20).toInt();
      interestPaid = (monthlyEMI * 12 * 20 - loanAmount).toInt();
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
