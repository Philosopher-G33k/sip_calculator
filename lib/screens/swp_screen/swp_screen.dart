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

enum _SwpMode { fixedPeriod, untilDepleted }

class SwpScreen extends StatefulWidget {
  const SwpScreen({super.key});

  @override
  State<SwpScreen> createState() => _SwpScreenState();
}

class _SwpScreenState extends State<SwpScreen> {
  // ── Mode selection ─────────────────────────────────────────────────────────
  _SwpMode _mode = _SwpMode.fixedPeriod;

  // ── Result state ───────────────────────────────────────────────────────────
  bool _isReady = false;

  /// Mode A results — fixed period
  int _remainingCorpus = 0;
  int _totalWithdrawn = 0;
  int _initialCorpus = 0;

  /// Mode B results — until depleted
  int _exYears = 0;
  int _exMonths = 0;
  bool _neverDepletes = false;

  // ── Ads & review ──────────────────────────────────────────────────────────
  BannerAd? _bannerAd;
  final _inAppReview = InAppReview.instance;
  final _scrollController = ScrollController();

  // ── Field definitions ─────────────────────────────────────────────────────

  /// Mode A: all four fields active
  static final _modeAFields = [
    FieldDef(
      label: 'Total Corpus',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
    FieldDef(
      label: 'Monthly Withdrawal',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
    FieldDef(
      label: 'Expected Return %',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      placeholder: '8.0',
    ),
    FieldDef(
      label: 'Period (Years)',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
  ];

  /// Mode B: Period greyed-out — the screen calculates it
  static final _modeBFields = [
    FieldDef(
      label: 'Total Corpus',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
    FieldDef(
      label: 'Monthly Withdrawal',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
    ),
    FieldDef(
      label: 'Expected Return %',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      placeholder: '8.0',
    ),
    FieldDef(
      label: 'Period (Years)',
      keyboardType: TextInputType.number,
      formatters: [FilteringTextInputFormatter.digitsOnly],
      isOptional: true, // computed by the formula
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
  /// values[0]=C (corpus)  values[1]=W (monthly withdrawal)
  /// values[2]=r (annual return %)  values[3]=n (years; 0 in Mode B)
  void _onCalculate(List<double> values) async {
    final C = values[0];
    final W = values[1];
    final r = values[2] / 1200; // monthly rate

    if (_mode == _SwpMode.fixedPeriod) {
      // ── Mode A: remaining corpus after n years of withdrawals ───────────
      // R = C × (1+r)^N − W × [(1+r)^N − 1] / r
      final totalMonths = values[3].toInt() * 12;
      final double remaining;
      if (r == 0) {
        remaining = C - W * totalMonths;
      } else {
        final growth = pow(1 + r, totalMonths).toDouble();
        remaining = C * growth - W * (growth - 1) / r;
      }
      final totalWithdrawn = W * totalMonths;

      setState(() {
        _remainingCorpus =
            remaining.round().clamp(0, double.maxFinite.toInt());
        _totalWithdrawn = totalWithdrawn.round();
        _initialCorpus = C.round();
        _isReady = true;
      });
    } else {
      // ── Mode B: how many months until corpus is depleted? ───────────────
      // If W ≤ C × r: monthly returns ≥ withdrawals → corpus never depletes
      // If r = 0:     months = floor(C / W)
      // Otherwise:    months = floor( -ln(1 − C·r/W) / ln(1+r) )
      if (r > 0 && W <= C * r) {
        setState(() {
          _neverDepletes = true;
          _exYears = 0;
          _exMonths = 0;
          _isReady = true;
        });
      } else {
        final int totalMonths;
        if (r == 0) {
          totalMonths = (C / W).floor();
        } else {
          totalMonths = (-log(1 - C * r / W) / log(1 + r)).floor();
        }
        setState(() {
          _neverDepletes = false;
          _exYears = totalMonths ~/ 12;
          _exMonths = totalMonths % 12;
          _isReady = true;
        });
      }
    }

    await _saveHistory(values);

    _scrollToBottom();
    await _maybeRequestReview();
  }

  Future<void> _saveHistory(List<double> values) async {
    final Map<String, int> result;
    if (_mode == _SwpMode.fixedPeriod) {
      result = {
        'remainingCorpus': _remainingCorpus,
        'totalWithdrawn': _totalWithdrawn,
        'initialCorpus': _initialCorpus,
      };
    } else {
      result = {
        'neverDepletes': _neverDepletes ? 1 : 0,
        'years': _exYears,
        'months': _exMonths,
      };
    }
    await CalculationHistoryStore.instance.save(
      calculatorType: 'swp',
      inputs: {
        'corpus': values[0],
        'withdrawal': values[1],
        'rate': values[2],
        'years': values[3],
      },
      result: result,
      locale: Utils.locale,
    );
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

  // ── Build helpers ──────────────────────────────────────────────────────────

  Widget _buildSegmentedButton() {
    return SegmentedButton<_SwpMode>(
      segments: const [
        ButtonSegment(
          value: _SwpMode.fixedPeriod,
          label: Text('Fixed Period'),
          icon: Icon(Icons.calendar_month_outlined, size: 18),
        ),
        ButtonSegment(
          value: _SwpMode.untilDepleted,
          label: Text('Until Depleted'),
          icon: Icon(Icons.hourglass_bottom_rounded, size: 18),
        ),
      ],
      selected: {_mode},
      onSelectionChanged: (selection) => setState(() {
        _mode = selection.first;
        _isReady = false;
      }),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Result card for Mode B — shows duration, no pie chart.
  Widget _buildExhaustionResult() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Blue gradient header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                children: [
                  const Text(
                    'Your corpus will last',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _neverDepletes
                        ? 'Forever 🎉'
                        : _formatDuration(_exYears, _exMonths),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Explanatory subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Row(
                children: [
                  Icon(
                    _neverDepletes
                        ? Icons.all_inclusive_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: const Color(0xFF78909C),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _neverDepletes
                          ? 'Monthly returns cover your withdrawals — the corpus never depletes at this rate.'
                          : 'Approximate time until the corpus is fully withdrawn at the specified rate and return.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF78909C),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int years, int months) {
    if (years == 0 && months == 0) return '< 1 month';
    if (years == 0) return '$months month${months == 1 ? '' : 's'}';
    if (months == 0) return '$years year${years == 1 ? '' : 's'}';
    return '$years yr $months mo';
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final fields =
        _mode == _SwpMode.fixedPeriod ? _modeAFields : _modeBFields;

    return Scaffold(
      appBar: AppBar(title: const Text('SWP Calculator')),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                FlexForm(
                  key: ValueKey(_mode),
                  fields: fields,
                  onCalculate: _onCalculate,
                  onReset: _onReset,
                  headerSlot: _buildSegmentedButton(),
                ),
                if (_isReady) ...[
                  if (_mode == _SwpMode.fixedPeriod)
                    SipMaturity(
                      sipMaturityValue: _remainingCorpus,
                      initialInvestmentAmount: _totalWithdrawn,
                      estimatedReturns: _initialCorpus,
                      scrollForFocus: _scrollToBottom,
                      isSwpCalculation: true,
                      title1Text: 'Remaining corpus',
                      title2Text: 'Total Withdrawn',
                      title3Text: 'Remaining',
                      hint1Text: 'Total Withdrawn',
                      hint2Text: 'Remaining',
                    )
                  else
                    _buildExhaustionResult(),
                ],
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
