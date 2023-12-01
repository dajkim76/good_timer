// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_models.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Task extends _Task with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Task(
    int id,
    String name, {
    int pomoCount = 0,
    int orderValue = 0,
    String? extra,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Task>({
        'pomoCount': 0,
        'orderValue': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'pomoCount', pomoCount);
    RealmObjectBase.set(this, 'orderValue', orderValue);
    RealmObjectBase.set(this, 'extra', extra);
  }

  Task._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => throw RealmUnsupportedSetError();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int get pomoCount => RealmObjectBase.get<int>(this, 'pomoCount') as int;
  @override
  set pomoCount(int value) => RealmObjectBase.set(this, 'pomoCount', value);

  @override
  int get orderValue => RealmObjectBase.get<int>(this, 'orderValue') as int;
  @override
  set orderValue(int value) => RealmObjectBase.set(this, 'orderValue', value);

  @override
  String? get extra => RealmObjectBase.get<String>(this, 'extra') as String?;
  @override
  set extra(String? value) => RealmObjectBase.set(this, 'extra', value);

  @override
  Stream<RealmObjectChanges<Task>> get changes =>
      RealmObjectBase.getChanges<Task>(this);

  @override
  Task freeze() => RealmObjectBase.freezeObject<Task>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Task._);
    return const SchemaObject(ObjectType.realmObject, Task, 'Task', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('pomoCount', RealmPropertyType.int),
      SchemaProperty('orderValue', RealmPropertyType.int),
      SchemaProperty('extra', RealmPropertyType.string, optional: true),
    ]);
  }
}
