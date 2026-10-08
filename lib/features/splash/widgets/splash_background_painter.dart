import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Soft translucent shapes (rounded squares, circles and check marks) that
/// drift slowly over the splash gradient.
class SplashBackgroundPainter extends CustomPainter {
  SplashBackgroundPainter({
    required this.animation,
    required this.foregroundColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color foregroundColor;

  // (x, y) as fractions of the screen, size in logical pixels, drift phase,
  // and kind: 0 rounded square, 1 ring, 2 check mark.
  static const _shapes = <(double, double, double, double, int)>[
    (0.12, 0.14, 64, 0.0, 0),
    (0.86, 0.10, 34, 0.7, 1),
    (0.80, 0.30, 52, 1.9, 2),
    (0.08, 0.46, 30, 2.6, 1),
    (0.92, 0.58, 72, 3.4, 0),
    (0.18, 0.76, 46, 4.1, 2),
    (0.70, 0.86, 40, 5.0, 1),
    (0.40, 0.06, 26, 5.7, 0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * math.pi * 2;
    for (final (x, y, s, phase, kind) in _shapes) {
      final dx = math.sin(t + phase) * 10;
      final dy = math.cos(t * 0.8 + phase) * 14;
      final center = Offset(x * size.width + dx, y * size.height + dy);
      final rotation = math.sin(t * 0.5 + phase) * 0.35;

      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(rotation);

      switch (kind) {
        case 0:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: s, height: s),
              Radius.circular(s * 0.28),
            ),
            Paint()..color = foregroundColor.withValues(alpha: 0.10),
          );
        case 1:
          canvas.drawCircle(
            Offset.zero,
            s / 2,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = foregroundColor.withValues(alpha: 0.16),
          );
        default:
          final path = Path()
            ..moveTo(-s * 0.32, 0)
            ..lineTo(-s * 0.08, s * 0.24)
            ..lineTo(s * 0.34, -s * 0.22);
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..color = foregroundColor.withValues(alpha: 0.18),
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SplashBackgroundPainter oldDelegate) =>
      oldDelegate.foregroundColor != foregroundColor;
}
