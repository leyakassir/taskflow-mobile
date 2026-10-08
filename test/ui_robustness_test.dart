// Renders key widgets at a 360dp-wide screen with 1.3x text, in LTR and
// RTL (Arabic) and in light and dark themes. Any RenderFlex overflow is
// reported by Flutter as an error and fails the test.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_theme.dart';
import 'package:taskflow_mobile/core/widgets/empty_state.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/features/calendar/domain/entities/calendar_entry.dart';
import 'package:taskflow_mobile/features/calendar/widgets/calendar_task_tile.dart';
import 'package:taskflow_mobile/features/auth/screens/login_screen.dart';
import 'package:taskflow_mobile/features/home/providers/home_provider.dart';
import 'package:taskflow_mobile/features/home/widgets/my_progress_section.dart';
import 'package:taskflow_mobile/features/home/widgets/stats_card.dart';
import 'package:taskflow_mobile/features/home/widgets/top_kpi_carousel.dart';
import 'package:taskflow_mobile/features/home/widgets/task_preview_card.dart';
import 'package:taskflow_mobile/features/home/widgets/today_tasks_section.dart';
import 'package:taskflow_mobile/features/home/widgets/welcome_header.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';
import 'package:taskflow_mobile/features/notifications/widgets/notification_card.dart';
import 'package:taskflow_mobile/features/profile/domain/entities/profile.dart';
import 'package:taskflow_mobile/features/profile/widgets/profile_header.dart';
import 'package:taskflow_mobile/features/profile/widgets/profile_stat_card.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_card.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_comment_tile.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_details_hero.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_info_row.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

Task _task({
  String title = 'Replace the damaged ceiling tiles in the north warehouse',
  TaskPriority priority = TaskPriority.urgent,
  TaskStatus status = TaskStatus.inProgress,
  Duration due = const Duration(days: -3),
}) {
  final now = DateTime.now();
  return Task(
    id: 't1',
    title: title,
    description: 'Bring the ladder from storage and coordinate with the night shift supervisor.',
    priority: priority,
    status: status,
    deadline: now.add(due).toUtc(),
    minPhotosRequired: 0,
    minFilesRequired: 0,
    requiresChecklist: false,
    assigneeId: 'w',
    createdById: 'a',
    createdAt: now,
    updatedAt: now,
  );
}

