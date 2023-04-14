import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utils/ad_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    // TODO: Load a banner ad
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
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: const [
            SectionHeader(
              sectionTitle: "GENERAL",
            ),
            Divider(),
            NumberFormatCell(),
            Divider(),
            GeneralCell(
              title: "Clear History",
            ),
            Divider(),
            SectionHeader(
              sectionTitle: "SYSTEM",
            ),
            Divider(),
            GeneralCell(
              title: "Tell a Friend",
            ),
            Divider(),
            GeneralCell(
              title: "Rate This App",
            ),
            Divider(),
          ]),
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
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String sectionTitle;
  const SectionHeader({
    required this.sectionTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            sectionTitle,
            style: const TextStyle(color: Colors.black26),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class NumberFormatCell extends StatelessWidget {
  const NumberFormatCell({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Number Format"),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8, right: 8),
            child: Text(
              "123456",
              style: TextStyle(color: Colors.black26),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 8, right: 8),
            child: Text(
              ">",
              style: TextStyle(color: Colors.black26),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneralCell extends StatelessWidget {
  final String title;
  const GeneralCell({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
