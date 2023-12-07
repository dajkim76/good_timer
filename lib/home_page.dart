import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:good_timer/clock_dial_painter.dart';
import 'package:good_timer/my_native_plugin.dart';
import 'package:good_timer/my_providers.dart';
import 'package:good_timer/my_realm.dart';
import 'package:good_timer/pomodoro_count_icon.dart';
import 'package:good_timer/settings_page.dart';
import 'package:good_timer/task_list_drawer.dart';
import 'package:good_timer/utils.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';

import 'generated/l10n.dart';
import 'pomodoro_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  @override
  State<HomePage> createState() => _HomePageState();
}

enum TimerState { stop, play, pause }

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  static const int kFocusSeconds = kDebugMode ? 10 : 25 * 60;
  static const int kBreakSeconds = kDebugMode ? 5 : 5 * 60;
  bool isFocusMode = false;
  DateTime? backKeyPressedTime;
  DateTime startedTime = DateTime.now();
  Duration timerDuration = Duration.zero;
  TimerState timerState = TimerState.stop;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // for open drawer
  final ValueNotifier<int> remainSecondsNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    // 풀스크린 만들기
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    if (kDebugMode) {
      MyNativePlugin.platformVersion.then((value) => Fluttertoast.showToast(msg: value));
    }
    remainSecondsNotifier.value = _getModeSeconds();
  }

  @override
  void dispose() {
    _timer?.cancel();
    MyNativePlugin.cancelAlarm(1); // TODO 타이밍 이슈 있음
    super.dispose();
  }

  void _playSound() async {
    var settings = context.read<SettingsProvider>();
    if (!settings.isPlaySound) return;
    if (isFocusMode) {
      MyNativePlugin.playSound(0);
    } else {
      MyNativePlugin.playSound(1);
    }
  }

  int _getModeSeconds() {
    if (_timer == null) return kFocusSeconds;
    return isFocusMode ? kFocusSeconds : kBreakSeconds;
  }

  void _onClickStart() {
    assert(_timer == null);
    if (_timer == null) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), _onTimer);
      MyNativePlugin.cancelAlarm(1);
      setState(() {
        timerState = TimerState.play;
        timerDuration = Duration.zero;
        isFocusMode = true;
        startedTime = DateTime.now();
        final remainSeconds = _getModeSeconds();
        remainSecondsNotifier.value = remainSeconds;
        int rtcTimeMillis = startedTime.add(Duration(seconds: remainSeconds)).millisecondsSinceEpoch;
        Future future = MyNativePlugin.setAlarm(1, rtcTimeMillis, true);
        handleError(future);
      });
      Wakelock.enable();
      HapticFeedback.lightImpact();
    }
  }

  void _onClickPause() {
    assert(_timer != null);
    setState(() {
      timerState = TimerState.pause;
      timerDuration = timerDuration + DateTime.now().difference(startedTime);
      startedTime = DateTime.now();
    });
    Future future = MyNativePlugin.cancelAlarm(1);
    handleError(future);
    Wakelock.disable();
    HapticFeedback.lightImpact();
  }

  void _onClickResume() {
    assert(_timer != null);
    setState(() {
      timerState = TimerState.play;
      startedTime = DateTime.now();
      Duration remainDuration = Duration(seconds: _getModeSeconds()) - timerDuration;
      int rtcTimeMillis = startedTime.add(remainDuration).millisecondsSinceEpoch;
      Future future = MyNativePlugin.setAlarm(1, rtcTimeMillis, true);
      handleError(future);
    });
    Wakelock.enable();
    HapticFeedback.lightImpact();
  }

  void _onClickReset() {
    assert(_timer != null);
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      Future future = MyNativePlugin.cancelAlarm(1);
      handleError(future);
      setState(() {
        remainSecondsNotifier.value = _getModeSeconds();
        timerState = TimerState.stop;
        isFocusMode = false;
      });
      Wakelock.disable();
      HapticFeedback.lightImpact();
    }
  }

  void _onTimer(Timer timer) {
    if (timerState != TimerState.play) return;

    DateTime now = DateTime.now();
    int remainSeconds = _getModeSeconds() - (timerDuration + now.difference(startedTime)).inSeconds;
    if (remainSeconds <= 0) {
      _playSound();
      if (isFocusMode) {
        MyRealm.instance.addPomodoro(context.read<SettingsProvider>().selectedTaskId, 25);
        context.read<PomodoroCountProvider>().notifyTodayPomodoroCount();
        if (context.read<SettingsProvider>().isVibration) {
          Vibration.vibrate(pattern: [500, 1000, 500, 1000]);
        }
      }
      setState(() {
        isFocusMode = !isFocusMode;
        startedTime = DateTime.now();
        timerDuration = Duration.zero;
        int rtcTimeMillis = startedTime.add(Duration(seconds: _getModeSeconds())).millisecondsSinceEpoch;
        Future future = MyNativePlugin.setAlarm(1, rtcTimeMillis, true);
        handleError(future);
      });
    } else {
      setState(() {
        // update Ui
        remainSecondsNotifier.value = remainSeconds;
        print("remainSeconds=$remainSeconds");
      });
    }
  }

  String _getRemainTimeText() {
    int remainSeconds;
    if (_timer != null) {
      if (timerState == TimerState.pause) {
        remainSeconds = _getModeSeconds() - timerDuration.inSeconds;
      } else {
        DateTime now = DateTime.now();
        remainSeconds = _getModeSeconds() - (timerDuration + now.difference(startedTime)).inSeconds;
      }
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
    if (_timer != null && !isFocusMode) return S.of(context).in_rest;
    final settings = context.watch<SettingsProvider>();
    var taskName = settings.selectedTaskName;
    if (taskName != null) return taskName;
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

  void _onClickPomodoro() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const PomodoroPage(),
    ));
  }

  List<Widget> _buildStartStopButtons(BuildContext context) {
    const kSize = 80.0;
    const kColor = Colors.white;

    List<Widget> buttons = <Widget>[];
    if (_timer == null) {
      buttons.add(IconButton(
        // start
        icon: const Icon(
          Icons.play_circle_rounded,
          size: kSize,
          color: kColor,
        ),
        onPressed: _onClickStart,
        tooltip: S.of(context).start,
      ));
    } else {
      if (timerState == TimerState.play) {
        // pause
        buttons.add(IconButton(
          icon: const Icon(
            Icons.pause_circle_rounded,
            size: kSize,
            color: kColor,
          ),
          onPressed: _onClickPause,
          tooltip: S.of(context).pause,
        ));
      } else if (timerState == TimerState.pause) {
        // resume
        buttons.add(IconButton(
          icon: const Icon(
            Icons.not_started_rounded,
            size: kSize,
            color: kColor,
          ),
          onPressed: _onClickResume,
          tooltip: S.of(context).resume,
        ));
      }

      // reset
      buttons.add(IconButton(
        icon: const Icon(
          Icons.cancel_outlined,
          size: kSize,
          color: kColor,
        ),
        onPressed: _onClickReset,
        tooltip: S.of(context).reset,
      ));
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final pomodoroCount = context.watch<PomodoroCountProvider>();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return WillPopScope(
        child: Scaffold(
          key: _key,
          appBar: buildAppBar(context, pomodoroCount),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  child: Text(
                    _getModeLabel(context),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 1,
                    style: TextStyle(color: _getModeLabelColor(), fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _key.currentState?.openEndDrawer();
                  },
                ),
                !settings.isAnalogClock
                    ? Text(
                        _getRemainTimeText(),
                        style: TextStyle(fontSize: 100, color: (isFocusMode ? Colors.yellow : Colors.grey)),
                      )
                    : CustomPaint(
                        size: Size(MediaQuery.of(context).size.height / 3, MediaQuery.of(context).size.height / 3),
                        painter: ClockDialPainter(remainSecondsNotifier),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildStartStopButtons(context),
                )
              ],
            ),
          ),
          endDrawer: const TaskListDrawer(),
          drawerDragStartBehavior: DragStartBehavior.start,
        ),
        onWillPop: () {
          if (timerState != TimerState.stop) {
            showToast(S.of(context).stop_pomodoro_first);
            return Future.value(false);
          }

          return Future.value(true);
        });
  }

  AppBar buildAppBar(BuildContext context, PomodoroCountProvider pomodoroCount) {
    return AppBar(
      titleSpacing: 0,
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Text(S.of(context).appName),
      // 명시적으로 페이지 종료버튼을 추가
      leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (timerState != TimerState.stop) {
              showToast(S.of(context).stop_pomodoro_first);
            } else {
              SystemNavigator.pop();
            }
          }),
      actions: <Widget>[
        IconButton(
          icon: PomodoroCountIcon(pomodoroCount.todayPomodoroCount),
          onPressed: _onClickPomodoro,
          tooltip: S.of(context).pomodoro_count,
        ),
        IconButton(
          icon: const Icon(Icons.format_list_numbered),
          onPressed: () {
            _key.currentState?.openEndDrawer();
          },
          tooltip: S.of(context).tasks,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _onClickSettings,
          tooltip: S.of(context).settings,
        ),
      ],
    );
  }
}
