import 'dart:math';

import 'package:flutter/material.dart';
import '../reusable/sip_form.dart';
import '../reusable/sip_maturity.dart';

import '../../utils/utils.dart';
import 'package:in_app_review/in_app_review.dart';

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

  void calculateLumpSumSIP(double lumpsumInvestment, double duration,
      double returnPercentage) async {
    final convertedPercentage = returnPercentage / 100;
    final convertedDuration = duration;
    final sipMaturityValue =
        (lumpsumInvestment * (pow(1 + convertedPercentage, convertedDuration)));

    setState(() {
      this.sipMaturityValue = sipMaturityValue.ceil();
      initialInvestmentAmount = (lumpsumInvestment).ceil();
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
        title: const Text("Lumpsum SIP Calculator"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
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
                      sipMaturityValue: sipMaturityValue,
                      estimatedReturns: estimatedReturns,
                      initialInvestmentAmount: initialInvestmentAmount,
                      scrollForFocus: scrollToBottom,
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
