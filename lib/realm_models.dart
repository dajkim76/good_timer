import 'package:realm/realm.dart';

part 'realm_models.g.dart';

@RealmModel()
class _Task {
  @PrimaryKey()
  late final int id;

  late final int createdTime;

  late String name;
}
