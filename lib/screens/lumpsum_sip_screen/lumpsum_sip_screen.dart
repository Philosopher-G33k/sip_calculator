import 'dart:math';

import 'package:flutter/material.dart';
import '../reusable/sip_form.dart';
import '../reusable/sip_maturity.dart';

import '../../utils/utils.dart';
import 'package:in_app_review/in_app_review.dart';

// TODO: Import google_mobile_ads.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utils/ad_helper.dart';

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

  void calculateLumpSumSIP(double lumpsumInvestment, double duration,
      double returnPercentage) async {
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

    // TODO: Load a banner ad
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
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
        title: const Text("Lumpsum SIP Calculator"),
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
