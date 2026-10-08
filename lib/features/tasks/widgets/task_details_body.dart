import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/widgets/attachments_section.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_checklist.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_comments_section.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_details_hero.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_info_row.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_section_card.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Scrollable content of the task details screen, with pull-to-refresh.
/// [commentsKey] lets the screen scroll to the comments section.
class TaskDetailsBody extends StatelessWidget {
  const TaskDetailsBody({
    super.key,
    required this.task,
    required this.commentsKey,
    required this.onRefresh,
  });

  final Task task;
  final GlobalKey commentsKey;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final location = task.location?.trim() ?? '';
    final notes = task.completionNotes?.trim() ?? '';

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskDetailsHero(task: task),
            const SizedBox(height: AppDimensions.space5),
            TaskSectionCard(
              title: AppLocalizations.of(context).taskInformation,
              icon: Icons.subject_rounded,
              child: Column(
                children: [
                  TaskInfoRow(
                    icon: Icons.schedule_rounded,
                    label: AppLocalizations.of(context).deadlineLabel,
                    // API dates are UTC; show the deadline in local time.
                    value: task.deadline == null
                        ? AppLocalizations.of(context).noDeadline
                        : DateFormat.yMMMEd(locale)
                              .add_jm()
                              .format(task.deadline!.toLocal()),
                    highlight: task.isPastDeadline,
                  ),
                  if (location.isNotEmpty)
                    TaskInfoRow(
                      icon: Icons.location_on_outlined,
                      label: AppLocalizations.of(context).locationLabel,
                      value: location,
                    ),
                ],
              ),
            ),
            if (task.checklistItems.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.space4),
              TaskSectionCard(
                title: AppLocalizations.of(context).checklistTitle,
                icon: Icons.checklist_rounded,
                child: TaskChecklist(items: task.checklistItems),
              ),
            ],
            const SizedBox(height: AppDimensions.space4),
            TaskSectionCard(
              title: AppLocalizations.of(context).attachmentsTitle,
              icon: Icons.attach_file_rounded,
              child: AttachmentsSection(attachments: task.attachments),
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.space4),
              TaskSectionCard(
                title: AppLocalizations.of(context).completionNotes,
                icon: Icons.notes_rounded,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    notes,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.space4),
            TaskCommentsSection(key: commentsKey, taskId: task.id),
            const SizedBox(height: AppDimensions.space5),
          ],
        ),
      ),
    );
  }
}
