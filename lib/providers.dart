import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 시간이 다 됬을 때, 소리로 알림 여부
class PlaySoundProvider with ChangeNotifier {
  late SharedPreferences _sharedPreferences;

  static late bool _isPlaySound;

  static bool get isPlaySound => _isPlaySound;

  PlaySoundProvider() {
    loadFromSharedPref();
  }

  Future<void> loadFromSharedPref() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _isPlaySound = _sharedPreferences.getBool("isPlaySound") ?? true;
    notifyListeners();
  }

  void save(bool isPlaySound) {
    _isPlaySound = isPlaySound;
    _sharedPreferences.setBool("isPlaySound", isPlaySound);
    notifyListeners();
  }
}
