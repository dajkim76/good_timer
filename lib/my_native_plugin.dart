import 'dart:async';

import 'package:flutter/services.dart';

class MyNativePlugin {
  // Method channel을 생성한다.
  static const MethodChannel _channel = MethodChannel('com.mdiwebma.good_timer');

  static Future<String> get platformVersion async {
    // Method channel에 등록되어있는 getPlatformVersion 이라는 메소드를 call 해서 platform version을 받아온다.
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> setAlarm(int id, int rtcTimeMillis, bool wakeUp) async {
    final bool succeeded = await _channel.invokeMethod(
        "setAlarm", <String, dynamic>{"extra_id": id, "extra_rtcTimeMillis": rtcTimeMillis, "extra_wakeUp": wakeUp});
    return succeeded;
  }

  static Future<bool> cancelAlarm(int id) async {
    final bool succeeded = await _channel.invokeMethod("cancelAlarm", <String, dynamic>{"extra_id": id});
    return succeeded;
  }

  static Future<bool> playSound(int id) async {
    final bool succeeded = await _channel.invokeMethod("playSound", <String, dynamic>{"extra_id": id});
    return succeeded;
  }
}
