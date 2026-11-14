import 'package:intl/intl.dart';

/// Number formatting for nutrition values.
///
/// All functions take the locale name (for example `de` or `en`) so that
/// German users see `1.240` and `4,5 g` while English users see `1,240` and
/// `4.5 g`. Get it in a widget with `AppLocalizations.of(context).localeName`.
///
/// Rounding follows the EU guidance for nutrition labels:
/// - kcal: whole numbers
/// - grams: one decimal, whole grams from 10 g upwards
/// - salt below 1 g: two decimals
///
/// Values are stored with full precision; only the display is rounded.

/// Rounds half away from zero to [decimals] places, without the binary
/// floating-point trap (2.675 must become 2.68, not 2.67).
double roundHalfUp(double value, int decimals) {
  final factor = _pow10(decimals);
  // toStringAsFixed(6) removes tiny binary errors such as 267.49999999999997
  // before rounding.
  final shifted = double.parse((value * factor).toStringAsFixed(6));
  return shifted.round() / factor;
}

double _pow10(int n) {
  var result = 1.0;
  for (var i = 0; i < n; i++) {
    result *= 10;
  }
  return result;
}

String _number(double value, int maxDecimals, String locale) {
  final format = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = maxDecimals;
  return format.format(roundHalfUp(value, maxDecimals));
}

/// `1240.4` → `1.240` (de) / `1,240` (en).
String formatKcal(double kcal, String locale) => _number(kcal, 0, locale);

/// Grams of a nutrient: `4.46` → `4,5`, `12.4` → `12`, `0.04` → `0`.
String formatGrams(double grams, String locale) =>
    _number(grams, grams.abs() >= 10 ? 0 : 1, locale);

/// Salt: `0.1075` → `0,11`, `1.56` → `1,6`.
String formatSalt(double grams, String locale) =>
    _number(grams, grams.abs() < 1 ? 2 : 1, locale);

/// An amount the user ate or drank: `60` → `60 g`, `200` → `200 ml`,
/// `12.5` → `12,5 g`.
String formatAmount(
  double amount, {
  required bool isLiquid,
  required String locale,
}) {
  final unit = isLiquid ? 'ml' : 'g';
  return '${_number(amount, 1, locale)} $unit';
}

/// Parses a number the user typed. Accepts both `4,5` and `4.5`.
/// Returns null for empty or invalid text.
double? parseUserNumber(String text) {
  final cleaned = text.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value.isNaN || value.isInfinite) return null;
  return value;
}
