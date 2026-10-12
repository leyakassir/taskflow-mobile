import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taskflow_mobile/app/theme/app_theme.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/features/calendar/providers/calendar_provider.dart';
import 'package:taskflow_mobile/features/calendar/screens/calendar_screen.dart';
import 'package:taskflow_mobile/features/calendar/widgets/task_month_calendar.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

Task _task(String id, DateTime deadline, {TaskPriority p = TaskPriority.high}) {
  final now = DateTime.now();
  return Task(
    id: id,
    title: 'Task $id with a fairly long title to test wrapping',
    priority: p,
    status: TaskStatus.assigned,
    deadline: deadline.toUtc(),
    startDate: deadline.subtract(const Duration(days: 1)).toUtc(),
    minPhotosRequired: 0,
    minFilesRequired: 0,
    requiresChecklist: false,
    assigneeId: 'w',
    createdById: 'a',
    createdAt: now,
    updatedAt: now,
  );
}

Widget _host(Locale locale, Override tasks) => ProviderScope(
  overrides: [tasks],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: const CalendarScreen(),
  ),
);

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 15);

  final cases = <String, Override>{
    'tasks': calendarMonthTasksProvider.overrideWith(
      (ref, month) async => [
        _task('a', today),
        _task('b', today, p: TaskPriority.low),
        _task('c', today.add(const Duration(days: 2))),
        for (var i = 0; i < 6; i++) _task('d$i', today, p: TaskPriority.medium),
      ],
    ),
    'empty': calendarMonthTasksProvider.overrideWith((ref, month) async => []),
    'error': calendarMonthTasksProvider.overrideWith(
      (ref, month) async => throw const ApiException.generic(),
    ),
  };

  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final entry in cases.entries) {
      testWidgets('Calendar (${entry.key}, ${locale.languageCode})', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_host(locale, entry.value));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        // A failed load used to throw while building (AsyncValue.value
        // rethrows) and replace the screen with Flutter's red error box.
        // Now the month grid stays and the error view shows below it.
        expect(find.byType(TaskMonthCalendar), findsOneWidget);
        if (entry.key == 'error') {
          final l10n = await AppLocalizations.delegate.load(locale);
          expect(find.text(l10n.calendarLoadError), findsOneWidget);
        }

        // Change month both ways and pick a day.
        await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.chevron_left_rounded).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('${today.day}').first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
