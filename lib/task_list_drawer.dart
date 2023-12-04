import 'package:flutter/material.dart';
import 'package:good_timer/my_providers.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';

class TaskListDrawer extends StatefulWidget {
  const TaskListDrawer({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TaskListDrawerState();
  }
}

class _TaskListDrawerState extends State<TaskListDrawer> {
  @override
  Widget build(BuildContext context) {
    var taskListProvider = Provider.of<TaskListProvider>(context);
    var settings = Provider.of<SettingsProvider>(context);

    return Container(
      width: MediaQuery.of(context).size.width * 2 / 3,
      color: Theme.of(context).secondaryHeaderColor,
      padding: EdgeInsets.fromLTRB(20, 20, 10, 10),
      child: Column(
        children: [
          ElevatedButton.icon(
              onPressed: () {
                onClickAddTask(context);
              },
              icon: const Icon(Icons.add),
              label: Text(S.of(context).add_task)),
          taskListProvider.taskList.isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Text(
                    S.of(context).empty_data,
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                      itemCount: taskListProvider.taskList.length,
                      itemBuilder: (context, index) => ListTile(
                            visualDensity: const VisualDensity(vertical: -4),
                            title: Text(taskListProvider.taskList[index].name, overflow: TextOverflow.ellipsis),
                            contentPadding: const EdgeInsets.all(0),
                            onTap: () {
                              settings.setSelectedTaskId(taskListProvider.taskList[index].id);
                              Scaffold.of(context).closeEndDrawer();
                            },
                            trailing: PopupMenuButton<int>(
                              onSelected: (int menuIndex) {
                                if (menuIndex == 0) onClickRename(context, taskListProvider.taskList[index].id);
                                if (menuIndex == 1) onClickDelete(context, taskListProvider.taskList[index].id);
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    value: 0,
                                    child: Text(S.of(context).rename),
                                  ),
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text(S.of(context).delete),
                                  )
                                ];
                              },
                            ),
                          )))
        ],
      ),
    );
  }

  void onClickAddTask(BuildContext context) async {
    var taskListProvider = context.read<TaskListProvider>();
    String? name = await _showTextInputDialog(context);
    if (name?.isNotEmpty == true) {
      taskListProvider.addTask(name!);
    }
  }

  Future<String?> _showTextInputDialog(BuildContext context, {String text = ""}) async {
    final textFieldController = TextEditingController()..text = text;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).task_name),
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

  void onClickDelete(BuildContext context, int taskId) async {
    var taskListProvider = context.read<TaskListProvider>();
    var taskName = taskListProvider.getSelectedTaskName(taskId) ?? "NO NAME";

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(taskName),
            content: Text(S.of(context).confirm_deletion),
            actions: <Widget>[
              TextButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(S.of(context).ok),
                onPressed: () {
                  taskListProvider.deleteTask(taskId);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void onClickRename(BuildContext context, int taskId) async {
    var taskListProvider = context.read<TaskListProvider>();
    var taskName = taskListProvider.getSelectedTaskName(taskId) ?? "NO NAME";
    var newName = await _showTextInputDialog(context, text: taskName);
    if (newName?.isNotEmpty == true) {
      taskListProvider.updateTask(taskId, newName!);
    }
  }
}
