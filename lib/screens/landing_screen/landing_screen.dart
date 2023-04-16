// ignore: implementation_imports
import 'package:flutter/material.dart';
import 'package:sip_calculator/screens/emi_calculator_screen/emi_calculator_screen.dart';
import 'package:sip_calculator/screens/lumpsum_sip_screen/lumpsum_sip_screen.dart';
import 'package:sip_calculator/screens/monthly_sip_screen/monthly_sip_screen.dart';
import 'package:sip_calculator/screens/settings_screen/settings_screen.dart';
import 'package:sip_calculator/screens/target_sip_screen/target_sip_screen.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sip_calculator/utils/utils.dart';
import '../../utils/ad_helper.dart';
// ignore: implementation_imports

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  BannerAd? _bannerAd;

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  @override
  void initState() {
    super.initState();

    Utils().getDefaultLocale().then((value) => Utils.locale = value);

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
        title: const Text("SIP Calculator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Do something when the button is pressed
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                CalculatorOptionCell(
                  assetName: "monthly_sip.png",
                  title: "Monthly SIP",
                  tapHandler: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MonthlySipScreen(),
                      ),
                    );
                  },
                ),
                CalculatorOptionCell(
                  assetName: "lumpsum_sip.png",
                  title: "Lumpsum SIP",
                  tapHandler: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LumpsumSipScreen(),
                      ),
                    );
                  },
                ),
                CalculatorOptionCell(
                  assetName: "target_sip.png",
                  title: "Target SIP",
                  tapHandler: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TargetSipScreen(),
                      ),
                    );
                  },
                ),
                CalculatorOptionCell(
                  assetName: "emi_calculator.png",
                  title: "EMI Calculator",
                  tapHandler: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EMICalculatorScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (_bannerAd != null)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
      ]),
    );
  }
}

class CalculatorOptionCell extends StatelessWidget {
  final String title;
  final String assetName;
  final Function tapHandler;
  const CalculatorOptionCell({
    required this.title,
    required this.tapHandler,
    required this.assetName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 20,
      child: InkWell(
        onTap: () {
          tapHandler();
        },
        child: Column(
          children: [
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/icons/$assetName"),
                )),
            Expanded(
              flex: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(33, 150, 243, 1),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                width: double.infinity,
                child: Center(
                    child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
