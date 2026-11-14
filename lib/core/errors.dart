import '../l10n/app_localizations.dart';

/// Everything that can go wrong when the app talks to the outside world
/// (today: Open Food Facts).
///
/// The data layer throws these. The UI turns them into a friendly message
/// with [failureMessage]. Using a `sealed` class means the compiler checks
/// that every case has a message.
sealed class AppFailure implements Exception {
  const AppFailure();
}

/// The barcode has the wrong length or a wrong check digit (typo, bad scan).
class InvalidBarcode extends AppFailure {
  const InvalidBarcode(this.code);
  final String code;
}

/// Open Food Facts does not know this barcode.
class ProductNotFound extends AppFailure {
  const ProductNotFound(this.code);
  final String code;
}

/// The barcode belongs to something that is not food (cosmetics, pet food…).
class NotFood extends AppFailure {
  const NotFood(this.code);
  final String code;
}

/// The product exists but its calories are unknown, so it cannot be logged.
class IncompleteProduct extends AppFailure {
  const IncompleteProduct(this.code);
  final String code;
}

/// No internet connection.
class Offline extends AppFailure {
  const Offline();
}

/// The server did not answer in time.
class RequestTimeout extends AppFailure {
  const RequestTimeout();
}

/// Too many requests in a short time (HTTP 429 or our own limit).
class RateLimited extends AppFailure {
  const RateLimited();
}

/// The server answered with an error, an HTML maintenance page or something
/// we could not read.
class ServerUnavailable extends AppFailure {
  const ServerUnavailable({this.maintenance = false});

  /// True when the server sent an HTML page (maintenance or overload).
  final bool maintenance;
}

/// The user-facing text for [failure], in the current language.
String failureMessage(AppFailure failure, AppLocalizations l10n) {
  return switch (failure) {
    InvalidBarcode() => l10n.failureInvalidBarcode,
    ProductNotFound() => l10n.failureNotFound,
    NotFood() => l10n.failureNotFood,
    IncompleteProduct() => l10n.failureIncomplete,
    Offline() => l10n.failureOffline,
    RequestTimeout() => l10n.failureTimeout,
    RateLimited() => l10n.failureRateLimited,
    ServerUnavailable(maintenance: true) => l10n.failureMaintenance,
    ServerUnavailable() => l10n.failureServer,
  };
}
