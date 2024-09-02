import 'dart:async';

import 'package:flutter/services.dart';

class MyNativePlugin {
  // Method channel을 생성한다.
  static const MethodChannel _channel = MethodChannel('com.mdiwebma.good_timer');

  static Future<String> getAppVersionName() async {
    final String version = await _channel.invokeMethod('getAppVersionName');
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

  // result is -1: not supported, 0:launched page, 1:ignored
  static Future<int> ignoreBatteryOptimization() async {
    final int result = await _channel.invokeMethod("ignoreBatteryOptimization");
    return result;
  }

  // result is -1: not supported, 0:not ignored, 1: ignored
  static Future<int> isIgnoreBatteryOptimization() async {
    final int result = await _channel.invokeMethod("isIgnoreBatteryOptimization");
    return result;
  }

  static Future<bool> openAppMarketPage() async {
    await _channel.invokeMethod("openAppMarketPage");
    return true;
  }

  // check Exact Alarm permission
  // result is -1: not supported, 0:not allowed, 1: allowed
  static Future<int> querySettingAlarms() async {
    final int result = await _channel.invokeMethod("querySettingAlarms");
    return result;
  }

  // open SettingAlarms permission page
  // true: succeeded, false: not supported, exception: error occurred
  static Future<bool> openSettingAlarms() async {
    await _channel.invokeMethod("openSettingAlarms");
    return true;
  }
}
