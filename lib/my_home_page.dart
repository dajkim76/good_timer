import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:good_timer/good_timer_native_plugin.dart';
import 'package:good_timer/providers.dart';
import 'package:good_timer/settings_page.dart';
import 'package:wakelock/wakelock.dart';

import 'generated/l10n.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  static const int kFocusSeconds = kDebugMode ? 10 : 5 * 60;
  static const int kBreakSeconds = kDebugMode ? 5 : 1 * 60;
  bool isFocusMode = false;
  DateTime? backKeyPressedTime;
  DateTime startedTime = DateTime.now();
  static DateTime alarmStartedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 풀스크린 만들기
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    if (kDebugMode) {
      GoodTimerNativePlugin.platformVersion.then((value) => Fluttertoast.showToast(msg: value));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _playSound() async {
    if (!PlaySoundProvider.isPlaySound) return;
    if (isFocusMode) {
      //assetsAudioPlayer.open(Audio("assets/break.wav"));
    } else {
      //assetsAudioPlayer.open(Audio("assets/focus.wav"));
    }
  }

  int _getModeSeconds() {
    if (_timer == null) return kFocusSeconds;
    return isFocusMode ? kFocusSeconds : kBreakSeconds;
  }

  void _onClickStartStopButton() {
    if (_timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), _onTimer);
      setState(() {
        isFocusMode = true;
        startedTime = DateTime.now();
        alarmStartedTime = DateTime.now();
      });
      Wakelock.enable();
    } else {
      _timer?.cancel();
      _timer = null;
      setState(() {
        isFocusMode = false;
      });
      Wakelock.disable();
    }
  }

  @pragma('vm:entry-point')
  static void _onAlarm() {
    int seconds = DateTime.now().difference(alarmStartedTime).inSeconds;
    String alarmSeconds = _getTimeText(seconds);
    Fluttertoast.showToast(msg: "_onAlarm => $alarmSeconds");
  }

  void _onTimer(Timer timer) {
    DateTime now = DateTime.now();
    int remainSeconds = _getModeSeconds() - now.difference(startedTime).inSeconds;
    if (remainSeconds <= 0) {
      _playSound();
      setState(() {
        isFocusMode = !isFocusMode;
        startedTime = DateTime.now();
        alarmStartedTime = DateTime.now();
      });
    } else {
      setState(() {
        // update Ui
      });
    }
  }

  String _getRemainTimeText() {
    int remainSeconds;
    if (_timer != null) {
      DateTime now = DateTime.now();
      remainSeconds = _getModeSeconds() - now.difference(startedTime).inSeconds;
    } else {
      remainSeconds = _getModeSeconds();
    }
    return _getTimeText(remainSeconds);
  }

  static String _getTimeText(int seconds) {
    String min = (seconds ~/ 60).toString();
    String sec = (seconds % 60).toString();
    if (min.length == 1) min = "0$min";
    if (sec.length == 1) sec = "0$sec";
    return "$min:$sec";
  }

  String _getModeLabel(BuildContext context) {
    if (_timer == null) return S.of(context).ready;
    return isFocusMode ? S.of(context).be_focus : S.of(context).in_rest;
  }

  Color _getModeLabelColor() {
    if (_timer == null) return Colors.grey;
    return isFocusMode ? Colors.green : Colors.grey;
  }

  void _onClickSettings() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            // TRY THIS: Try changing the color here to a specific color (to
            // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
            // change color while the other colors stay the same.
            backgroundColor: Colors.black,
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(S.of(context).appName),
            // 명시적으로 페이지 종료버튼을 추가
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => {
                // TODO: check iOS
                SystemNavigator.pop()
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _onClickSettings,
                tooltip: S.of(context).settings,
              ),
            ],
          ),
          body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              //
              // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
              // action in the IDE, or press "p" in the console), to see the
              // wireframe for each widget.
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _getModeLabel(context),
                  style: TextStyle(color: _getModeLabelColor(), fontSize: 40),
                ),
                Text(
                  _getRemainTimeText(),
                  style: TextStyle(fontSize: 100, color: (isFocusMode ? Colors.yellow : Colors.grey)),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueGrey,
            onPressed: _onClickStartStopButton,
            tooltip: S.of(context).tooltip_start_stop,
            child: Icon(_timer == null ? Icons.not_started_outlined : Icons.stop_circle_outlined),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
        onWillPop: () {
          if (_timer == null) return Future.value(true);
          if (backKeyPressedTime == null || DateTime.now().difference(backKeyPressedTime!).inSeconds >= 2) {
            backKeyPressedTime = DateTime.now();
            Fluttertoast.showToast(msg: S.of(context).pressAgainToExit);
            return Future.value(false);
          }
          return Future.value(true);
        });
  }
}
