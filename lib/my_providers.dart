import 'package:flutter/foundation.dart';
import 'package:good_timer/realm_models.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 시간이 다 됬을 때, 소리로 알림 여부
class SettingsProvider with ChangeNotifier {
  late SharedPreferences _sharedPreferences;

  bool _isPlaySound = true;
  int _selectedTaskId = 0;
  bool _isAnalogClock = true;
  int _calendarFormat = 0;

  bool get isPlaySound => _isPlaySound;
  int get selectedTaskId => _selectedTaskId;
  bool get isAnalogClock => _isAnalogClock;
  int get calendarFormat => _calendarFormat;

  SettingsProvider() {
    loadFromSharedPref();
  }

  Future<void> loadFromSharedPref() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _isPlaySound = _sharedPreferences.getBool("isPlaySound") ?? true;
    _isAnalogClock = _sharedPreferences.getBool("isAnalogClock") ?? true;
    _selectedTaskId = _sharedPreferences.getInt("selectedTaskId") ?? 0;
    _calendarFormat = _sharedPreferences.getInt("calendarFormat") ?? 0;
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

  void setSelectedTaskId(int taskId) {
    _selectedTaskId = taskId;
    _sharedPreferences.setInt("selectedTaskId", taskId);
    notifyListeners();
  }

  void setCalendarFormat(int calendarFormat) {
    _calendarFormat = calendarFormat;
    _sharedPreferences.setInt("calendarFormat", calendarFormat);
  }
}

class TaskListProvider with ChangeNotifier {
  late List<Task> _taskList;
  List<Pomodoro>? _pomodoroList;

  late Realm realm;
  List<Task> get taskList => _taskList;
  List<Pomodoro> get pomodoroList => _pomodoroList ?? [];
  int _todayPomodoroCount = 0;
  int get todayPomodoroCount => _todayPomodoroCount;

  TaskListProvider() {
    var config = Configuration.local([Task.schema, Pomodoro.schema], schemaVersion: 2);
    realm = Realm(config);

    var allTasks = realm.all<Task>();
    if (kDebugMode && allTasks.isEmpty) {
      realm.write(() {
        realm.add(Task(DateTime.now().millisecondsSinceEpoch, "Test task #1"));
        realm.add(Task(DateTime.now().millisecondsSinceEpoch + 1, "Test task #2"));
      });
    }

    _taskList = realm.all<Task>().toList();
    loadTodayPomodoroCount();
    notifyListeners();
  }

  String? getTaskName(int id) {
    return realm.find<Task>(id)?.name;
  }

  String? getTaskMemo(int id) {
    return realm.find<Task>(id)?.memo;
  }

  void addTask(String name) {
    var newTask = Task(DateTime.now().millisecondsSinceEpoch, name);
    realm.write(() {
      realm.add(newTask);
    });
    _taskList.add(newTask);
    notifyListeners();
  }

  void updateTaskName(int id, String name) {
    final task = _taskList.firstWhere((element) => element.id == id);
    if (task != null) {
      realm.write(() {
        task.name = name;
      });
      notifyListeners();
    }
  }

  void updateTaskMemo(int id, String memo) {
    final task = _taskList.firstWhere((element) => element.id == id);
    if (task != null) {
      realm.write(() {
        task.memo = memo;
      });
      notifyListeners();
    }
  }

  void deleteTask(int taskId) {
    var task = _taskList.firstWhere((element) => element.id == taskId);
    realm.write(() => realm.delete<Task>(task));
    _taskList.remove(task);
    notifyListeners();
  }

  void addPomodoro(int taskId, int durationMinutes) {
    var task = realm.find<Task>(taskId);
    var taskName = task?.name ?? "";
    var memo = task?.memo;
    if (taskName.isEmpty == true) {
      taskId = -1;
      taskName = "No name";
    }

    realm.write(() {
      var now = DateTime.now();
      String todayStr = DateFormat('yyyyMMdd').format(now);
      realm.add(Pomodoro(now.millisecondsSinceEpoch, int.parse(todayStr), taskId, taskName, now, durationMinutes,
          memo: memo));
    });

    loadTodayPomodoroCount();
    notifyListeners();
  }

  void loadTodayPomodoroCount() {
    String todayStr = DateFormat('yyyyMMdd').format(DateTime.now());
    _todayPomodoroCount = realm.query<Pomodoro>("todayInt == \$0", [int.parse(todayStr)]).length;
  }

  void deletePomodoroList(List<Pomodoro> pomodoroList) {
    realm.write(() => realm.deleteMany<Pomodoro>(pomodoroList));
    loadTodayPomodoroCount();
    notifyListeners();
  }

  void deletePomodoro(Pomodoro pomodoro) {
    realm.write(() => realm.delete<Pomodoro>(pomodoro));
    loadTodayPomodoroCount();
    notifyListeners();
  }

  void updatePomodoroMemo(Pomodoro pomodoro, String? memo) {
    realm.write(() {
      pomodoro.memo = memo;
    });
  }

  List<Pomodoro> loadPomodoroList(DateTime dateTime) {
    String todayStr = DateFormat('yyyyMMdd').format(dateTime);
    return realm.query<Pomodoro>("todayInt == \$0", [int.parse(todayStr)]).toList();
  }
}
