import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart';

class SimpleClockIcon extends StatefulWidget {
  final double size;
  final Color color;
  final Color? backgroundColor;
  final double strokeWidth;

  const SimpleClockIcon({
    Key? key,
    this.size = 50,
    this.color = Colors.orange,
    this.backgroundColor,
    this.strokeWidth = 1.3,
  }) : super(key: key);

  @override
  State<SimpleClockIcon> createState() => _SimpleClockIconState();
}

class _SimpleClockIconState extends State<SimpleClockIcon>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _ClockPainter(
        time: _currentTime,
        color: widget.color,
        backgroundColor: widget.backgroundColor,
        strokeWidth: widget.strokeWidth,
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime time;
  final Color color;
  final Color? backgroundColor;
  final double strokeWidth;

  _ClockPainter({
    required this.time,
    required this.color,
    this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Nền đồng hồ
    final bgPaint = Paint()
      ..color = backgroundColor ?? Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Viền gradient
    final borderPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.8), color.withOpacity(1)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - strokeWidth / 2, borderPaint);

    // Kim giờ
    final hourAngle =
        ((time.hour % 12) * 30 + time.minute * 0.5) * math.pi / 180 -
            math.pi / 2;
    final hourPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 1.7
      ..strokeCap = StrokeCap.round;
    final hourLength = radius * 0.5;
    canvas.drawLine(
      center,
      Offset(center.dx + math.cos(hourAngle) * hourLength,
          center.dy + math.sin(hourAngle) * hourLength),
      hourPaint,
    );

    // Kim phút
    final minuteAngle =
        (time.minute * 6 + time.second * 0.1) * math.pi / 180 - math.pi / 2;
    final minutePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth * 1.2
      ..strokeCap = StrokeCap.round;
    final minuteLength = radius * 0.7;
    canvas.drawLine(
      center,
      Offset(center.dx + math.cos(minuteAngle) * minuteLength,
          center.dy + math.sin(minuteAngle) * minuteLength),
      minutePaint,
    );

    // Kim giây (mỏng + màu nhạt)
    final secondAngle = (time.second * 6) * math.pi / 180 - math.pi / 2;
    final secondPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = strokeWidth * 1
      ..strokeCap = StrokeCap.round;
    final secondLength = radius * 0.8;
    canvas.drawLine(
      center,
      Offset(center.dx + math.cos(secondAngle) * secondLength,
          center.dy + math.sin(secondAngle) * secondLength),
      secondPaint,
    );

    // Trung tâm nổi bật
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawCircle(center, strokeWidth * 2, centerPaint);
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
