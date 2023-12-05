import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:good_timer/MyRealm.dart';
import 'package:good_timer/my_providers.dart';
import 'package:good_timer/realm_models.dart';
import 'package:good_timer/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'generated/l10n.dart';

class _Event {
  int count;
  _Event(this.count);
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
  final Map<int, _Event> eventMap = {};

  @override
  void initState() {
    super.initState();
    _pomodoroList = MyRealm.instance.getPomodoroList(_focusedDay);
    _calendarFormat = _getCalendarFormat();
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
              firstDay: DateTime.now().subtract(const Duration(days: 365 * 10 + 2)),
              lastDay: DateTime.now().add(const Duration(days: 365 * 10 + 2)),
              availableCalendarFormats: {
                CalendarFormat.month: S.of(context).calendar_month,
                CalendarFormat.twoWeeks: S.of(context).calendar_two_weeks,
                CalendarFormat.week: S.of(context).calendar_week,
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                _setCalendarFormat(format);
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                eventMap.clear();
              },
              eventLoader: (day) {
                int dayInt = toDayInt(day);
                eventMap.putIfAbsent(dayInt, () => _Event(MyRealm.instance.getPomodoroCount(dayInt)));
                if (eventMap[dayInt]!.count == 0) return [];
                return [eventMap[dayInt]];
              },
              calendarBuilders: buildCalendarBuilders(),
              calendarStyle:
                  const CalendarStyle(markerDecoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Text(
              S.of(context).pomodoro_count_fmt(_pomodoroList.length),
              style: const TextStyle(color: Colors.deepOrange),
            ),
            Text(DateFormat.yMMMMd().format(_focusedDay)),
          ]),
          Expanded(child: _buildPomodoroList(context))
        ]));
  }

  int toDayInt(DateTime dateTime) {
    return int.parse(DateFormat('yyyyMMdd').format(dateTime));
  }

  CalendarBuilders<dynamic> buildCalendarBuilders() {
    return CalendarBuilders(singleMarkerBuilder: (BuildContext context, DateTime day, dynamic countInfo) {
      int count = (countInfo as _Event).count;
      if (count == 0) return null;
      return Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.rectangle, color: Colors.orange), //Change color
          width: 20.0,
          height: 16.0,
          child: Text(
            count.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ));
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = selectedDay; // update `_focusedDay` here as well
        _pomodoroList = MyRealm.instance.getPomodoroList(_focusedDay);
      });
    }
  }

  CalendarFormat _getCalendarFormat() {
    final settings = context.read<SettingsProvider>();
    switch (settings.calendarFormat) {
      case 0:
        return CalendarFormat.month;
      case 1:
        return CalendarFormat.twoWeeks;
      case 2:
        return CalendarFormat.week;
      default:
        return CalendarFormat.month;
    }
  }

  void _setCalendarFormat(CalendarFormat calendarFormat) {
    final settings = context.read<SettingsProvider>();
    switch (calendarFormat) {
      case CalendarFormat.month:
        settings.setCalendarFormat(0);
        break;
      case CalendarFormat.twoWeeks:
        settings.setCalendarFormat(1);
        break;
      case CalendarFormat.week:
        settings.setCalendarFormat(2);
        break;
      default:
        settings.setCalendarFormat(0);
        break;
    }
  }

  Widget _buildPomodoroList(BuildContext context) {
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
                leading: Text(
                  (index + 1).toString(),
                  style: const TextStyle(fontSize: 17, color: Colors.white),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_pomodoroList[index].taskName, overflow: TextOverflow.ellipsis),
                    Text(DateFormat('HH:mm').format(_pomodoroList[index].doneTime.toLocal()))
                  ],
                ),
                subtitle: _pomodoroList[index].memo?.isNotEmpty == true
                    ? Text(_pomodoroList[index].memo!, style: const TextStyle(color: Colors.orange))
                    : null,
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
                  eventMap[pomodoro.dayInt]?.count--;
                  MyRealm.instance.deletePomodoro(pomodoro);
                  taskList.notifyTodayPomodoroCount();
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
      MyRealm.instance.updatePomodoroMemo(pomodoro, memo);
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
                  if (_pomodoroList.isNotEmpty) {
                    int dayInt = _pomodoroList[0].dayInt;
                    eventMap[dayInt]?.count = 0;
                  }
                  MyRealm.instance.deletePomodoroList(_pomodoroList);
                  context.read<TaskListProvider>().notifyTodayPomodoroCount();
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
