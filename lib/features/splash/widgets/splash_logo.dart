import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';

/// White app tile with a check mark, the "TaskFlow" wordmark under it.
/// [glow] (0..1) drives a soft pulsing halo around the tile.
class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    required this.label,
    required this.primaryColor,
    required this.foregroundColor,
    this.glow = 0,
  });

  final String label;
  final Color primaryColor;
  final Color foregroundColor;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: foregroundColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: foregroundColor.withValues(alpha: 0.18 + glow * 0.22),
                blurRadius: 24 + glow * 24,
                spreadRadius: 2 + glow * 6,
              ),
            ],
          ),
          child: Icon(Icons.task_alt_rounded, size: 58, color: primaryColor),
        ),
        const SizedBox(height: AppDimensions.space6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: foregroundColor,
          ),
        ),
      ],
    );
  }
}
