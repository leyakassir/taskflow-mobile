import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/features/home/providers/home_provider.dart';
import 'package:taskflow_mobile/features/home/widgets/my_progress_section.dart';
import 'package:taskflow_mobile/features/home/widgets/today_tasks_section.dart';
import 'package:taskflow_mobile/features/home/widgets/top_kpi_carousel.dart';
import 'package:taskflow_mobile/features/home/widgets/welcome_header.dart';
import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_card_skeleton.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(homeOverviewProvider);

    Future<void> refresh() => Future.wait([
      ref.read(tasksControllerProvider.notifier).refresh(),
      ref.read(notificationsControllerProvider.notifier).refresh(),
    ]);

    final header = WelcomeHeader(
      onNotificationsTap: () => context.push(RouteNames.notifications),
    );

    return Scaffold(
      body: SafeArea(
        child: overview.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(AppDimensions.pagePadding),
            children: [
              header,
              const SizedBox(height: AppDimensions.sectionSpacing),
              const TaskCardSkeleton(lines: 1),
              const SizedBox(height: AppDimensions.space4),
              const TaskCardSkeleton(lines: 2),
            ],
          ),
          error: (error, stack) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.pagePadding),
                child: header,
              ),
              Expanded(child: ErrorView(onRetry: refresh)),
            ],
          ),
          data: (summary) => RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.pagePadding),
              children: [
                header,
                const SizedBox(height: AppDimensions.sectionSpacing),
                TopKpiCarousel(overview: summary),
                const SizedBox(height: AppDimensions.sectionSpacing),
                TodayTasksSection(
                  tasks: summary.dueToday,
                  onViewAll: () => context.push(RouteNames.dueToday),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                MyProgressSection(overview: summary),
                const SizedBox(height: AppDimensions.space5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
