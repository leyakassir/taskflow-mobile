import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    required this.count,
    required this.index,
    this.activeColor,
  });

  final int count;
  final int index;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Page ${index + 1} of $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (dotIndex) {
          final active = dotIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsetsDirectional.only(end: AppDimensions.space2),
            height: 8,
            width: active ? 22 : 8,
            decoration: BoxDecoration(
              color: active
                  ? (activeColor ?? colors.primary)
                  : colors.onSurface.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }
}
