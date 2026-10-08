import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';

/// One "My progress" tile: label, big value, caption and an optional bar.
class ProgressMetricCard extends StatelessWidget {
  const ProgressMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    this.progress,
  });

  final String label;
  final String value;
  final String caption;

  /// 0..1, drawn as a slim bar under the value. Null hides the bar.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.space1),
            Text(
              value,
              style: AppTextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: AppDimensions.space2),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress!.clamp(0, 1)),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) =>
                      LinearProgressIndicator(value: value, minHeight: 6),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.space2),
            Text(
              caption,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
