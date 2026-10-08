import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// A slim progress bar showing checklist completion, e.g. "3 / 5".
/// Used on task cards and the details screen for checklist-based tasks.
class TaskProgressIndicator extends StatelessWidget {
  const TaskProgressIndicator({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  double get _fraction => total == 0 ? 0 : (completed / total).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = total > 0 && completed >= total;
    final color = context.readable(isDone ? AppColors.success : AppColors.info);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).checklistTitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '$completed / $total',
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space1),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _fraction,
            minHeight: 6,
            // A theme surface, so the empty track shows in light mode too.
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
