import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:good_timer/my_providers.dart';
import 'package:good_timer/realm_models.dart';
import 'package:good_timer/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'generated/l10n.dart';

class Event {
  String name;
  Event(this.name);
}

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<StatefulWidget> createState() => _PomodoroState();
}

class _PomodoroState extends State<PomodoroPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late List<Pomodoro> _pomodoroList;

  @override
  void initState() {
    super.initState();
    _pomodoroList = context.read<TaskListProvider>().loadPomodoroList(_focusedDay);
    _portraitModeOnly();
  }

  @override
  void dispose() {
    _enableRotation();
    super.dispose();
  }

  /// blocks rotation; sets orientation to: portrait
  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _enableRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final taskListProvider = context.watch<TaskListProvider>();
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).pomodoro_count),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _onClickDeleteAll,
              tooltip: S.of(context).delete_all,
            )
          ],
        ),
        body: Column(children: [
          TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 10, 16),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              eventLoader: (day) {
                // TODO: load monthly pomodoro list
                // if (day.weekday == DateTime.monday) {
                //   return [Event('Cyclic event1'), Event('Cyclic event2')];
                // }

                return [];
              },
              calendarStyle:
                  const CalendarStyle(markerDecoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Text(DateFormat.yMMMMd().format(_focusedDay)),
            Text(S.of(context).pomodoro_count_fmt(_pomodoroList.length))
          ]),
          Expanded(child: _buildPomodoroLost(context, taskListProvider))
        ]));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_focusedDay, focusedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay; // update `_focusedDay` here as well
        _pomodoroList = context.read<TaskListProvider>().loadPomodoroList(_focusedDay);
      });
    }
  }

  Widget _buildPomodoroLost(BuildContext context, final TaskListProvider taskListProvider) {
    return _pomodoroList.isEmpty
        ? Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(S.of(context).empty_data)
            ],
          )
        : ListView.builder(
            itemCount: _pomodoroList.length,
            itemBuilder: (context, index) => ListTile(
                leading: getPomodoroCountIcon(index + 1),
                title: Text(
                  _pomodoroList[index].taskName,
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _pomodoroList[index].memo ?? "",
                      style: const TextStyle(color: Colors.yellowAccent),
                    ),
                    Text(DateFormat('HH:mm').format(_pomodoroList[index].doneTime.toLocal()))
                  ],
                ),
                trailing: PopupMenuButton<int>(
                  onSelected: (int menuIndex) {
                    if (menuIndex == 0) onClickMemo(context, _pomodoroList[index]);
                    if (menuIndex == 1) onClickDelete(context, _pomodoroList[index]);
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 0,
                        child: Text(S.of(context).memo),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text(S.of(context).delete),
                      )
                    ];
                  },
                )));
  }

  void onClickDelete(BuildContext context, Pomodoro pomodoro) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(pomodoro.taskName),
            content: Text(S.of(context).confirm_deletion),
            actions: <Widget>[
              TextButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(S.of(context).ok),
                onPressed: () {
                  // delete
                  var taskList = context.read<TaskListProvider>();
                  taskList.deletePomodoro(pomodoro);
                  setState(() {
                    _pomodoroList.remove(pomodoro);
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void onClickMemo(BuildContext context, Pomodoro pomodoro) async {
    var memo = await _showTextInputDialog(context, text: pomodoro.memo ?? "");
    if (memo == null) return; // onCancel
    setState(() {
      context.read<TaskListProvider>().updatePomodoroMemo(pomodoro, memo);
    });
  }

  Future<String?> _showTextInputDialog(BuildContext context, {String text = ""}) async {
    final textFieldController = TextEditingController()..text = text;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).memo),
            content: TextField(
              controller: textFieldController,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(S.of(context).ok),
                onPressed: () => Navigator.pop(context, textFieldController.text),
              ),
            ],
          );
        });
  }

  void _onClickDeleteAll() {
    if (_pomodoroList.isEmpty) {
      showToast(S.of(context).empty_data);
      return;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).delete_all),
            content: Text(S.of(context).confirm_deletion_all),
            actions: <Widget>[
              TextButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(S.of(context).ok),
                onPressed: () {
                  // delete
                  var taskList = context.read<TaskListProvider>();
                  taskList.deletePomodoroList(_pomodoroList);
                  setState(() {
                    _pomodoroList.clear();
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}

Icon getPomodoroCountIcon(int count) {
  switch (count) {
    case 1:
      return const Icon(
        Icons.looks_one,
        color: Colors.yellow,
      );
    case 2:
      return const Icon(
        Icons.looks_two,
        color: Colors.yellow,
      );
    case 3:
      return const Icon(
        Icons.looks_3,
        color: Colors.yellow,
      );
    case 4:
      return const Icon(
        Icons.looks_4,
        color: Colors.yellow,
      );
    case 5:
      return const Icon(
        Icons.looks_5,
        color: Colors.yellow,
      );
    case 6:
      return const Icon(
        Icons.looks_6,
        color: Colors.yellow,
      );
  }
  return const Icon(
    Icons.alarm_on,
    color: Colors.yellow,
  );
}
