import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/widgets/skeleton_block.dart';

class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key, this.lines = 2});

  final int lines;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: SkeletonBlock(height: 16)),
              SizedBox(width: AppDimensions.space4),
              SkeletonBlock(height: 22, width: 60, radius: 999),
            ],
          ),
          for (var i = 0; i < lines; i++) ...[
            const SizedBox(height: AppDimensions.space3),
            SkeletonBlock(
              height: 10,
              width: i == lines - 1 ? 150 : double.infinity,
            ),
          ],
          const SizedBox(height: AppDimensions.space4),
          const Row(
            children: [
              SkeletonBlock(height: 22, width: 82, radius: 999),
              Spacer(),
              SkeletonBlock(height: 10, width: 76),
            ],
          ),
        ],
      ),
    );
  }
}
