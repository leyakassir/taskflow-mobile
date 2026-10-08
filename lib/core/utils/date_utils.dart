import 'package:intl/intl.dart';

import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Strips the time component, keeping the calendar date's year/month/day
/// fields as-is (no time zone conversion).
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// The calendar date of [value] in the device's local time zone. Use this
/// for API timestamps, which are parsed as UTC.
DateTime localDateOf(DateTime value) => dateOnly(value.toLocal());

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Short localized "time ago" label, e.g. "5m ago" / "منذ 5 دقائق".
/// Falls back to a date once [time] is more than a week old.
String relativeTimeLabel(
  DateTime time,
  AppLocalizations l10n, {
  DateTime? now,
}) {
  final elapsed = (now ?? DateTime.now()).difference(time.toLocal());
  if (elapsed.inMinutes < 1) return l10n.timeJustNow;
  if (elapsed.inHours < 1) return l10n.timeMinutesAgo(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.timeHoursAgo(elapsed.inHours);
  if (elapsed.inDays < 7) return l10n.timeDaysAgo(elapsed.inDays);
  return DateFormat.yMMMd(l10n.localeName).format(time.toLocal());
}

/// Whole calendar days from today to [value]'s local date: 0 = today,
/// 1 = tomorrow, -1 = yesterday. Counted on dates, not hours, so DST
/// changes cannot shift the result.
int calendarDaysFromToday(DateTime value, {DateTime? now}) {
  final target = localDateOf(value);
  final today = dateOnly(now ?? DateTime.now());
  return DateTime.utc(
    target.year,
    target.month,
    target.day,
  ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
}
