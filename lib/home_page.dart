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
  bool _isFocusMode = false;
  DateTime _startTime = DateTime.now();
  DateTime _resumeTime = DateTime.now();
  Duration _timerDuration = Duration.zero;
  TimerState _timerState = TimerState.stop;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // for open drawer
  final ValueNotifier<int> _remainSecondsNotifier = ValueNotifier<int>(0);
  int _pomodoroCount = 0; // check for long break time
  late int _focusTimeMinutes;
  late int _shortBreakTimeMinutes;
  late int _longBreakTimeMinutes;
  late SettingsProvider _settings;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 풀스크린 만들기
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _settings = context.read<SettingsProvider>();
    _updatePomodoroMinutes();
    _remainSecondsNotifier.value = _getModeSeconds();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _timer?.cancel();
    MyNativePlugin.cancelAlarm(1); // TODO 타이밍 이슈 있음
    super.dispose();
  }

  void _updatePomodoroMinutes() {
    _focusTimeMinutes = _settings.focusTime;
    _shortBreakTimeMinutes = _settings.shortBreakTime;
    _longBreakTimeMinutes = _settings.longBreakTime;
  }

  void _setAlarmSoundVibration() async {
    if (_settings.isPlaySound) {
      if (_isFocusMode) {
        MyNativePlugin.playSound(0);
      } else {
        MyNativePlugin.playSound(1);
      }
    }
    if (_settings.isVibration) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000]);
    }
  }

  int _getModeSeconds() {
    int seconds = kDebugMode ? 1 : 60;
    if (_timerState == TimerState.stop) {
      return _settings.focusTime * seconds;
    }
    if (_isFocusMode) {
      return _focusTimeMinutes * seconds;
    } else {
      return (_pomodoroCount % 4) == 0 ? _longBreakTimeMinutes * seconds : _shortBreakTimeMinutes * seconds;
    }
  }

  void _onClickStart() {
    assert(_timer == null);
    if (_timer == null) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), _onTimer);
      MyNativePlugin.cancelAlarm(1);
      _updatePomodoroMinutes();
      setState(() {
        _timerState = TimerState.play;
        _timerDuration = Duration.zero;
        _isFocusMode = true;
        _startTime = _resumeTime = DateTime.now();
        final remainSeconds = _getModeSeconds();
        _remainSecondsNotifier.value = remainSeconds;
        int rtcTimeMillis = _startTime.add(Duration(seconds: remainSeconds)).millisecondsSinceEpoch;
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
      _timerState = TimerState.pause;
      _timerDuration = _timerDuration + DateTime.now().difference(_resumeTime);
      _resumeTime = DateTime.now();
    });
    Future future = MyNativePlugin.cancelAlarm(1);
    handleError(future);
    Wakelock.disable();
    HapticFeedback.lightImpact();
  }

  void _onClickResume() {
    assert(_timer != null);
    setState(() {
      _timerState = TimerState.play;
      _resumeTime = DateTime.now();
      Duration remainDuration = Duration(seconds: _getModeSeconds()) - _timerDuration;
      int rtcTimeMillis = _resumeTime.add(remainDuration).millisecondsSinceEpoch;
      Future future = MyNativePlugin.setAlarm(1, rtcTimeMillis, true);
      handleError(future);
    });
    Wakelock.enable();
    HapticFeedback.lightImpact();
  }

  void _onClickStop() {
    assert(_timer != null);
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      Future future = MyNativePlugin.cancelAlarm(1);
      handleError(future);
      _pomodoroCount = 0;
      _updatePomodoroMinutes();
      setState(() {
        _remainSecondsNotifier.value = _getModeSeconds();
        _timerState = TimerState.stop;
        _isFocusMode = false;
      });
      Wakelock.disable();
      HapticFeedback.lightImpact();
    }
  }

  void _onTimer(Timer timer) {
    if (_timerState != TimerState.play) return;

    DateTime now = DateTime.now();
    int remainSeconds = _getModeSeconds() - (_timerDuration + now.difference(_resumeTime)).inSeconds;
    if (remainSeconds <= 0) {
      _setAlarmSoundVibration();
      if (_isFocusMode) {
        _pomodoroCount++;
        MyRealm.instance
            .addPomodoro(_startTime, _settings.instantTaskName, _settings.selectedTaskId, _focusTimeMinutes);
        context.read<PomodoroCountProvider>().notifyTodayPomodoroCount();
      }
      _updatePomodoroMinutes();
      setState(() {
        _isFocusMode = !_isFocusMode;
        _startTime = _resumeTime = DateTime.now();
        _timerDuration = Duration.zero;
        int rtcTimeMillis = _startTime.add(Duration(seconds: _getModeSeconds())).millisecondsSinceEpoch;
        Future future = MyNativePlugin.setAlarm(1, rtcTimeMillis, true);
        handleError(future);
      });
    } else {
      if (_remainSecondsNotifier.value != remainSeconds) {
        setState(() {
          // update Ui
          _remainSecondsNotifier.value = remainSeconds;
        });
      }
    }
  }

  String _getRemainTimeText() {
    int remainSeconds;
    if (_timer != null) {
      if (_timerState == TimerState.pause) {
        remainSeconds = _getModeSeconds() - _timerDuration.inSeconds;
      } else {
        DateTime now = DateTime.now();
        remainSeconds = _getModeSeconds() - (_timerDuration + now.difference(_resumeTime)).inSeconds;
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

  String _getModeLabel() {
    if (_timer != null && !_isFocusMode) return S.of(context).in_rest;

    // check instant task name
    var instantTaskName = _settings.instantTaskName;
    if (instantTaskName?.isNotEmpty == true) {
      return instantTaskName!;
    }
    // check task
    var taskName = _settings.selectedTaskName;
    if (taskName?.isNotEmpty == true) {
      return taskName!;
    }

    if (_timer == null) return S.of(context).ready;
    return _isFocusMode ? S.of(context).be_focus : S.of(context).in_rest;
  }

  Color _getModeLabelColor() {
    if (_timer == null) return Colors.grey;
    if (_isFocusMode) {
      if (_timerState == TimerState.play) {
        return Colors.green;
      } else {
        return Colors.greenAccent;
      }
    } else {
      return Colors.grey;
    }
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

  void _onClickTaskName() async {
    _textEditingController.text = _settings.instantTaskName ?? "";
    String? newValue = await showInputDialog(context, _textEditingController, S.of(context).instant_task_name);
    if (newValue?.isNotEmpty == true) {
      _settings.setInstantTaskName(newValue!);
    }
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
      if (_timerState == TimerState.play) {
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
      } else if (_timerState == TimerState.pause) {
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

      // stop
      buttons.add(IconButton(
        icon: const Icon(
          Icons.cancel_outlined,
          size: kSize,
          color: kColor,
        ),
        onPressed: _onClickStop,
        tooltip: S.of(context).stop,
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
                OutlinedButton(
                  onPressed: _onClickTaskName,
                  child: Text(
                    _getModeLabel(),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 1,
                    style: TextStyle(color: _getModeLabelColor(), fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                !settings.isAnalogClock
                    ? Text(
                        _getRemainTimeText(),
                        style: TextStyle(fontSize: 100, color: (_isFocusMode ? Colors.yellow : Colors.grey)),
                      )
                    : CustomPaint(
                        size: Size(MediaQuery.of(context).size.height / 3, MediaQuery.of(context).size.height / 3),
                        painter: ClockDialPainter(_timerState == TimerState.stop
                            ? (_remainSecondsNotifier..value = _getModeSeconds())
                            : _remainSecondsNotifier),
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
          if (_timerState != TimerState.stop) {
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
            if (_timerState != TimerState.stop) {
              showToast(S.of(context).stop_pomodoro_first);
            } else {
              SystemNavigator.pop();
            }
          }),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.format_list_numbered),
          onPressed: () {
            _key.currentState?.openEndDrawer();
          },
          tooltip: S.of(context).tasks,
        ),
        IconButton(
          icon: PomodoroCountIcon(pomodoroCount.todayPomodoroCount),
          onPressed: _onClickPomodoro,
          tooltip: S.of(context).pomodoro_count,
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
