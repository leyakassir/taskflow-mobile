import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';

/// Priority label pill with a filled count badge.
class PriorityPill extends StatelessWidget {
  const PriorityPill({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final readable = context.readable(color);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppDimensions.space3,
        AppDimensions.space1,
        AppDimensions.space1,
        AppDimensions.space1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: readable,
            ),
          ),
          const SizedBox(width: AppDimensions.space2),
          Container(
            constraints: const BoxConstraints(minWidth: 24),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space2,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
