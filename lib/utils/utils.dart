import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

class Utils {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static final Utils _singleton = Utils._internal();

  final availableLocales = ["en-IN", "en-US", "nl-NL"];

  static String locale = "en-IN";

  factory Utils() {
    return _singleton;
  }

  Utils._internal();

  Future<String> getDefaultLocale() {
    final locale = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('locale') ?? "en-IN";
    });
    return locale;
  }

  Future<void> setDefaultLocale(String locale) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('locale', locale);
    Utils.locale = locale;
  }

  Future<void> incrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;
    prefs.setInt('counter', counter);
  }

  Future<int> readCounter() {
    final counter = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('counter') ?? 0;
    });

    return counter;
  }

  Future<void> resetCounter() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt('counter', 0);
  }

  String formatNumbersInt({int number = 0}) {
    var formatter = NumberFormat.simpleCurrency(locale: locale);
    String formattedPrice = formatter.format(number).substring(1);
    return formattedPrice;
  }

  String formatNumbers({double number = 1234567.89, String customLocale = ""}) {
    var tempLocale = locale;
    if (customLocale != "") {
      tempLocale = customLocale;
    }
    var formatter = NumberFormat.simpleCurrency(locale: tempLocale);
    String formattedPrice = formatter.format(number).substring(1);
    return formattedPrice;
  }

  String getStoreURL() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/us/app/sip-calculator/id6447810570';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
