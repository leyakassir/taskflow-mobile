import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:taskflow_mobile/app/theme/app_colors.dart';

class OnboardingBackgroundPainter extends CustomPainter {
  OnboardingBackgroundPainter({required this.animation, required this.color})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.42;

    // Soft rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.035);

    canvas.drawCircle(center, r, ringPaint);
    canvas.drawCircle(center, r * 0.72, ringPaint);

    // Orbit dot
    final angle = animation.value * math.pi * 2;
    final dot = Offset(
      center.dx + math.cos(angle) * r,
      center.dy + math.sin(angle) * r,
    );

    final dotPaint = Paint()
      ..color = AppColors.onboardingViolet.withValues(alpha: 0.18);
    canvas.drawCircle(dot, 3, dotPaint);

    // Second static subtle dot
    final dot2Paint = Paint()..color = color.withValues(alpha: 0.08);
    canvas.drawCircle(
      Offset(center.dx - r * 0.6, center.dy + r * 0.25),
      2.2,
      dot2Paint,
    );
  }

  @override
  bool shouldRepaint(covariant OnboardingBackgroundPainter oldDelegate) => true;
}
