import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Timer? _timer;
  int focusSeconds = kDebugMode ? 15 : 25 * 60;
  int breakSeconds = kDebugMode ? 5 : 5 * 60;
  bool isFocusMode = false;
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    // 풀스크린 만들기
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _playSound() async {
    if (isFocusMode) {
      assetsAudioPlayer.open(Audio("assets/break.wav"));
    } else {
      assetsAudioPlayer.open(Audio("assets/focus.wav"));
    }
  }

  int _getModeSeconds() {
    if (_timer == null) return focusSeconds;
    return isFocusMode ? focusSeconds : breakSeconds;
  }

  void _onClickStartStopButton() {
    if (_timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _counter++;
          if (_getModeSeconds() - _counter <= 0) {
            _counter = 0;
            isFocusMode = !isFocusMode;
            _playSound();
          }
        });
      });
      setState(() {
        isFocusMode = true;
        _counter = 0;
      });
      Wakelock.enable();
    } else {
      _timer?.cancel();
      _timer = null;
      setState(() {
        isFocusMode = false;
        _counter = 0;
      });
      Wakelock.disable();
    }
  }

  String _getTimeText() {
    int remainSeconds = _getModeSeconds() - _counter;
    String min = (remainSeconds / 60).toInt().toString();
    String sec = (remainSeconds % 60).toString();
    if (min.length == 1) min = "0$min";
    if (sec.length == 1) sec = "0$sec";
    return "$min:$sec";
  }

  String _getModeLabel() {
    if (_timer == null) return "준비";
    return isFocusMode ? '포커스!! 집중하세요' : "휴식중...";
  }

  Color _getModeLabelColor() {
    if (_timer == null) return Colors.grey;
    return isFocusMode ? Colors.green : Colors.grey;
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
            title: Text(
              widget.title,
              style: const TextStyle(color: Colors.grey),
            ),
            // 명시적으로 페이지 종료버튼을 추가
            leading: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.grey,
              ),
              onPressed: () => {
                // TODO: check iOS
                SystemNavigator.pop()
              },
            ),
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
                  _getModeLabel(),
                  style: TextStyle(color: _getModeLabelColor(), fontSize: 40),
                ),
                Text(
                  _getTimeText(),
                  style: TextStyle(
                      fontSize: 100,
                      color: (isFocusMode ? Colors.yellow : Colors.grey)),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueGrey,
            onPressed: _onClickStartStopButton,
            tooltip: '시작 / 종료',
            child: Icon(_timer == null
                ? Icons.not_started_outlined
                : Icons.stop_circle_outlined),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
        onWillPop: () {
          // back키로 페이지 종료를 막는다.
          return Future.value(false);
        });
  }
}
