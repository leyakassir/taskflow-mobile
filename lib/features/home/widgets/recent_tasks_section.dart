import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/features/home/widgets/home_section_header.dart';
import 'package:taskflow_mobile/features/home/widgets/task_preview_card.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class RecentTasksSection extends StatelessWidget {
  const RecentTasksSection({
    super.key,
    required this.tasks,
    required this.onViewAll,
  });

  final List<Task> tasks;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: l10n.homeRecentTasksTitle,
          trailing: TextButton(
            onPressed: onViewAll,
            child: Text(l10n.homeViewAll),
          ),
        ),
        const SizedBox(height: AppDimensions.space2),
        for (final task in tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.itemSpacing),
            child: TaskPreviewCard(task: task),
          ),
      ],
    );
  }
}
