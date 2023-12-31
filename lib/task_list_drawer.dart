import 'package:flutter/material.dart';
import 'package:good_timer/my_providers.dart';
import 'package:good_timer/pomodoro_count_icon.dart';
import 'package:good_timer/realm_models.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';
import 'my_realm.dart';

class TaskListDrawer extends StatefulWidget {
  const TaskListDrawer({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TaskListDrawerState();
  }
}

class _TaskListDrawerState extends State<TaskListDrawer> {
  late List<Task> _taskList;
  final _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var settings = context.read<SettingsProvider>();
    _taskList = MyRealm.instance.getTaskList(settings.showHiddenTask, settings.sortByTaskName);
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 3 / 4,
      color: Theme.of(context).dialogBackgroundColor,
      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
      child: Column(
        children: [
          buildHeader(context),
          _taskList.isEmpty ? buildEmptyData(context) : Expanded(child: buildListView())
        ],
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
        itemCount: _taskList.length,
        itemBuilder: (context, index) => ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              title: buildTaskTitle(_taskList[index]),
              subtitle: _taskList[index].memo?.isNotEmpty == true
                  ? Text(_taskList[index].memo!,
                      overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.blue, fontSize: 14))
                  : null,
              contentPadding: const EdgeInsets.all(0),
              horizontalTitleGap: 8,
              onTap: () {
                context.read<SettingsProvider>().setSelectedTask(_taskList[index]);
                Scaffold.of(context).closeEndDrawer();
              },
              leading: PomodoroCountIcon(_taskList[index].pomoCount),
              trailing: buildPopupMenuButton(_taskList[index]),
            ));
  }

  Padding buildEmptyData(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
      child: Text(
        S.of(context).empty_data,
      ),
    );
  }

  Row buildHeader(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton.icon(
          onPressed: () {
            onClickAddTask(context);
          },
          icon: const Icon(Icons.add),
          label: Text(S.of(context).add_task)),
      PopupMenuButton<int>(
        onSelected: onClickHeaderMoreMenu,
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              value: 0,
              child: Row(children: [
                context.read<SettingsProvider>().showHiddenTask
                    ? const Icon(Icons.check_box_outlined)
                    : const Icon(Icons.check_box_outline_blank),
                const SizedBox(width: 5),
                Text(S.of(context).show_hidden_task)
              ]),
            ),
            PopupMenuItem(
              value: 1,
              child: Row(children: [
                context.read<SettingsProvider>().sortByTaskName
                    ? const Icon(Icons.check_box_outlined)
                    : const Icon(Icons.check_box_outline_blank),
                const SizedBox(width: 5),
                Text(S.of(context).sort_by_name)
              ]),
            )
          ];
        },
      ),
    ]);
  }

  Widget buildTaskTitle(Task task) {
    if (task.isHidden) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          task.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15),
        ),
        const Icon(
          Icons.visibility_off,
          size: 20,
        )
      ]);
    } else {
      return Text(task.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15));
    }
  }

  PopupMenuButton<int> buildPopupMenuButton(Task task) {
    return PopupMenuButton<int>(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 0,
            child: Text(S.of(context).rename),
          ),
          PopupMenuItem(
            value: 2,
            child: Text(S.of(context).memo),
          ),
          PopupMenuItem(
            value: 3,
            child: task.isHidden ? Text(S.of(context).show) : Text(S.of(context).hide),
          ),
          PopupMenuItem(
            value: 1,
            child: Text(S.of(context).delete),
          )
        ];
      },
      onSelected: (int menuIndex) {
        if (menuIndex == 0) onClickRename(task);
        if (menuIndex == 1) onClickDelete(task);
        if (menuIndex == 2) onClickMemo(task);
        if (menuIndex == 3) onClickToggleHidden(task);
      },
    );
  }

  void onClickHeaderMoreMenu(int index) {
    if (index == 0) {
      var settings = context.read<SettingsProvider>();
      bool showHiddenTask = !settings.showHiddenTask;
      settings.setShowHiddenTask(showHiddenTask);

      setState(() {
        _taskList = MyRealm.instance.getTaskList(settings.showHiddenTask, settings.sortByTaskName);
      });
    } else if (index == 1) {
      var settings = context.read<SettingsProvider>();
      bool sortByTaskName = !settings.sortByTaskName;
      settings.setSortByTaskName(sortByTaskName);

      setState(() {
        _taskList = MyRealm.instance.getTaskList(settings.showHiddenTask, settings.sortByTaskName);
      });
    }
  }

  void onClickAddTask(BuildContext context) async {
    String? name = await _showTextInputDialog(context, S.of(context).task_name);
    if (name?.isNotEmpty == true) {
      Task newTask = MyRealm.instance.addTask(name!);
      setState(() {
        _taskList.add(newTask);
      });
    }
  }

  Future<String?> _showTextInputDialog(BuildContext context, String title, {String text = ""}) async {
    _textFieldController.text = text;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
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

  void onClickDelete(Task task) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(task.name),
            content: Text(S.of(context).confirm_deletion),
            actions: <Widget>[
              TextButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(S.of(context).ok),
                onPressed: () {
                  MyRealm.instance.deleteTask(task);
                  setState(() {
                    _taskList.remove(task);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void onClickRename(Task task) async {
    var taskName = task.name;
    var newName = await _showTextInputDialog(context, S.of(context).task_name, text: taskName);
    if (newName?.isNotEmpty == true) {
      MyRealm.instance.updateTaskName(task, newName!);
      setState(() {});
    }
  }

  void onClickMemo(Task task) async {
    var newMemo = await _showTextInputDialog(context, S.of(context).memo, text: task.memo ?? "");
    if (newMemo != null) {
      MyRealm.instance.updateTaskMemo(task, newMemo);
      setState(() {});
    }
  }

  void onClickToggleHidden(Task task) async {
    MyRealm.instance.toggleHidden(task);
    setState(() {});
  }
}
