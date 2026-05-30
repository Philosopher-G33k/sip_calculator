import 'package:flutter/material.dart';
import 'package:sip_calculator/screens/emi_calculator_screen/emi_calculator_screen.dart';
import 'package:sip_calculator/screens/lumpsum_sip_screen/lumpsum_sip_screen.dart';
import 'package:sip_calculator/screens/monthly_sip_screen/monthly_sip_screen.dart';
import 'package:sip_calculator/screens/settings_screen/settings_screen.dart';
import 'package:sip_calculator/screens/step_up_sip_screen/step_up_sip_screen.dart';
import 'package:sip_calculator/screens/swp_screen/swp_screen.dart';
import 'package:sip_calculator/screens/target_sip_screen/target_sip_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sip_calculator/utils/utils.dart';
import '../../utils/ad_helper.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();
    Utils().getDefaultLocale().then((value) => Utils.locale = value);
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _bannerAd = ad as BannerAd),
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _navigate(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => _navigate(const SettingsScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                children: [
                  _CalcCard(
                    assetName: 'monthly_sip.png',
                    title: 'Monthly SIP',
                    onTap: () => _navigate(const MonthlySipScreen()),
                  ),
                  _CalcCard(
                    assetName: 'lumpsum_sip.png',
                    title: 'Lumpsum SIP',
                    onTap: () => _navigate(const LumpsumSipScreen()),
                  ),
                  _CalcCard(
                    assetName: 'target_sip.png',
                    title: 'Target SIP',
                    onTap: () => _navigate(const TargetSipScreen()),
                  ),
                  _CalcCard(
                    assetName: 'emi_calculator.png',
                    title: 'EMI Calculator',
                    onTap: () => _navigate(const EMICalculatorScreen()),
                  ),
                  _CalcCard(
                    assetName: 'step_up_sip.png',
                    title: 'Step-Up SIP',
                    onTap: () => _navigate(const StepUpSipScreen()),
                  ),
                  _CalcCard(
                    assetName: 'swp_calculator.png',
                    title: 'SWP',
                    onTap: () => _navigate(const SwpScreen()),
                  ),
                ],
              ),
            ),
          ),
          if (_bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final String title;
  final String assetName;
  final VoidCallback onTap;

  const _CalcCard({
    required this.title,
    required this.assetName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1565C0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Image.asset(
                  'assets/icons/$assetName',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: blue,
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
