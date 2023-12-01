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
      width: MediaQuery.of(context).size.width / 2,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, 20, 10, 10),
      child: Column(
        children: [
          OutlinedButton(
              onPressed: () {
                onClickAddTask(context);
              },
              child: Text(S.of(context).add_task)),
          Expanded(
              child: ListView.builder(
            itemCount: taskListProvider.taskList.length,
            itemBuilder: (context, index) => ListTile(
              visualDensity: const VisualDensity(vertical: -4),
              title: Text(taskListProvider.taskList[index].name),
              contentPadding: const EdgeInsets.all(0),
              onTap: () {
                settings.setSelectedTaskId(taskListProvider.taskList[index].id);
                Scaffold.of(context).closeEndDrawer();
              },
              onLongPress: () {
                onLongClickTask(context, taskListProvider.taskList[index].id);
              },
            ),
          ))
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

  Future<String?> _showTextInputDialog(BuildContext context) async {
    final textFieldController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(S.of(context).task_name),
            content: TextField(
              controller: textFieldController,
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text(S.of(context).ok),
                onPressed: () => Navigator.pop(context, textFieldController.text),
              ),
            ],
          );
        });
  }

  void onLongClickTask(BuildContext context, int taskId) async {
    var taskListProvider = context.read<TaskListProvider>();
    var taskName = taskListProvider.getSelectedTaskName(taskId) ?? "NO NAME";

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(taskName),
            content: Text(S.of(context).confirm_deletion),
            actions: <Widget>[
              ElevatedButton(
                child: Text(S.of(context).cancel),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
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
}
