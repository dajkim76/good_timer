import 'package:flutter/material.dart';
import 'package:good_timer/realm_models.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 시간이 다 됬을 때, 소리로 알림 여부
class SettingsProvider with ChangeNotifier {
  late SharedPreferences _sharedPreferences;

  bool _isPlaySound = true;
  int _selectedTaskId = 0;

  bool get isPlaySound => _isPlaySound;
  int get selectedTaskId => _selectedTaskId;

  SettingsProvider() {
    loadFromSharedPref();
  }

  Future<void> loadFromSharedPref() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _isPlaySound = _sharedPreferences.getBool("isPlaySound") ?? true;
    _selectedTaskId = _sharedPreferences.getInt("selectedTaskId") ?? 0;
    notifyListeners();
  }

  void save(bool isPlaySound) {
    _isPlaySound = isPlaySound;
    _sharedPreferences.setBool("isPlaySound", isPlaySound);
    notifyListeners();
  }

  void setSelectedTaskId(int taskId) {
    _selectedTaskId = taskId;
    _sharedPreferences.setInt("selectedTaskId", taskId);
    notifyListeners();
  }
}

class TaskListProvider with ChangeNotifier {
  late List<Task> _taskList;

  late Realm realm;
  List<Task> get taskList => _taskList;

  TaskListProvider() {
    var config = Configuration.local([Task.schema], schemaVersion: 1);
    realm = Realm(config);

    var allTasks = realm.all<Task>();
    if (allTasks.isEmpty) {
      realm.write(() {
        realm.add(Task(DateTime.now().millisecondsSinceEpoch, "Test task #1"));
        realm.add(Task(DateTime.now().millisecondsSinceEpoch + 1, "Test task #2"));
      });
    }

    _taskList = realm.all<Task>().toList();
    notifyListeners();
  }

  String? getSelectedTaskName(int id) {
    return realm.find<Task>(id)?.name;
  }

  void addTask(String name) {
    var newTask = Task(DateTime.now().millisecondsSinceEpoch, name);
    realm.write(() {
      realm.add(newTask);
    });
    _taskList.add(newTask);
    notifyListeners();
  }

  void deleteTask(int taskId) {
    var task = _taskList.firstWhere((element) => element.id == taskId);
    realm.write(() => realm.delete<Task>(task));
    _taskList.remove(task);
    notifyListeners();
  }
}
