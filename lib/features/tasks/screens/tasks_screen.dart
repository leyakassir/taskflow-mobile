import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/widgets/empty_state.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/providers/tasks_provider.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_card.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_card_skeleton.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_filter_bar.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_search_bar.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  TaskStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadWhenNearBottom);
  }

  void _loadWhenNearBottom() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 300) {
      ref.read(tasksControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_loadWhenNearBottom)
      ..dispose();
    super.dispose();
  }

  List<Task> _applyFilters(List<Task> tasks) {
    return tasks.where((task) {
      final matchesQuery =
          _query.isEmpty ||
          (task.title + (task.titleAr ?? '')).toLowerCase().contains(
            _query.toLowerCase(),
          );
      // "Overdue" also includes unfinished tasks whose deadline has passed,
      // matching how the cards show them, even before the backend job has
      // changed their status.
      final matchesStatus =
          _statusFilter == null ||
          task.status == _statusFilter ||
          (_statusFilter == TaskStatus.overdue && task.isPastDeadline);
      return matchesQuery && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.space5),
              Text(
                AppLocalizations.of(context).tasksTitle,
                style: AppTextStyles.displaySmall.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.space1),
              Text(
                AppLocalizations.of(context).tasksSubhead,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.space5),
              TaskSearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppDimensions.space3),
              TaskFilterBar(
                selected: _statusFilter,
                onSelected: (status) => setState(() => _statusFilter = status),
              ),
              const SizedBox(height: AppDimensions.space5),
              Expanded(
                child: tasksAsync.when(
                  loading: () => ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: 4,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppDimensions.space3),
                    itemBuilder: (context, index) => const TaskCardSkeleton(),
                  ),
                  error: (error, _) => ErrorView(
                    onRetry: () =>
                        ref.read(tasksControllerProvider.notifier).refresh(),
                  ),
                  data: (tasks) {
                    final filtered = _applyFilters(tasks);
                    final loadingMore = ref.watch(tasksLoadingMoreProvider);
                    final loadMoreFailed = ref.watch(
                      tasksLoadMoreFailedProvider,
                    );
                    final hasMore = ref
                        .read(tasksControllerProvider.notifier)
                        .hasMore;

                    if (tasks.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => ref
                            .read(tasksControllerProvider.notifier)
                            .refresh(),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: EmptyState(
                            icon: Icons.task_alt_rounded,
                            title: AppLocalizations.of(context).tasksEmptyTitle,
                            message: AppLocalizations.of(context)
                                .tasksEmptyMessage,
                          ),
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return Column(
                        children: [
                          Expanded(
                            child: EmptyState(
                              icon: Icons.search_off_rounded,
                              title: AppLocalizations.of(context)
                                  .tasksNoMatchTitle,
                              message: AppLocalizations.of(context)
                                  .tasksNoMatchMessage,
                            ),
                          ),
                          if (hasMore)
                            TextButton(
                              onPressed: loadingMore
                                  ? null
                                  : () => ref
                                        .read(tasksControllerProvider.notifier)
                                        .loadNextPage(),
                              child: Text(
                                loadingMore
                                    ? 'Loading…'
                                    : loadMoreFailed
                                    ? AppLocalizations.of(context)
                                          .tasksRetryLoading
                                    : AppLocalizations.of(context)
                                          .tasksLoadMore,
                              ),
                            ),
                        ],
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(tasksControllerProvider.notifier).refresh(),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filtered.length + (hasMore ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppDimensions.space3),
                        itemBuilder: (context, index) {
                          if (index == filtered.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.space3,
                              ),
                              child: Center(
                                child: loadingMore
                                    ? const CircularProgressIndicator()
                                    : TextButton(
                                        onPressed: () => ref
                                            .read(
                                              tasksControllerProvider.notifier,
                                            )
                                            .loadNextPage(),
                                        child: Text(
                                          loadMoreFailed
                                              ? AppLocalizations.of(context)
                                                    .tasksRetryLoading
                                              : AppLocalizations.of(context)
                                                    .tasksLoadMore,
                                        ),
                                      ),
                              ),
                            );
                          }
                          final task = filtered[index];
                          return TaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            onTap: () => context.push(
                              RouteNames.taskDetailsPath(task.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
