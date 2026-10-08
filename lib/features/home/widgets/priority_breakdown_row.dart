import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/features/home/widgets/priority_pill.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// HIGH / MEDIUM / LOW pills, each with a count badge.
class PriorityBreakdownRow extends StatelessWidget {
  const PriorityBreakdownRow({
    super.key,
    required this.high,
    required this.medium,
    required this.low,
  });

  final int high;
  final int medium;
  final int low;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppDimensions.space2,
      runSpacing: AppDimensions.space2,
      children: [
        PriorityPill(
          label: l10n.priorityHigh,
          count: high,
          color: AppColors.danger,
        ),
        PriorityPill(
          label: l10n.priorityMedium,
          count: medium,
          color: AppColors.warning,
        ),
        PriorityPill(
          label: l10n.priorityLow,
          count: low,
          color: AppColors.info,
        ),
      ],
    );
  }
}
