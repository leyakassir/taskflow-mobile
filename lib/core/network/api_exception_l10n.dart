import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

extension ApiExceptionL10n on ApiException {
  /// Message in the app language. Errors the app raised itself are
  /// translated; text written by the backend is shown as received.
  String localized(AppLocalizations l10n) => switch (kind) {
    ApiErrorKind.server => isServerError ? l10n.genericError : message,
    ApiErrorKind.generic => l10n.genericError,
    ApiErrorKind.timeout => l10n.errorTimeout,
    ApiErrorKind.offline => l10n.errorOffline,
    ApiErrorKind.certificate => l10n.errorCertificate,
    ApiErrorKind.cancelled => l10n.errorCancelled,
  };
}
