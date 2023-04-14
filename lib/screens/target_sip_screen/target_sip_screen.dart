import 'dart:math';

import 'package:flutter/material.dart';
import '../reusable/sip_form.dart';
import '../reusable/sip_maturity.dart';

import '../../utils/utils.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utils/ad_helper.dart';

class TargetSipScreen extends StatefulWidget {
  const TargetSipScreen({super.key});

  @override
  State<TargetSipScreen> createState() => _TargetSipScreenState();
}

class _TargetSipScreenState extends State<TargetSipScreen> {
  var isSIPCalculationReady = false;

  var sipMaturityValue = 0;
  var initialInvestmentAmount = 0;
  var estimatedReturns = 0;

  BannerAd? _bannerAd;

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
      double targetSavings, double duration, double returnPercentage) async {
    final convertedPercentage = returnPercentage / 1200;
    final convertedDuration = duration * 12;
    final monthlyInvestment = (targetSavings) /
        ((pow(1 + convertedPercentage, convertedDuration) - 1) *
            ((1 + convertedPercentage).toInt() / (convertedPercentage)).ceil());

    setState(() {
      sipMaturityValue = monthlyInvestment.toInt();
      initialInvestmentAmount = (monthlyInvestment * convertedDuration).toInt();
      estimatedReturns = (targetSavings - initialInvestmentAmount).toInt();
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
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Target Savings Calculator"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SipForm(
                    calculateSIPWith: calculateMonthlySIP,
                    resetHandler: resetHanlder,
                    investmentFieldTitle: "Target Savings",
                  ),
                  if (isSIPCalculationReady)
                    SipMaturity(
                      sipMaturityValue: sipMaturityValue.toString(),
                      estimatedReturns: estimatedReturns.toString(),
                      initialInvestmentAmount:
                          initialInvestmentAmount.toString(),
                      title1Text:
                          "Your monthly investments to meet your target would be",
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
