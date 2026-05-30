import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../utils/ad_helper.dart';
import '../../utils/utils.dart';
import '../../utils/calculation_history.dart';
import '../reusable/flex_form.dart';
import '../reusable/sip_maturity.dart';

class StepUpSipScreen extends StatefulWidget {
  const StepUpSipScreen({super.key});

  @override
  State<StepUpSipScreen> createState() => _StepUpSipScreenState();
}

class _StepUpSipScreenState extends State<StepUpSipScreen> {
  // ── Result state ───────────────────────────────────────────────────────────
  bool _isReady = false;
  int _maturityValue = 0;
  int _totalInvested = 0;
  int _estimatedReturns = 0;

  // ── Ads & review ──────────────────────────────────────────────────────────
  BannerAd? _bannerAd;
  final _inAppReview = InAppReview.instance;
  final _scrollController = ScrollController();

  // ── Form field definitions ────────────────────────────────────────────────
  /// Step-Up % allows 0 (0% = behaves like a standard monthly SIP).
  static final _fields = [
    FieldDef(
      label: 'Monthly Investment',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
    FieldDef(
      label: 'Annual Step-Up %',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      placeholder: '10.0',
      allowZero: true, // 0% step-up is valid
    ),
    FieldDef(
      label: 'Expected Return %',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      placeholder: '12.0',
    ),
    FieldDef(
      label: 'Period (Years)',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
  ];

  @override
  void initState() {
    super.initState();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _bannerAd = ad as BannerAd),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Calculation ────────────────────────────────────────────────────────────
  /// values[0]=P (monthly investment)  values[1]=g (step-up %)
  /// values[2]=r (annual return %)      values[3]=n (years)
  void _onCalculate(List<double> values) async {
    final P = values[0];
    final g = values[1] / 100; // convert % to decimal
    final r = values[2] / 1200; // monthly rate
    final n = values[3].toInt();
    final totalMonths = n * 12;

    // Month-by-month accumulation: each month's investment compounds for
    // the remaining months at the monthly rate.
    double corpus = 0;
    for (int month = 0; month < totalMonths; month++) {
      final yearIdx = month ~/ 12;
      final monthlyAmt = P * pow(1 + g, yearIdx);
      corpus += monthlyAmt * pow(1 + r, totalMonths - month);
    }

    // Total invested = sum of each year's 12 contributions
    double totalInvested = 0;
    for (int year = 0; year < n; year++) {
      totalInvested += P * pow(1 + g, year) * 12;
    }

    setState(() {
      _maturityValue = corpus.ceil();
      _totalInvested = totalInvested.ceil();
      _estimatedReturns = _maturityValue - _totalInvested;
      _isReady = true;
    });

    await CalculationHistoryStore.instance.save(
      calculatorType: 'stepUpSIP',
      inputs: {
        'principal': P,
        'stepUp': values[1],
        'rate': values[2],
        'years': values[3],
      },
      result: {
        'maturity': _maturityValue,
        'invested': _totalInvested,
        'returns': _estimatedReturns,
      },
      locale: Utils.locale,
    );

    _scrollToBottom();
    await _maybeRequestReview();
  }

  void _onReset() => setState(() => _isReady = false);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _maybeRequestReview() async {
    final count = await Utils().readCounter();
    if (count >= 5) {
      if (await _inAppReview.isAvailable()) _inAppReview.requestReview();
      await Utils().resetCounter();
    } else {
      await Utils().incrementCounter();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step-Up SIP Calculator')),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                FlexForm(
                  fields: _fields,
                  onCalculate: _onCalculate,
                  onReset: _onReset,
                ),
                if (_isReady)
                  SipMaturity(
                    sipMaturityValue: _maturityValue,
                    initialInvestmentAmount: _totalInvested,
                    estimatedReturns: _estimatedReturns,
                    scrollForFocus: _scrollToBottom,
                    title1Text: 'Your Step-Up SIP corpus will be',
                    title2Text: 'Total Invested',
                    title3Text: 'Est. Returns',
                    hint1Text: 'Total Invested',
                    hint2Text: 'Est. Returns',
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          // Pinned banner ad at the bottom
          Column(
            children: [
              const Spacer(),
              if (_bannerAd != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
