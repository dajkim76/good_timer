import 'package:flutter/foundation.dart';
import 'package:good_timer/realm_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MyRealm.dart';

// 시간이 다 됬을 때, 소리로 알림 여부
class SettingsProvider with ChangeNotifier {
  late SharedPreferences _sharedPreferences;

  bool _isPlaySound = true;
  int _selectedTaskId = 0;
  String? _selectedTaskName;
  bool _isAnalogClock = true;
  int _calendarFormat = 0;
  bool _showHiddenTask = false;
  bool _isVibration = false;

  bool get isPlaySound => _isPlaySound;
  int get selectedTaskId => _selectedTaskId;
  String? get selectedTaskName => _selectedTaskName;
  bool get isAnalogClock => _isAnalogClock;
  int get calendarFormat => _calendarFormat;
  bool get showHiddenTask => _showHiddenTask;
  bool get isVibration => _isVibration;

  SettingsProvider() {
    loadFromSharedPref();
  }

  Future<void> loadFromSharedPref() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _isPlaySound = _sharedPreferences.getBool("isPlaySound") ?? true;
    _isAnalogClock = _sharedPreferences.getBool("isAnalogClock") ?? true;
    _selectedTaskId = _sharedPreferences.getInt("selectedTaskId") ?? 0;
    _selectedTaskName = MyRealm.instance.getTaskName(_selectedTaskId);
    _calendarFormat = _sharedPreferences.getInt("calendarFormat") ?? 0;
    _showHiddenTask = _sharedPreferences.getBool("showHiddenTask") ?? false;
    _isVibration = _sharedPreferences.getBool("isVibration") ?? false;
    notifyListeners();
  }

  void save(bool isPlaySound) {
    _isPlaySound = isPlaySound;
    _sharedPreferences.setBool("isPlaySound", isPlaySound);
    notifyListeners();
  }

  void setAnalogClock(bool isAnalogClock) {
    _isAnalogClock = isAnalogClock;
    _sharedPreferences.setBool("isAnalogClock", isAnalogClock);
    notifyListeners();
  }

  void setSelectedTask(Task task) {
    _selectedTaskId = task.id;
    _selectedTaskName = task.name;
    _sharedPreferences.setInt("selectedTaskId", task.id);
    notifyListeners();
  }

  void setCalendarFormat(int calendarFormat) {
    _calendarFormat = calendarFormat;
    _sharedPreferences.setInt("calendarFormat", calendarFormat);
  }

  void setShowHiddenTask(bool showHiddenTask) {
    _showHiddenTask = showHiddenTask;
    _sharedPreferences.setBool("showHiddenTask", showHiddenTask);
    notifyListeners();
  }

  void setVibration(bool isVibration) {
    _isVibration = isVibration;
    _sharedPreferences.setBool("isVibration", isVibration);
    notifyListeners();
  }
}

class TaskListProvider with ChangeNotifier {
  int _todayPomodoroCount = 0;
  int get todayPomodoroCount => _todayPomodoroCount;

  TaskListProvider() {
    notifyTodayPomodoroCount();
  }

  void notifyTodayPomodoroCount() {
    _todayPomodoroCount = MyRealm.instance.getTodayPomodoroCount();
    notifyListeners();
  }
}
