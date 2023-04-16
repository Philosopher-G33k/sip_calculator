import 'dart:async';
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

  String formatNumbers(double number) {
    var formatter = NumberFormat.simpleCurrency(locale: locale);
    String formattedPrice = formatter.format(number).substring(1);
    return formattedPrice;
  }
}
