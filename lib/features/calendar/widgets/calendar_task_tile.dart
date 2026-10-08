import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/calendar/domain/entities/calendar_entry.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_priority_color.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// One task in the selected day's list. The leading bar carries the
/// priority color; overdue items switch to a danger tint and label.
class CalendarTaskTile extends StatelessWidget {
  const CalendarTaskTile({super.key, required this.entry, required this.onTap});

  final CalendarEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final overdue = entry.isOverdue;
    final accent = overdue
        ? AppColors.danger
        : calendarPriorityColor(entry.task.priority);
    final danger = context.readable(AppColors.danger);
    final time = DateFormat.jm(locale).format(entry.dateTime);
    final when = entry.kind == CalendarEntryKind.deadline
        ? l10n.calendarDueAt(time)
        : l10n.calendarStartsAt(time);

    return Material(
      color: overdue ? AppColors.dangerBg : colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.space3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: overdue
                  ? AppColors.danger.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppDimensions.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.task.titleFor(
                        Localizations.localeOf(context).languageCode,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space1),
                    Wrap(
                      spacing: AppDimensions.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          when,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          calendarPriorityLabel(l10n, entry.task.priority),
                          style: AppTextStyles.labelMedium.copyWith(
                            color: context.readable(
                              calendarPriorityColor(entry.task.priority),
                            ),
                          ),
                        ),
                        if (overdue)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 14,
                                color: danger,
                              ),
                              const SizedBox(width: AppDimensions.space1),
                              Text(
                                l10n.calendarOverdue,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: danger,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
