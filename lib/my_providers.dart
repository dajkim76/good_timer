import 'package:flutter/material.dart';
import 'package:good_timer/realm_models.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 시간이 다 됬을 때, 소리로 알림 여부
class SettingsProvider with ChangeNotifier {
  late SharedPreferences _sharedPreferences;

  static late bool _isPlaySound;

  static bool get isPlaySound => _isPlaySound;

  SettingsProvider() {
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

class TaskListProvider with ChangeNotifier {
  late List<Task> _taskList;

  late Realm realm;
  List<Task> get taskList => _taskList;

  TaskListProvider() {
    var config = Configuration.local([Task.schema]);
    realm = Realm(config);

    var allTasks = realm.all<Task>();
    if (allTasks.isEmpty) {
      realm.write(() {
        realm.add(Task(1, DateTime.now().millisecondsSinceEpoch, "Test task1#1"));
      });
    }

    _taskList = realm.all<Task>().map((e) => e).toList();
    notifyListeners();
  }
}
