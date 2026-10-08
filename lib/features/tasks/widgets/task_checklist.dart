import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Displays a task's checklist items. When [onChanged] is provided, items
/// are tappable checkboxes (used during task completion); otherwise they
/// render as a read-only list (used on the details screen before the
/// worker has started completing the task).
class TaskChecklist extends StatelessWidget {
  const TaskChecklist({super.key, required this.items, this.onChanged});

  final List<TaskChecklistItem> items;
  final void Function(String itemId, bool done)? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).checklistTitle,
          style: AppTextStyles.headingSmall.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.itemSpacing),
        ...items.map(
          (item) => _ChecklistTile(
            item: item,
            interactive: onChanged != null,
            onChanged: onChanged == null
                ? null
                : (done) => onChanged!(item.id, done),
          ),
        ),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.interactive,
    this.onChanged,
  });

  final TaskChecklistItem item;
  final bool interactive;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: AppDimensions.space2),
      decoration: BoxDecoration(
        color: item.done
            ? AppColors.success.withValues(alpha: 0.06)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: interactive && onChanged != null
              ? () => onChanged!(!item.done)
              : null,
          borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppDimensions.space2,
              AppDimensions.space1,
              AppDimensions.space3,
              AppDimensions.space1,
            ),
            child: Row(
              children: [
                if (interactive)
                  Checkbox(
                    value: item.done,
                    onChanged: (done) {
                      if (done != null) onChanged?.call(done);
                    },
                    activeColor: context.readable(AppColors.success),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  )
                else
                  Icon(
                    item.done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 22,
                    color: item.done
                        ? context.readable(AppColors.success)
                        : colorScheme.onSurfaceVariant,
                  ),
                const SizedBox(width: AppDimensions.space2),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: item.done
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      decoration: item.done ? TextDecoration.lineThrough : null,
                    ),
                    child: Text(item.label),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
