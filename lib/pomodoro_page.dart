import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:good_timer/my_providers.dart';
import 'package:good_timer/my_realm.dart';
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
  int _filterTaskId = 0;
  String _filterTaskName = "";
  final Map<int, _Event> _eventMap = {};
  final _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pomodoroList = MyRealm.instance.getPomodoroList(_focusedDay, _filterTaskId);
    _calendarFormat = _getCalendarFormat();
    _portraitModeOnly();
  }

  @override
  void dispose() {
    _enableRotation();
    _textFieldController.dispose();
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
        ),
        body: Column(children: [
          buildFilterWidget(),
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
              rowHeight: CalendarFormat.month != _calendarFormat ? 80 : 52,
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
                _eventMap.clear();
              },
              eventLoader: (day) {
                int dayInt = toDayInt(day);
                _eventMap.putIfAbsent(dayInt, () => _Event(MyRealm.instance.getPomodoroCount(dayInt, _filterTaskId)));
                if (_eventMap[dayInt]!.count == 0) return [];
                return [_eventMap[dayInt]];
              },
              calendarBuilders: buildCalendarBuilders(),
              calendarStyle:
                  const CalendarStyle(markerDecoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Text(DateFormat.yMMMMd().format(_focusedDay)),
            OutlinedButton.icon(
              onPressed: _onClickDeleteAll,
              label: Text(
                S.of(context).pomodoro_count_fmt(_pomodoroList.length),
                style: const TextStyle(color: Colors.orange),
              ),
              icon: const Icon(Icons.delete_forever),
            ),
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
          height: 18.0,
          child: Text(
            count.toString(),
            style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
          ));
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = selectedDay; // update `_focusedDay` here as well
        _pomodoroList = MyRealm.instance.getPomodoroList(_focusedDay, _filterTaskId);
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                horizontalTitleGap: 8,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _pomodoroList[index].taskName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      "${DateFormat.Hm().format(_pomodoroList[index].endTime.toLocal())} (${S.of(context).minutes_fmt(_pomodoroList[index].focusTimeMinutes)})",
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    )
                  ],
                ),
                subtitle: _pomodoroList[index].memo?.isNotEmpty == true
                    ? Text(_pomodoroList[index].memo!,
                        overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.blue, fontSize: 14))
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
                  _eventMap[pomodoro.dayInt]?.count--;
                  MyRealm.instance.deletePomodoro(pomodoro);
                  context.read<PomodoroCountProvider>().notifyTodayPomodoroCount();
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
    _textFieldController.text = text;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).memo),
            content: TextField(
              controller: _textFieldController,
              autofocus: true,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(S.of(context).ok),
                onPressed: () => Navigator.pop(context, _textFieldController.text),
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
                    _eventMap[dayInt]?.count = 0;
                  }
                  MyRealm.instance.deletePomodoroList(_pomodoroList);
                  context.read<PomodoroCountProvider>().notifyTodayPomodoroCount();
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

  void _onClickFilter() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(title: Text(S.of(context).select_task), content: _buildTaskList(), actions: <Widget>[
            TextButton(
                child: Text(S.of(context).cancel),
                onPressed: () {
                  Navigator.pop(context);
                }),
            TextButton(
                child: Text(S.of(context).all_tasks),
                onPressed: () {
                  Navigator.pop(context);
                  setFilterTaskList(0, "");
                })
          ]);
        });
  }

  Widget _buildTaskList() {
    final settings = context.read<SettingsProvider>();
    final list = MyRealm.instance.getTaskList(settings.showHiddenTask, settings.sortByTaskName);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (ctx, index) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              setFilterTaskList(list[index].id, list[index].name);
            },
            child: Text(
              list[index].name,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
        itemCount: list.length,
      ),
    );
  }

  void setFilterTaskList(int filterTaskId, String filterTaskName) {
    setState(() {
      _filterTaskId = filterTaskId;
      _filterTaskName = filterTaskName;
      _eventMap.clear();
      _pomodoroList = MyRealm.instance.getPomodoroList(_focusedDay, _filterTaskId);
    });
  }

  Widget buildFilterWidget() {
    return OutlinedButton.icon(
      onPressed: _onClickFilter,
      label: Text(
        _filterTaskId == 0 ? S.of(context).all_tasks : _filterTaskName,
        overflow: TextOverflow.ellipsis,
      ),
      icon: const Icon(Icons.filter_alt),
    );
  }
}
