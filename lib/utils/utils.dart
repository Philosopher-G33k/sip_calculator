import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static final Utils _singleton = Utils._internal();

  factory Utils() {
    return _singleton;
  }

  Utils._internal();

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
}
