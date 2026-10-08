class AppConstants {
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';

  // Timing
  static const int splashDuration = 2000; // milliseconds
  static const int onboardingAnimationDuration = 300;

  // Pagination
  static const int defaultPageSize = 20;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocTypes = ['pdf', 'doc', 'docx'];
}
