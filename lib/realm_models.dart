import 'package:realm/realm.dart';

part 'realm_models.g.dart';

@RealmModel()
class _Task {
  @PrimaryKey()
  // 생성시간
  late final int id;
  // 이름
  late String name;
  // total Pomodoro count
  int pomoCount = 0;
  // 순서 index
  int orderValue = 0;
  // 나중에
  String? extra;
}
