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

class Pomodoro extends _Pomodoro
    with RealmEntity, RealmObjectBase, RealmObject {
  Pomodoro(
    int id,
    int todayInt,
    int taskId,
    String name,
    DateTime doneTime,
    int durationMinutes, {
    String? memo,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'todayInt', todayInt);
    RealmObjectBase.set(this, 'taskId', taskId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'doneTime', doneTime);
    RealmObjectBase.set(this, 'durationMinutes', durationMinutes);
    RealmObjectBase.set(this, 'memo', memo);
  }

  Pomodoro._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => throw RealmUnsupportedSetError();

  @override
  int get todayInt => RealmObjectBase.get<int>(this, 'todayInt') as int;
  @override
  set todayInt(int value) => throw RealmUnsupportedSetError();

  @override
  int get taskId => RealmObjectBase.get<int>(this, 'taskId') as int;
  @override
  set taskId(int value) => throw RealmUnsupportedSetError();

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => throw RealmUnsupportedSetError();

  @override
  DateTime get doneTime =>
      RealmObjectBase.get<DateTime>(this, 'doneTime') as DateTime;
  @override
  set doneTime(DateTime value) => RealmObjectBase.set(this, 'doneTime', value);

  @override
  int get durationMinutes =>
      RealmObjectBase.get<int>(this, 'durationMinutes') as int;
  @override
  set durationMinutes(int value) =>
      RealmObjectBase.set(this, 'durationMinutes', value);

  @override
  String? get memo => RealmObjectBase.get<String>(this, 'memo') as String?;
  @override
  set memo(String? value) => RealmObjectBase.set(this, 'memo', value);

  @override
  Stream<RealmObjectChanges<Pomodoro>> get changes =>
      RealmObjectBase.getChanges<Pomodoro>(this);

  @override
  Pomodoro freeze() => RealmObjectBase.freezeObject<Pomodoro>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Pomodoro._);
    return const SchemaObject(ObjectType.realmObject, Pomodoro, 'Pomodoro', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('todayInt', RealmPropertyType.int),
      SchemaProperty('taskId', RealmPropertyType.int),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('doneTime', RealmPropertyType.timestamp),
      SchemaProperty('durationMinutes', RealmPropertyType.int),
      SchemaProperty('memo', RealmPropertyType.string, optional: true),
    ]);
  }
}
