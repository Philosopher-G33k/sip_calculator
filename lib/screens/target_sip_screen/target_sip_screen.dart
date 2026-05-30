import 'dart:math';

import 'package:flutter/material.dart';
import '../reusable/sip_form.dart';
import '../reusable/sip_maturity.dart';

import '../../utils/utils.dart';
import '../../utils/calculation_history.dart';
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

  // Formula corrected in Phase 0 (2026-05-31): the original shipped formula used
  // (1+r).toInt() == 1, making the divisor degenerate. Replaced with the correct
  // inverse annuity-due formula. User-visible results change by ~1% for typical inputs.
  // BA sign-off obtained: behavioral change is intentional for accuracy.
  void calculateMonthlySIP(
      double targetSavings, double duration, double returnPercentage) async {
    final r = returnPercentage / 1200; // monthly rate
    final N = duration * 12; // total months

    // Exact inverse of the Monthly SIP annuity-due formula:
    //   FV = P × [(1+r)^N − 1] × (1+r) / r
    //   ⟹ P = FV × r / [(1+r)^N − 1] / (1+r)
    final monthlyInvestment =
        (targetSavings * r) / ((pow(1 + r, N) - 1) * (1 + r));

    setState(() {
      sipMaturityValue = monthlyInvestment.ceil();
      initialInvestmentAmount = (monthlyInvestment * N).ceil();
      estimatedReturns = (targetSavings - initialInvestmentAmount).toInt();
      isSIPCalculationReady = true;
    });

    await CalculationHistoryStore.instance.save(
      calculatorType: 'targetSIP',
      inputs: {
        'target': targetSavings,
        'years': duration,
        'rate': returnPercentage,
      },
      result: {
        'requiredMonthly': monthlyInvestment.ceil(),
        'invested': initialInvestmentAmount,
        'returns': estimatedReturns,
      },
      locale: Utils.locale,
    );

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

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Target Savings Calculator"),
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
                    investmentFieldTitle: "Target Savings",
                  ),
                  if (isSIPCalculationReady)
                    SipMaturity(
                      sipMaturityValue: sipMaturityValue,
                      estimatedReturns: estimatedReturns,
                      initialInvestmentAmount: initialInvestmentAmount,
                      scrollForFocus: scrollToBottom,
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
