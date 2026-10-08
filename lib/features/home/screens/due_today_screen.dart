import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/widgets/empty_state.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/features/home/providers/home_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_card.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_card_skeleton.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Every unfinished task due today (Home previews only the first three).
/// Uses the same list as Home, so no extra request.
class DueTodayScreen extends ConsumerWidget {
  const DueTodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(homeOverviewProvider);
    Future<void> refresh() =>
        ref.read(tasksControllerProvider.notifier).refresh();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeDueTodayTitle)),
      body: overview.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: const [
            TaskCardSkeleton(lines: 2),
            SizedBox(height: AppDimensions.space3),
            TaskCardSkeleton(lines: 2),
          ],
        ),
        error: (_, _) => ErrorView(onRetry: refresh),
        data: (summary) => RefreshIndicator(
          onRefresh: refresh,
          child: summary.dueToday.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    EmptyState(
                      icon: Icons.event_available_rounded,
                      title: l10n.homeDueTodayEmptyTitle,
                      message: l10n.homeDueTodayEmptyMessage,
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.pagePadding),
                  itemCount: summary.dueToday.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppDimensions.space3),
                  itemBuilder: (context, i) {
                    final task = summary.dueToday[i];
                    return TaskCard(
                      task: task,
                      onTap: () =>
                          context.push(RouteNames.taskDetailsPath(task.id)),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
