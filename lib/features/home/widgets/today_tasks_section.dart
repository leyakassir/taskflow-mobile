import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/widgets/empty_state.dart';
import 'package:taskflow_mobile/features/home/widgets/home_section_header.dart';
import 'package:taskflow_mobile/features/home/widgets/task_preview_card.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Unfinished tasks whose deadline falls on today's local date. The count
/// matches the "Due today" KPI card, which uses the same list.
class TodayTasksSection extends StatelessWidget {
  const TodayTasksSection({super.key, required this.tasks, this.onViewAll});

  /// Only the first few are previewed; the badge still shows the full count
  /// and the arrow next to it opens the full list.
  static const maxVisible = 3;

  final List<Task> tasks;

  /// Opens the full due-today list; shown as an arrow next to the count.
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: l10n.homeDueTodayTitle,
          trailing: tasks.isEmpty
              ? null
              : Semantics(
                  button: onViewAll != null,
                  child: InkWell(
                    onTap: onViewAll,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.fieldRadius,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.space2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.fieldRadius,
                              ),
                            ),
                            child: Text(
                              '${tasks.length}',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (onViewAll != null)
                            // Mirrors itself in right-to-left layouts.
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: AppDimensions.space3),
        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: EmptyState(
              icon: Icons.event_available_rounded,
              title: l10n.homeDueTodayEmptyTitle,
              message: l10n.homeDueTodayEmptyMessage,
            ),
          )
        else
          for (final task in tasks.take(maxVisible))
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space3),
              child: TaskPreviewCard(task: task),
            ),
      ],
    );
  }
}
