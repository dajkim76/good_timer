import 'package:flutter/material.dart';

class PomodoroCountIcon extends CustomPaint {
  PomodoroCountIcon(int count, {super.key}) : super(size: const Size(27, 20), painter: _PomodoroCountPainter(count));
}

class _PomodoroCountPainter extends CustomPainter {
  final int count;

  final Paint fillPaint = Paint()
    ..color = Colors.orange
    ..style = PaintingStyle.fill;

  final textPainter = TextPainter()
    ..text = const TextSpan(style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold))
    ..textAlign = TextAlign.center
    ..textDirection = TextDirection.ltr;

  _PomodoroCountPainter(this.count);

  @override
  void paint(Canvas canvas, Size size) {
    // fill round rect
    final BorderRadius borderRadius = BorderRadius.circular(2);
    final Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final RRect outer = borderRadius.toRRect(rect);
    canvas.drawRRect(outer, fillPaint);

    // draw count
    textPainter.text = TextSpan(
        text: count.toString(), style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold));
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
