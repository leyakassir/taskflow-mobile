class ApiConstants {
  ApiConstants._();

  /// Must be provided via: flutter run --dart-define=API_BASE_URL=http://...
  /// Default is Android emulator loopback, for local dev convenience only.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.10.226:3000',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String myProfile = '/me';
  static const String myPassword = '/me/password';
  static const String myAvatar = '/me/avatar';
  static const String myDeviceToken = '/me/device-token';

  static String absoluteUrl(String path) =>
      Uri.parse(baseUrl).resolve(path).toString();

  static const String tasks = '/tasks';
  static String taskById(String id) => '/tasks/$id';
  static String taskStatus(String id) => '/tasks/$id/status';
  static String taskComplete(String id) => '/tasks/$id/complete';
  static String taskAttachments(String id) => '/tasks/$id/attachments';
  static String taskComments(String id) => '/tasks/$id/comments';

  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
}
