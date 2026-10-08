import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/widgets/skeleton_block.dart';

/// Loading placeholder shaped like a [NotificationCard].
class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(
            height: 40,
            width: 40,
            radius: AppDimensions.fieldRadius,
          ),
          SizedBox(width: AppDimensions.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(height: 14, width: 160),
                SizedBox(height: AppDimensions.space2),
                SkeletonBlock(height: 10),
                SizedBox(height: AppDimensions.space2),
                SkeletonBlock(height: 10, width: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
