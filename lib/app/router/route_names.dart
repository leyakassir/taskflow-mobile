class RouteNames {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';

  static const app = '/app';
  // Bottom-navigation tabs (StatefulShellRoute branches, in this order).
  static const home = '/app/home';
  static const tasks = '/app/tasks';
  static const calendar = '/app/calendar';
  static const profile = '/app/profile';

  /// Pushed from the bell on Home; not a tab.
  static const notifications = '/app/home/notifications';

  /// All tasks due today, opened from Home's "Due today" count.
  static const dueToday = '/app/home/due-today';
  static const settings = '/app/profile/settings';
  static const language = '/app/profile/settings/language';
  static String legalPath(String slug) => '/app/profile/legal/$slug';
  static const forgotPassword = '/forgot-password';

  /// Second step of "Forgot password": enter the emailed code. The email is
  /// passed as the route's `extra`.
  static const resetPassword = '/forgot-password/reset';

  static const taskDetails = '/app/tasks/:id';
  static const taskComplete = '/app/tasks/:id/complete';

  static String taskDetailsPath(String id, {bool focusComments = false}) =>
      focusComments ? '/app/tasks/$id?focus=comments' : '/app/tasks/$id';
  static String taskCompletePath(String id) => '/app/tasks/$id/complete';
}