Widget _host(Widget child, {required Locale locale, required bool dark}) {
  return ProviderScope(
    overrides: [unreadNotificationCountProvider.overrideWithValue(128)],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.3)),
        child: app!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  // No network in tests: render with the test font instead of fetching Inter.
  GoogleFonts.config.allowRuntimeFetching = false;

  final now = DateTime.now();
  final widgets = <String, Widget>{
    'TaskCard': TaskCard(task: _task(), onTap: () {}),
    'TaskCard due today': TaskCard(
      task: _task(due: const Duration(hours: 1), status: TaskStatus.assigned),
      onTap: () {},
    ),
    'TaskPreviewCard': TaskPreviewCard(task: _task()),
    'TaskDetailsHero': TaskDetailsHero(task: _task()),
    'TaskInfoRow': const TaskInfoRow(
      icon: Icons.schedule_rounded,
      label: 'Deadline',
      value: 'Wednesday, October 8, 2026 at 10:45 PM',
      highlight: true,
    ),
    'TodayTasksSection': TodayTasksSection(
      tasks: [_task(due: const Duration(hours: 2))],
    ),
    'WelcomeHeader + bell (128 unread)': WelcomeHeader(
      onNotificationsTap: () {},
    ),
    'StatsCard': const SizedBox(
      height: 148,
      width: 300,
      child: StatsCard(
        label: 'Completed this week',
        value: 128,
        icon: Icons.task_alt_rounded,
        color: AppColors.success,
      ),
    ),
    'NotificationCard': NotificationCard(
      notification: AppNotification(
        id: 'n',
        kind: NotificationKind.taskDueSoon,
        title: 'Due in 1 hour 50 minutes: Replace the damaged ceiling tiles',
        body: 'Your task "Replace the damaged ceiling tiles" is due in 1 hour 50 minutes.',
        createdAt: now.subtract(const Duration(minutes: 5)).toUtc(),
      ),
      onTap: () {},
    ),
    'CalendarTaskTile': CalendarTaskTile(
      entry: CalendarEntry(task: _task(), kind: CalendarEntryKind.deadline),
      onTap: () {},
    ),
    'TaskCommentTile (staff)': TaskCommentTile(
      comment: TaskComment(
        id: 'c',
        taskId: 't1',
        body: 'Please check the burn gel stock too and report back before the end of the shift.',
        createdAt: now.subtract(const Duration(hours: 3)).toUtc(),
        author: const TaskCommentAuthor(
          id: 'a',
          fullName: 'Alexandria Montgomery-Smith',
          role: 'MANAGER',
        ),
      ),
      isOwn: false,
    ),
    'ProfileHeader': ProfileHeader(
      profile: const Profile(
        id: 'w',
        email: 'very.long.worker.email.address@taskflow.local',
        fullName: 'Demo Worker With A Long Name',
        role: 'WORKER',
        isActive: true,
      ),
      onEditTap: () {},
      onPhotoTap: () {},
    ),
    'ProfileStatCards': const Row(
      children: [
        Expanded(
          child: ProfileStatCard(
            label: 'Active tasks',
            value: 12,
            icon: Icons.pending_actions_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ProfileStatCard(
            label: 'Completed',
            value: 340,
            icon: Icons.task_alt_rounded,
          ),
        ),
      ],
    ),
    'ErrorView': const SizedBox(height: 600, child: ErrorView(onRetry: _noop)),
    'TopKpiCarousel': TopKpiCarousel(
      overview: HomeOverview.fromTasks([
        _task(),
        _task(priority: TaskPriority.low),
      ]),
    ),
    'MyProgressSection': MyProgressSection(
      overview: HomeOverview.fromTasks([
        _task(),
        _task(priority: TaskPriority.medium, status: TaskStatus.completed),
      ]),
    ),
    'EmptyState': const EmptyState(
      icon: Icons.inbox_outlined,
      title: 'No tasks yet',
      message: 'Tasks assigned to you will show up here.',
    ),
  };

  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final dark in const [false, true]) {
      final variant = '${locale.languageCode}/${dark ? 'dark' : 'light'}';
      for (final entry in widgets.entries) {
        testWidgets('${entry.key} fits 360dp @1.3x ($variant)', (tester) async {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            _host(entry.value, locale: locale, dark: dark),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('LoginScreen fits 360dp @1.3x ($variant)', (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: dark ? ThemeMode.dark : ThemeMode.light,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              builder: (context, app) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.3)),
                child: app!,
              ),
              home: const LoginScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Bottom navigation fits 360dp @1.3x ($variant)', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _host(
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return NavigationBar(
                  selectedIndex: 0,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      label: l10n.homeTab,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.checklist_outlined),
                      label: l10n.tasksTab,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: l10n.calendarTitle,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline),
                      label: l10n.profileTab,
                    ),
                  ],
                );
              },
            ),
            locale: locale,
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  test('AppBar title colors come from colorScheme.onSurface', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final title = theme.appBarTheme.titleTextStyle!.color;
      expect(title, theme.colorScheme.onSurface);
      expect(theme.appBarTheme.foregroundColor, theme.colorScheme.onSurface);
      // ignore: avoid_print
      print(
        '${theme.brightness.name}: AppBar title '
        '#${title!.toARGB32().toRadixString(16)} on '
        '#${theme.appBarTheme.backgroundColor!.toARGB32().toRadixString(16)}',
      );
    }
  });
}

void _noop() {}
