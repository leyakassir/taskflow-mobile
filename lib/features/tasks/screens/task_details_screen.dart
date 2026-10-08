import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_comments_provider.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_details_provider.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_action_bar.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_card_skeleton.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_details_body.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  const TaskDetailsScreen({
    super.key,
    required this.taskId,
    this.focusComments = false,
  });

  final String taskId;

  /// Scrolls to the comments once the task loads (comment notifications).
  final bool focusComments;

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  final _commentsKey = GlobalKey();
  bool _scrolledToComments = false;

  String get taskId => widget.taskId;

  void _scrollToCommentsOnce() {
    if (!widget.focusComments || _scrolledToComments) return;
    _scrolledToComments = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _commentsKey.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _refresh() => Future.wait([
    ref.read(taskDetailsControllerProvider(taskId).notifier).reload(),
    ref.read(taskCommentsControllerProvider(taskId).notifier).refresh(),
  ]);

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailsControllerProvider(taskId));
    if (taskAsync.hasValue) _scrollToCommentsOnce();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).taskDetailsTitle),
      ),
      body: taskAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: const [
            TaskCardSkeleton(lines: 3),
            SizedBox(height: AppDimensions.space3),
            TaskCardSkeleton(lines: 2),
            SizedBox(height: AppDimensions.space3),
            TaskCardSkeleton(lines: 2),
          ],
        ),
        error: (error, _) => ErrorView(
          onRetry: () => ref
              .read(taskDetailsControllerProvider(taskId).notifier)
              .refresh(),
        ),
        data: (task) => TaskDetailsBody(
          task: task,
          commentsKey: _commentsKey,
          onRefresh: _refresh,
        ),
      ),
      bottomNavigationBar: taskAsync.maybeWhen(
        data: (task) => TaskActionBar(task: task),
        orElse: () => null,
      ),
    );
  }
}
