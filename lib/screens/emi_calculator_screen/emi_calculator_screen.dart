import 'dart:math';

import 'package:flutter/material.dart';
import '../reusable/sip_form.dart';
import '../reusable/sip_maturity.dart';

import '../../utils/utils.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utils/ad_helper.dart';

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

  BannerAd? _bannerAd;

  final ScrollController _scrollController = ScrollController();

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
  void initState() {
    super.initState();

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EMI Calculator"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
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
                      sipMaturityValue: monthlyEMI,
                      estimatedReturns: totalAmount,
                      initialInvestmentAmount: interestPaid,
                      scrollForFocus: scrollToBottom,
                      title1Text: "Your monthly EMI's would be",
                      title2Text: "Interest Paid",
                      title3Text: "Total Amount",
                      hint1Text: "Principle",
                      hint2Text: "Interest",
                      isEMICalculation: true,
                    ),
                  const SizedBox(
                    width: double.infinity,
                    height: 50,
                  )
                ],
              ),
            ),
          ),
          Column(
            children: [
              const Spacer(),
              if (_bannerAd != null)
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
