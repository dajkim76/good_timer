import 'package:flutter/material.dart';
import 'package:good_timer/my_providers.dart';
import 'package:provider/provider.dart';

class TaskListDrawer extends StatelessWidget {
  const TaskListDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    var taskListProvider = Provider.of<TaskListProvider>(context);

    return Container(
      width: MediaQuery.of(context).size.width / 2,
      color: Colors.white,
      child: ListView.builder(
          itemCount: taskListProvider.taskList.length,
          itemBuilder: (context, index) => ListTile(
                title: Text(taskListProvider.taskList[index].name),
                onTap: () {
                  Scaffold.of(context).closeEndDrawer();
                },
              )),
    );
  }
}
