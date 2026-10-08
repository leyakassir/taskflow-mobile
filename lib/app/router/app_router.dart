import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/features/auth/screens/login_screen.dart';
import 'package:taskflow_mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:taskflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:taskflow_mobile/features/calendar/screens/calendar_screen.dart';
import 'package:taskflow_mobile/features/home/screens/home_screen.dart';
import 'package:taskflow_mobile/features/main_navigation/screens/main_navigation_screen.dart';
import 'package:taskflow_mobile/features/home/screens/due_today_screen.dart';
import 'package:taskflow_mobile/features/notifications/screens/notifications_screen.dart';
import 'package:taskflow_mobile/features/onboarding/screens/onboarding_screen.dart';
import 'package:taskflow_mobile/features/profile/screens/profile_screen.dart';
import 'package:taskflow_mobile/features/profile/screens/edit_profile_screen.dart';
import 'package:taskflow_mobile/features/about/widgets/legal_webview_screen.dart';
import 'package:taskflow_mobile/features/settings/screens/settings_screen.dart';
import 'package:taskflow_mobile/features/settings/screens/language_screen.dart';
import 'package:taskflow_mobile/features/splash/screens/splash_screen.dart';
import 'package:taskflow_mobile/features/tasks/screens/tasks_screen.dart';
import 'package:taskflow_mobile/features/tasks/screens/task_details_screen.dart';
import 'package:taskflow_mobile/features/tasks/screens/complete_task_screen.dart';

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    _authSub = ref.listen<AsyncValue<bool>>(
      authControllerProvider,
      (prev, next) => notifyListeners(),
    );
  }

  final Ref ref;
  late final ProviderSubscription<AsyncValue<bool>> _authSub;

  @override
  void dispose() {
    _authSub.close();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: notifier, // keep ONE router instance
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigationScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'due-today',
                    builder: (context, state) => const DueTodayScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.tasks,
                builder: (context, state) => const TasksScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => TaskDetailsScreen(
                      taskId: state.pathParameters['id']!,
                      focusComments:
                          state.uri.queryParameters['focus'] == 'comments',
                    ),
                    routes: [
                      GoRoute(
                        path: 'complete',
                        builder: (context, state) => CompleteTaskScreen(
                          taskId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                    routes: [
                      GoRoute(
                        path: 'language',
                        builder: (context, state) => const LanguageScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'legal/:slug',
                    builder: (context, state) =>
                        LegalWebViewScreen(slug: state.pathParameters['slug']!),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    // Minimal gating: Splash decides the first hop; router only guards app pages.
    redirect: (context, state) {
      final location = state.matchedLocation;

      final isOnSplash = location == RouteNames.splash;
      final isOnOnboarding = location == RouteNames.onboarding;
      final isOnLogin = location == RouteNames.login;
      final appRoots = <String>{
        RouteNames.home,
        RouteNames.tasks,
        RouteNames.calendar,
        RouteNames.profile,
      };
      final isAppRoute = appRoots.any(
        (root) => location == root || location.startsWith('$root/'),
      );

      if (isOnSplash) return null; // Always allow Splash to show

      final auth = ref.read(authControllerProvider);

      // While auth is resolving, do nothing (prevents bounce loops).
      if (auth.isLoading) return null;

      final isAuthenticated = auth.asData?.value ?? false;

      // Not authenticated: allow onboarding/login; block /app/*
      if (!isAuthenticated) {
        if (isAppRoute) return RouteNames.login;
        return null;
      }

      // Authenticated: block going back to login/onboarding
      if (isOnLogin || isOnOnboarding) return RouteNames.home;

      return null;
    },
  );
});
