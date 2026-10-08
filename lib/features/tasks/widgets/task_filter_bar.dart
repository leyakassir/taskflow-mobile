import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// A `null` filter value means "All".
class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TaskStatus? selected;
  final ValueChanged<TaskStatus?> onSelected;

  static const _filters = <TaskStatus?>[
    null,
    TaskStatus.inProgress,
    TaskStatus.completed,
    TaskStatus.overdue,
  ];

  String _labelFor(BuildContext context, TaskStatus? status) =>
      switch (status) {
        null => AppLocalizations.of(context).filterAll,
        TaskStatus.inProgress => AppLocalizations.of(context).statusInProgress,
        TaskStatus.completed => AppLocalizations.of(context).statusCompleted,
        TaskStatus.overdue => AppLocalizations.of(context).statusOverdue,
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 48dp tall so each chip has a full-size touch target.
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppDimensions.space2),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == selected;

          return ChoiceChip(
            label: Text(_labelFor(context, filter)),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
            labelStyle: AppTextStyles.labelMedium.copyWith(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            backgroundColor: colorScheme.surfaceContainerHigh,
            selectedColor: colorScheme.primary,
            showCheckmark: false,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.heroRadius),
            ),
          );
        },
      ),
    );
  }
}
