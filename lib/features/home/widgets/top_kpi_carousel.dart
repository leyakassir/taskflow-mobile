import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/widgets/dot_indicator.dart';
import 'package:taskflow_mobile/features/home/providers/home_provider.dart';
import 'package:taskflow_mobile/features/home/widgets/stats_card.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Swipeable summary cards at the top of Home, with page dots.
class TopKpiCarousel extends StatefulWidget {
  const TopKpiCarousel({super.key, required this.overview});
  final HomeOverview overview;

  @override
  State<TopKpiCarousel> createState() => _TopKpiCarouselState();
}

class _TopKpiCarouselState extends State<TopKpiCarousel> {
  late final PageController _controller = PageController(viewportFraction: .86);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = widget.overview;
    final cards = <StatsCard>[
      StatsCard(
        label: l10n.kpiAssigned,
        value: o.assignedCount,
        icon: Icons.inbox_outlined,
        color: AppColors.info,
      ),
      StatsCard(
        label: l10n.kpiInProgress,
        value: o.inProgressCount,
        icon: Icons.timelapse_outlined,
        color: AppColors.warning,
      ),
      StatsCard(
        label: l10n.kpiDueToday,
        value: o.dueToday.length,
        icon: Icons.today_outlined,
        color: AppColors.brandBlueDark,
      ),
      StatsCard(
        label: l10n.kpiOverdue,
        value: o.overdueCount,
        icon: Icons.error_outline,
        color: AppColors.danger,
      ),
      StatsCard(
        label: l10n.kpiCompletedWeek,
        value: o.completedThisWeek,
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
    ];
    return Column(
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _controller,
            itemCount: cards.length,
            padEnds: false,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsetsDirectional.only(
                end: AppDimensions.space3,
              ),
              child: cards[i],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.space3),
        DotIndicator(count: cards.length, index: _index),
      ],
    );
  }
}
