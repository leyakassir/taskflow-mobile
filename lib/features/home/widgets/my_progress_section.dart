import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/home/providers/home_provider.dart';
import 'package:taskflow_mobile/features/home/widgets/home_section_header.dart';
import 'package:taskflow_mobile/features/home/widgets/priority_breakdown_row.dart';
import 'package:taskflow_mobile/features/home/widgets/progress_metric_card.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// "My progress": this week's completion, on-time rate and priority counts,
/// all computed from the tasks already loaded for Home.
class MyProgressSection extends StatelessWidget {
  const MyProgressSection({super.key, required this.overview});

  final HomeOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final o = overview;
    final rate = o.onTimeRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: l10n.homeMyProgress),
        const SizedBox(height: AppDimensions.space3),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ProgressMetricCard(
                  label: l10n.homeThisWeek,
                  value: l10n.homeThisWeekValue(o.weekCompleted, o.weekTotal),
                  caption: l10n.homeThisWeekCaption,
                  progress: o.weekTotal == 0
                      ? 0
                      : o.weekCompleted / o.weekTotal,
                ),
              ),
              const SizedBox(width: AppDimensions.space3),
              Expanded(
                child: ProgressMetricCard(
                  label: l10n.homeOnTimeRate,
                  value: rate == null ? '—' : '${(rate * 100).round()}%',
                  caption: l10n.homeOnTimeCaption,
                  progress: rate ?? 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space4),
        Text(
          l10n.homePriorityBreakdown,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.space2),
        PriorityBreakdownRow(
          high: o.highPriorityCount,
          medium: o.mediumPriorityCount,
          low: o.lowPriorityCount,
        ),
      ],
    );
  }
}
