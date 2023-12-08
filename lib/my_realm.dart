import 'package:flutter/foundation.dart';
import 'package:good_timer/realm_models.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

class MyRealm {
  static final MyRealm instance = MyRealm._internal();
  factory MyRealm() => instance;
  late final Realm realm;

  MyRealm._internal() {
    var config = Configuration.local([Task.schema, Pomodoro.schema], schemaVersion: 5,
        migrationCallback: (migration, oldVersion) {
      switch (oldVersion) {
        case 2:
          migration.renameProperty("Pomodoro", "todayInt", "dayInt");
        case 3:
          migration.renameProperty("Pomodoro", "durationMinutes", "focusTimeMinutes");
        case 4:
          migration.renameProperty("Pomodoro", "doneTime", "endTime");
      }
    });
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
  List<Task> getTaskList(bool showAllTask, bool sortByName) {
    final List<Task> result;
    if (showAllTask) {
      result = realm.all<Task>().toList();
    } else {
      result = realm.query<Task>("isHidden = false").toList();
    }
    if (sortByName) {
      result.sort((t1, t2) => t1.name.compareTo(t2.name));
    }
    return result;
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
    return realm.query<Pomodoro>("dayInt == $todayStr").length;
  }

  int getPomodoroCount(int dayInt, int filterTaskId) {
    if (filterTaskId == 0) {
      return realm.query<Pomodoro>("dayInt == $dayInt").length;
    } else {
      return realm.query<Pomodoro>("dayInt == $dayInt and taskId == $filterTaskId").length;
    }
  }

  List<Pomodoro> getPomodoroList(DateTime dateTime, int filterTaskId) {
    String dayStr = DateFormat('yyyyMMdd').format(dateTime);
    if (filterTaskId == 0) {
      return realm.query<Pomodoro>("dayInt == $dayStr").toList();
    } else {
      return realm.query<Pomodoro>("dayInt == $dayStr and taskId == $filterTaskId").toList();
    }
  }

  void addPomodoro(DateTime startTime, String? instantTaskName, int taskId, int focusTimeMinutes) {
    final String taskName;
    final String? memo;
    Task? task;

    if (instantTaskName?.isNotEmpty == true) {
      taskId = 0;
      taskName = instantTaskName!;
      memo = null;
    } else {
      task = realm.find<Task>(taskId);
      if (task != null) {
        taskName = task.name;
        memo = task.memo;
      } else {
        taskId = 0;
        taskName = "No task name";
        memo = null;
      }
    }

    realm.write(() {
      if (task != null) task.pomoCount = task.pomoCount + 1;
      var endTime = DateTime.now();
      String todayStr = DateFormat('yyyyMMdd').format(endTime);
      realm.add(Pomodoro(endTime.millisecondsSinceEpoch, int.parse(todayStr), taskId, taskName, startTime, endTime,
          true, focusTimeMinutes,
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
}
