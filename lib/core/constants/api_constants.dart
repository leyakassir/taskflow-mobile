class ApiConstants {
  ApiConstants._();

  /// Override with: `flutter run --dart-define=API_BASE_URL=http://PC_IP:3000`
  /// The default is the dev PC's current Wi-Fi address (it changes when the
  /// PC joins another network; check with `ipconfig`). Android emulator:
  /// use http://10.0.2.2:3000.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.10.226:3000',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Public, cheap endpoint used to check whether the server is reachable.
  static const String configLocales = '/config/locales';

  /// Server-Sent Events stream of live change notices.
  static const String events = '/events';

  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String signupRequests = '/signup-requests';
  static const String signupRequestsVerify = '/signup-requests/verify';
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
