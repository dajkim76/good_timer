import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

class ClockDialPainter extends CustomPainter {
  final clockText;

  final PI = 3.141592653589793238;
  final hourTickMarkLength = 10.0;
  final minuteTickMarkLength = 5.0;

  final hourTickMarkWidth = 3.0;
  final minuteTickMarkWidth = 1.5;

  final Paint tickPaint;
  final TextPainter textPainter;
  final TextStyle textStyle;
  final TextStyle timeTextStyle;

  final romanNumeralList = ['XII', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI'];
  ValueNotifier<int> notifier;

  ClockDialPainter(this.notifier, {this.clockText = ClockText.arabic})
      : tickPaint = new Paint()..color = Colors.white,
        textPainter = new TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        textStyle = const TextStyle(
          color: Colors.white,
          fontFamily: 'Times New Roman',
          fontSize: 15.0,
        ),
        timeTextStyle = const TextStyle(
          color: Colors.white,
          fontFamily: 'Times New Roman',
          fontSize: 25.0,
        ),
        super(repaint: notifier);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    //drawBackground(canvas, size);
    drawArc(canvas, size);
    drawClock(canvas, size);
    canvas.restore();
  }

  void drawClock(Canvas canvas, Size size) {
    var tickMarkLength;
    final angle = 2 * PI / 60;
    final radius = size.width / 2;

    // drawing
    canvas.translate(radius, radius);

    for (var i = 0; i < 60; i++) {
      //make the length and stroke of the tick marker longer and thicker depending
      tickMarkLength = i % 5 == 0 ? hourTickMarkLength : minuteTickMarkLength;
      tickPaint.strokeWidth = i % 5 == 0 ? hourTickMarkWidth : minuteTickMarkWidth;
      canvas.drawLine(new Offset(0.0, -radius), new Offset(0.0, -radius + tickMarkLength), tickPaint);

      //draw the text
      if (i % 5 == 0) {
        canvas.save();
        canvas.translate(0.0, -radius + 20.0);

        textPainter.text = new TextSpan(
          text: this.clockText == ClockText.roman ? '${romanNumeralList[i ~/ 5]}' : '${i == 0 ? 12 * 5 : (i ~/ 5) * 5}',
          style: textStyle,
        );

        //helps make the text painted vertically
        canvas.rotate(-angle * i);

        textPainter.layout();

        textPainter.paint(canvas, new Offset(-(textPainter.width / 2), -(textPainter.height / 2)));

        canvas.restore();
      }

      canvas.rotate(angle);
    }

    // draw time text "25:00"
    int remainSeconds = notifier.value;
    String timeText = sprintf("%02d:%02d", [remainSeconds ~/ 60, remainSeconds % 60]);
    textPainter.text = TextSpan(text: timeText, style: timeTextStyle);
    textPainter.layout();
    textPainter.paint(canvas, new Offset(-(textPainter.width / 2), -(textPainter.height / 2)));
  }

  void drawBackground(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;

    final BorderRadius borderRadius = BorderRadius.circular(5);
    final Rect rect = Rect.fromLTRB(0, 0, width, height);
    final RRect outer = borderRadius.toRRect(rect);
    canvas.drawRRect(outer, paint);
  }

  void drawArc(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    // 원의 반지름을 구한다. 선의 굵이에 영향을 받지 않게 보정
    double radius = min(size.width / 2 - paint.strokeWidth / 2, size.height / 2 - paint.strokeWidth / 2);

    // 그래프가 가운데로 그려지도록 좌표를 정한다.
    Offset center = Offset(size.width / 2, size.height / 2);

    // 원 그래프를 그린다.
    //canvas.drawCircle(center, radius, paint);

    // 호(arc)의 각도를 정한다. 정해진 각도만큼만 그린다.
    int remainSeconds = notifier.value;
    double arcAngle = 2 * pi * (remainSeconds / 3600);

    // 호를 그릴때 색 변경
    paint..color = Colors.red;

    // 호(arc)를 그린다.
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, arcAngle, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

enum ClockText { roman, arabic }
