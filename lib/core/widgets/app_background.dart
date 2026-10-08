import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:taskflow_mobile/app/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.showOrbits = true});

  final Widget child;
  final bool showOrbits;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnight : AppColors.canvasLight,
              gradient: isDark
                  ? const RadialGradient(
                      center: Alignment(-0.2, -0.6),
                      radius: 1.2,
                      colors: [Color(0xFF0F2A52), AppColors.midnight],
                    )
                  : null,
            ),
          ),
        ),
        if (showOrbits)
          Positioned.fill(
            child: CustomPaint(painter: _OrbitPainter(isDark: isDark)),
          ),
        child,
      ],
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.42;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = (isDark ? Colors.white : AppColors.brandNavy).withValues(
        alpha: isDark ? 0.03 : 0.035,
      );

    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.72, ringPaint);

    final dotPaint = Paint()
      ..color = AppColors.brandBlue.withValues(alpha: isDark ? 0.12 : 0.08);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.85, center.dy - radius * 0.15),
      3,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(center.dx - radius * 0.55, center.dy + radius * 0.35),
      2.2,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
