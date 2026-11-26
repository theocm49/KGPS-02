import 'dart:math' as math;
import 'package:flutter/material.dart';

class Compass extends StatelessWidget {
  final double heading;

  const Compass({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: CompassPainter(heading: heading),
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  final double heading;

  CompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blueAccent
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, circlePaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);

    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;

    for (int degree = 0; degree < 360; degree += 5) {
      final angle = degree * math.pi / 180;
      final major = degree % 30 == 0;
      final innerRadius = radius - (major ? 25 : 15);
      final outerRadius = radius - 5;

      final start = Offset(
        math.cos(angle) * innerRadius,
        math.sin(angle) * innerRadius,
      );
      final end = Offset(
        math.cos(angle) * outerRadius,
        math.sin(angle) * outerRadius,
      );
      canvas.drawLine(start, end, tickPaint);
    }

    const directions = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    for (final entry in directions.entries) {
      final angle = entry.key * math.pi / 180;
      final textPainter = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textRadius = radius - 45;
      final position = Offset(
        math.cos(angle) * textRadius - textPainter.width / 2,
        math.sin(angle) * textRadius - textPainter.height / 2,
      );
      textPainter.paint(canvas, position);
    }

    canvas.restore();

    canvas.drawCircle(
      center,
      4,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}
