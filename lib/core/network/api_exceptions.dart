/// Why a request failed. Everything except [server] has a localized message
/// in the app's translations; [server] carries the backend's own text.
enum ApiErrorKind { server, generic, timeout, offline, certificate, cancelled }

/// Application-level exception. UI code should only ever catch this —
/// never a raw DioException.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.kind = ApiErrorKind.server,
  });

  const ApiException.generic()
    : this(
        'Something went wrong. Please try again.',
        kind: ApiErrorKind.generic,
      );

  final String message;
  final int? statusCode;
  final ApiErrorKind kind;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => (statusCode ?? 0) >= 500;

  @override
  String toString() => message;
}
