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
    String? memo,
    bool isHidden = false,
    int pomoCount = 0,
    int orderValue = 0,
    String? extra,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Task>({
        'isHidden': false,
        'pomoCount': 0,
        'orderValue': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'memo', memo);
    RealmObjectBase.set(this, 'isHidden', isHidden);
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
  String? get memo => RealmObjectBase.get<String>(this, 'memo') as String?;
  @override
  set memo(String? value) => RealmObjectBase.set(this, 'memo', value);

  @override
  bool get isHidden => RealmObjectBase.get<bool>(this, 'isHidden') as bool;
  @override
  set isHidden(bool value) => RealmObjectBase.set(this, 'isHidden', value);

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
      SchemaProperty('memo', RealmPropertyType.string, optional: true),
      SchemaProperty('isHidden', RealmPropertyType.bool),
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
    int dayInt,
    int taskId,
    String taskName,
    DateTime doneTime,
    int focusTimeMinutes, {
    String? memo,
    String? extra,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'dayInt', dayInt);
    RealmObjectBase.set(this, 'taskId', taskId);
    RealmObjectBase.set(this, 'taskName', taskName);
    RealmObjectBase.set(this, 'doneTime', doneTime);
    RealmObjectBase.set(this, 'focusTimeMinutes', focusTimeMinutes);
    RealmObjectBase.set(this, 'memo', memo);
    RealmObjectBase.set(this, 'extra', extra);
  }

  Pomodoro._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => throw RealmUnsupportedSetError();

  @override
  int get dayInt => RealmObjectBase.get<int>(this, 'dayInt') as int;
  @override
  set dayInt(int value) => throw RealmUnsupportedSetError();

  @override
  int get taskId => RealmObjectBase.get<int>(this, 'taskId') as int;
  @override
  set taskId(int value) => throw RealmUnsupportedSetError();

  @override
  String get taskName =>
      RealmObjectBase.get<String>(this, 'taskName') as String;
  @override
  set taskName(String value) => throw RealmUnsupportedSetError();

  @override
  DateTime get doneTime =>
      RealmObjectBase.get<DateTime>(this, 'doneTime') as DateTime;
  @override
  set doneTime(DateTime value) => RealmObjectBase.set(this, 'doneTime', value);

  @override
  int get focusTimeMinutes =>
      RealmObjectBase.get<int>(this, 'focusTimeMinutes') as int;
  @override
  set focusTimeMinutes(int value) =>
      RealmObjectBase.set(this, 'focusTimeMinutes', value);

  @override
  String? get memo => RealmObjectBase.get<String>(this, 'memo') as String?;
  @override
  set memo(String? value) => RealmObjectBase.set(this, 'memo', value);

  @override
  String? get extra => RealmObjectBase.get<String>(this, 'extra') as String?;
  @override
  set extra(String? value) => RealmObjectBase.set(this, 'extra', value);

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
      SchemaProperty('dayInt', RealmPropertyType.int),
      SchemaProperty('taskId', RealmPropertyType.int),
      SchemaProperty('taskName', RealmPropertyType.string),
      SchemaProperty('doneTime', RealmPropertyType.timestamp),
      SchemaProperty('focusTimeMinutes', RealmPropertyType.int),
      SchemaProperty('memo', RealmPropertyType.string, optional: true),
      SchemaProperty('extra', RealmPropertyType.string, optional: true),
    ]);
  }
}
