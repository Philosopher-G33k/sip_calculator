import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sip_calculator/utils/utils.dart';
import '../../utils/ad_helper.dart';

import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BannerAd? _bannerAd;
  final InAppReview _inAppReview = InAppReview.instance;
  var _selectedOption = Utils.locale;
  var localChanged = false;

  void handleLocaleChanged(String value) {
    setState(() {
      _selectedOption = value;
      Utils().setDefaultLocale(_selectedOption);
      localChanged = true;
    });
  }

  void _showModalSheet({required Function handleLocaleChange}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Number Format",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    RadioListTile(
                      title: Text(Utils().formatNumbers(
                          number: 1234567.89, customLocale: "en-IN")),
                      value: Utils().availableLocales[0],
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value.toString();
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(Utils().formatNumbers(
                          customLocale: "en-US", number: 1234567.89)),
                      value: Utils().availableLocales[1],
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          setState(() {
                            _selectedOption = value.toString();
                          });
                          //handleLocaleChange(value);
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text(Utils().formatNumbers(
                          number: 1234567.89, customLocale: "nl-NL")),
                      value: Utils().availableLocales[2],
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value.toString();
                        });
                        //handleLocaleChange(value);
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        handleLocaleChange(_selectedOption);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void rateThisApp() async {
    if (await _inAppReview.isAvailable()) {
      _inAppReview.openStoreListing(appStoreId: "6447810570");
    }
  }

  void shareWithFriends() {
    print("Hello");
    Share.share('check out my website https://example.com',
        subject: 'Look what I made!');
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
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const SectionHeader(
              sectionTitle: "GENERAL",
            ),
            const Divider(),
            NumberFormatCell(
              tapHandler: _showModalSheet,
              valueChangeHandler: handleLocaleChanged,
            ),
            const Divider(),
            // GeneralCell(
            //   tapHandler: shareWithFriends,
            //   title: "Clear History",
            // ),
            // const Divider(),
            const SectionHeader(
              sectionTitle: "SYSTEM",
            ),
            const Divider(),
            GeneralCell(
              tapHandler: shareWithFriends,
              title: "Tell a Friend",
            ),
            const Divider(),
            GeneralCell(
              tapHandler: rateThisApp,
              title: "Rate This App",
            ),
            const Divider(),
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
            style: const TextStyle(
                color: Colors.black26,
                fontSize: 16,
                fontWeight: FontWeight.normal),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class NumberFormatCell extends StatelessWidget {
  final Function tapHandler;
  final Function valueChangeHandler;
  const NumberFormatCell({
    required this.valueChangeHandler,
    required this.tapHandler,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        tapHandler(handleLocaleChange: valueChangeHandler);
      },
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Number Format",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
            child: Text(
              Utils().formatNumbers(number: 1234567.89),
              style: const TextStyle(color: Colors.black26),
            ),
          ),
          const Padding(
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
  final Function tapHandler;
  const GeneralCell({
    required this.tapHandler,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => tapHandler(),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
