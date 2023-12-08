import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showAlertDialog(BuildContext context, String title, String message) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(title: Text(title), content: Text(message));
      });
}

void showToast(String message, {bool isLong = false}) {
  Fluttertoast.showToast(msg: message, toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT);
}

void handleError(Future future) {
  future.catchError((err) => showToast(err.toString(), isLong: true));
}

extension ListUtils<T> on List<T> {
  num sumBy(num f(T element)) {
    num sum = 0;
    for (var item in this) {
      sum += f(item);
    }
    return sum;
  }
}
