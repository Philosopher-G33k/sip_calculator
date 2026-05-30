import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

class Utils {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static final Utils _singleton = Utils._internal();

  final availableLocales = ["en-IN", "en-US", "nl-NL"];

  static String locale = "en-IN";

  /// Native channel used to mirror the selected locale into the iOS App-Group
  /// suite so App Intents / widgets format in the app's locale.
  static const MethodChannel _localeChannel =
      MethodChannel('com.ishanmalviya.sipcalculator/locale');

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

    // Mirror to the iOS App-Group suite for native surfaces. The channel only
    // exists on iOS; ignore failures on other platforms / before engine setup.
    if (Platform.isIOS) {
      try {
        await _localeChannel.invokeMethod('setLocale', locale);
      } on PlatformException {
        // Best-effort: a missing native handler must not block locale changes.
      } on MissingPluginException {
        // No native handler registered (e.g. older build) — ignore.
      }
    }
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
      return 'https://play.google.com/store/apps/details?id=com.ishanmalviya.sipcalculator';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/us/app/sip-calculator/id6447810570';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
