import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/utils/date_utils.dart';
import 'package:taskflow_mobile/features/calendar/domain/entities/calendar_entry.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_day_markers.dart';

/// Month view with task markers. Follows the app locale (month and weekday
/// names, first day of the week) and mirrors correctly in RTL.
class TaskMonthCalendar extends StatelessWidget {
  const TaskMonthCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.entriesByDay,
    required this.onDaySelected,
    required this.onMonthChanged,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final Map<DateTime, List<CalendarEntry>> entriesByDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onMonthChanged;

  static const _startingDays = [
    StartingDayOfWeek.sunday,
    StartingDayOfWeek.monday,
    StartingDayOfWeek.tuesday,
    StartingDayOfWeek.wednesday,
    StartingDayOfWeek.thursday,
    StartingDayOfWeek.friday,
    StartingDayOfWeek.saturday,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final firstDayIndex = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final now = DateTime.now();
    final dayTextStyle = AppTextStyles.bodyMedium.copyWith(
      color: colorScheme.onSurface,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space2,
        vertical: AppDimensions.space3,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: TableCalendar<CalendarEntry>(
        locale: locale,
        firstDay: DateTime(now.year - 2),
        lastDay: DateTime(now.year + 3, 12, 31),
        focusedDay: _focusedDay,
        currentDay: now,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: ''},
        startingDayOfWeek: _startingDays[firstDayIndex],
        availableGestures: AvailableGestures.horizontalSwipe,
        selectedDayPredicate: (day) => isSameDate(day, selectedDay),
        eventLoader: (day) => entriesByDay[dateOnly(day)] ?? const [],
        onDaySelected: (selected, focused) => onDaySelected(dateOnly(selected)),
        onPageChanged: (focused) =>
            onMonthChanged(DateTime(focused.year, focused.month)),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: AppTextStyles.headingSmall.copyWith(
            color: colorScheme.onSurface,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: colorScheme.onSurface,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurface,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          weekendStyle: AppTextStyles.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: dayTextStyle,
          weekendTextStyle: dayTextStyle,
          todayDecoration: BoxDecoration(
            color: AppColors.brandBlue.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          todayTextStyle: dayTextStyle.copyWith(
            color: AppColors.brandBlue,
            fontWeight: FontWeight.w700,
          ),
          selectedDecoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: dayTextStyle.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        calendarBuilders: CalendarBuilders<CalendarEntry>(
          markerBuilder: (context, day, entries) => entries.isEmpty
              ? null
              : PositionedDirectional(
                  bottom: AppDimensions.space1,
                  start: 0,
                  end: 0,
                  child: Center(child: CalendarDayMarkers(entries: entries)),
                ),
        ),
      ),
    );
  }

  // Keep the selected day in view when it belongs to the focused month.
  DateTime get _focusedDay =>
      selectedDay.year == focusedMonth.year &&
          selectedDay.month == focusedMonth.month
      ? selectedDay
      : focusedMonth;
}
