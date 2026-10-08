import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_details_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';
import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';

/// Bottom action on the task details screen: start (assigned/overdue) or
/// complete (in progress). Hidden for finished tasks.
class TaskActionBar extends ConsumerWidget {
  const TaskActionBar({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> start() async {
      try {
        await ref
            .read(taskDetailsControllerProvider(task.id).notifier)
            .updateStatus(TaskStatus.inProgress);
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is ApiException
                  ? error.localized(AppLocalizations.of(context))
                  : AppLocalizations.of(context).genericError,
            ),
          ),
        );
      }
    }

    final Widget? action = switch (task.status) {
      TaskStatus.assigned || TaskStatus.overdue => AppButton(
        label: AppLocalizations.of(context).startTask,
        icon: Icons.play_arrow_rounded,
        onPressed: start,
      ),
      TaskStatus.inProgress => AppButton(
        label: AppLocalizations.of(context).completeTaskTitle,
        icon: Icons.check_circle_outline_rounded,
        onPressed: () => context.push(RouteNames.taskCompletePath(task.id)),
      ),
      TaskStatus.completed || TaskStatus.cancelled => null,
    };

    if (action == null) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: SizedBox(width: double.infinity, child: action),
      ),
    );
  }
}
