import 'package:flutter/foundation.dart';
import 'package:good_timer/realm_models.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

class MyRealm {
  static final MyRealm instance = MyRealm._internal();
  factory MyRealm() => instance;
  late final Realm realm;

  MyRealm._internal() {
    var config = Configuration.local([Task.schema, Pomodoro.schema], schemaVersion: 2);
    realm = Realm(config);

    if (kDebugMode && realm.all<Task>().isEmpty) {
      realm.write(() {
        realm.add(Task(DateTime.now().millisecondsSinceEpoch, "Test task #1"));
        realm.add(Task(DateTime.now().millisecondsSinceEpoch + 1, "Test task #2"));
      });
    }
  }

  /**
   * Task
   */
  List<Task> loadTaskList(bool showAllTask) {
    if (showAllTask) {
      return realm.all<Task>().toList();
    } else {
      return realm.query<Task>("isHidden = false").toList();
    }
  }

  String? getTaskName(int id) {
    return realm.find<Task>(id)?.name;
  }

  String? getTaskMemo(int id) {
    return realm.find<Task>(id)?.memo;
  }

  Task addTask(String name) {
    var newTask = Task(DateTime.now().millisecondsSinceEpoch, name);
    realm.write(() {
      realm.add(newTask);
    });
    return newTask;
  }

  void updateTaskName(Task task, String name) {
    realm.write(() {
      task.name = name;
    });
  }

  void toggleHidden(Task task) {
    realm.write(() {
      task.isHidden = !task.isHidden;
    });
  }

  void updateTaskMemo(Task task, String memo) {
    realm.write(() {
      task.memo = memo;
    });
  }

  void deleteTask(Task task) {
    realm.write(() => realm.delete<Task>(task));
  }

  /**
   * Pomodoro
   */
  int getTodayPomodoroCount() {
    String todayStr = DateFormat('yyyyMMdd').format(DateTime.now());
    return realm.query<Pomodoro>("todayInt == \$0", [int.parse(todayStr)]).length;
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
      if (task != null) task.pomoCount = task.pomoCount + 1;
      var now = DateTime.now();
      String todayStr = DateFormat('yyyyMMdd').format(now);
      realm.add(Pomodoro(now.millisecondsSinceEpoch, int.parse(todayStr), taskId, taskName, now, durationMinutes,
          memo: memo));
    });
  }

  void deletePomodoroList(List<Pomodoro> pomodoroList) {
    realm.write(() => realm.deleteMany<Pomodoro>(pomodoroList));
  }

  void deletePomodoro(Pomodoro pomodoro) {
    realm.write(() => realm.delete<Pomodoro>(pomodoro));
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
