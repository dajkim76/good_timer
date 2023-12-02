import 'package:flutter/material.dart';
import 'package:good_timer/my_providers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'generated/l10n.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskListProvider = context.watch<TaskListProvider>();
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).pomodoro_count),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                taskListProvider.clearPomodoro();
              },
              tooltip: S.of(context).delete_all,
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListView.builder(
                itemCount: taskListProvider.pomodoroList.length,
                itemBuilder: (context, index) => ListTile(
                      leading: getIcon(index),
                      title: Text(
                        taskListProvider.pomodoroList[index].name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(DateFormat('yyyy-MM-dd HH:mm')
                          .format(taskListProvider.pomodoroList[index].doneTime.toLocal())),
                    ))));
  }

  Icon getIcon(int index) {
    switch (index) {
      case 0:
        return const Icon(
          Icons.looks_one,
          color: Colors.white,
        );
      case 1:
        return const Icon(
          Icons.looks_two,
          color: Colors.white,
        );
      case 2:
        return const Icon(
          Icons.looks_3,
          color: Colors.white,
        );
      case 3:
        return const Icon(
          Icons.looks_4,
          color: Colors.white,
        );
      case 4:
        return const Icon(
          Icons.looks_5,
          color: Colors.white,
        );
      case 5:
        return const Icon(
          Icons.looks_6,
          color: Colors.white,
        );
    }
    return const Icon(
      Icons.list,
      color: Colors.white,
    );
  }
}
