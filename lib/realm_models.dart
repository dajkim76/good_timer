import 'package:realm/realm.dart';

part 'realm_models.g.dart';

@RealmModel()
class _Task {
  @PrimaryKey()
  // 생성시간
  late final int id;
  // 이름
  late String name;

  late String? memo;

  bool isHidden = false;

  // total Pomodoro count
  int pomoCount = 0;
  // 순서 index
  int orderValue = 0;
  // 나중에
  String? extra;
}

@RealmModel()
class _Pomodoro {
  @PrimaryKey()
  late final int id;
  late final int todayInt; // 20230601
  late final int taskId;
  late final String taskName;
  late DateTime doneTime;
  late int durationMinutes;
  String? memo;
  String? extra;
}
