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
  var _selectedLocale = Utils.locale;

  @override
  void initState() {
    super.initState();
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

  void _handleLocaleChanged(String value) {
    setState(() {
      _selectedLocale = value;
      Utils().setDefaultLocale(value);
    });
  }

  void _showNumberFormatSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFD8DC),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Number Format',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A1929),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose how numbers are displayed throughout the app.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF78909C)),
                  ),
                  const SizedBox(height: 16),
                  // RadioGroup replaces deprecated groupValue / onChanged
                  RadioGroup<String>(
                    groupValue: _selectedLocale,
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() => _selectedLocale = value);
                      }
                    },
                    child: Column(
                      children: Utils().availableLocales.map((locale) {
                        return RadioListTile<String>(
                          value: locale,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            Utils().formatNumbers(
                                number: 1234567.89, customLocale: locale),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            locale,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF90A4AE),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleLocaleChanged(_selectedLocale);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _rateThisApp() async {
    if (await _inAppReview.isAvailable()) {
      _inAppReview.openStoreListing(appStoreId: '6447810570');
    }
  }

  void _shareWithFriends() {
    const urlAndroid =
        'https://play.google.com/store/apps/details?id=com.ishanmalviya.sipcalculator';
    const urlIOS =
        'https://apps.apple.com/us/app/sip-calculator/id6447810570';
    SharePlus.instance.share(
      ShareParams(
        text:
            'Check out this amazing SIP Calculator app!\n\nAndroid: $urlAndroid\niOS: $urlIOS',
        subject: 'Share SIP Calculator',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              children: [
                _SectionLabel(label: 'GENERAL'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.format_list_numbered_rounded,
                      title: 'Number Format',
                      trailing: Text(
                        Utils().formatNumbers(number: 1234567.89),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF90A4AE),
                        ),
                      ),
                      onTap: _showNumberFormatSheet,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'APP'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.share_outlined,
                      title: 'Tell a Friend',
                      onTap: _shareWithFriends,
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate This App',
                      onTap: _rateThisApp,
                    ),
                  ],
                ),
              ],
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

// ─── Private sub-widgets ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF90A4AE),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF1565C0), size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0A1929),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFB0BEC5), size: 20),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
