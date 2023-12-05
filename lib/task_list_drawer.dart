import 'package:flutter/material.dart';
import 'package:good_timer/my_providers.dart';
import 'package:good_timer/pomodo_count_icon.dart';
import 'package:good_timer/realm_models.dart';
import 'package:provider/provider.dart';

import 'MyRealm.dart';
import 'generated/l10n.dart';

class TaskListDrawer extends StatefulWidget {
  const TaskListDrawer({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TaskListDrawerState();
  }
}

class _TaskListDrawerState extends State<TaskListDrawer> {
  late List<Task> taskList;

  @override
  void initState() {
    super.initState();
    var settings = context.read<SettingsProvider>();
    taskList = MyRealm.instance.loadTaskList(settings.showHiddenTask);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 2 / 3,
      color: Theme.of(context).secondaryHeaderColor,
      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
      child: Column(
        children: [buildHeader(context), taskList.isEmpty ? buildEmptyData(context) : Expanded(child: buildListView())],
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
        itemCount: taskList.length,
        itemBuilder: (context, index) => ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              title: buildTaskTitle(taskList[index]),
              subtitle: taskList[index].memo?.isNotEmpty == true
                  ? Text(taskList[index].memo!, style: const TextStyle(color: Colors.orange))
                  : null,
              contentPadding: const EdgeInsets.all(0),
              onTap: () {
                context.read<SettingsProvider>().setSelectedTask(taskList[index]);
                Scaffold.of(context).closeEndDrawer();
              },
              leading: PomodoroCountIcon(taskList[index].pomoCount),
              trailing: buildPopupMenuButton(taskList[index]),
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
        onSelected: onClickShowHiddenTask,
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              value: 0,
              child: Row(children: [
                context.read<SettingsProvider>().showHiddenTask
                    ? const Icon(Icons.check_box_outlined)
                    : const Icon(Icons.check_box_outline_blank),
                Text(S.of(context).show_hidden_task)
              ]),
            )
          ];
        },
      ),
    ]);
  }

  Widget buildTaskTitle(Task task) {
    if (task.isHidden) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(task.name, overflow: TextOverflow.ellipsis), const Icon(Icons.visibility_off)]);
    } else {
      return Text(task.name, overflow: TextOverflow.ellipsis);
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

  void onClickShowHiddenTask(int _) {
    var settings = context.read<SettingsProvider>();
    bool showHiddenTask = !settings.showHiddenTask;
    settings.setShowHiddenTask(showHiddenTask);

    setState(() {
      taskList = MyRealm.instance.loadTaskList(showHiddenTask);
    });
  }

  void onClickAddTask(BuildContext context) async {
    String? name = await _showTextInputDialog(context, S.of(context).task_name);
    if (name?.isNotEmpty == true) {
      Task newTask = MyRealm.instance.addTask(name!);
      setState(() {
        taskList.add(newTask);
      });
    }
  }

  Future<String?> _showTextInputDialog(BuildContext context, String title, {String text = ""}) async {
    final textFieldController = TextEditingController()..text = text;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
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
                    taskList.remove(task);
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
