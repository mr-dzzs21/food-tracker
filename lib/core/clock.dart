import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Where the app gets "now" from.
///
/// Always read the time through this provider instead of `DateTime.now()`.
/// Tests replace it with `Clock.fixed(...)` so "today" never changes.
final clockProvider = Provider<Clock>((ref) => const Clock());

/// A diary day is stored as text in the form `yyyy-MM-dd`, for example
/// `2026-11-14`. Text keys avoid time-zone and daylight-saving surprises:
/// a meal eaten at 23:30 always belongs to that local calendar day.
final _dayKeyFormat = DateFormat('yyyy-MM-dd');

/// The day key of a local date and time.
String dayKeyOf(DateTime dateTime) => _dayKeyFormat.format(dateTime);

/// Today's day key according to [clock].
String todayKey(Clock clock) => dayKeyOf(clock.now());

/// Turns a day key back into a local date (at midnight).
///
/// Throws a [FormatException] for anything that is not a real `yyyy-MM-dd` date.
DateTime parseDayKey(String key) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key);
  if (match == null) throw FormatException('Not a day key', key);
  final date = DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
  // DateTime(2026, 2, 31) silently becomes March 3rd, so compare back.
  if (dayKeyOf(date) != key) throw FormatException('Not a real date', key);
  return date;
}

/// Whether [key] is a valid day key.
bool isDayKey(String key) {
  try {
    parseDayKey(key);
    return true;
  } on FormatException {
    return false;
  }
}

/// The day key [days] days after [key] (negative goes back).
///
/// Uses calendar arithmetic (not 24-hour steps), so daylight-saving changes
/// never skip or repeat a day.
String addDays(String key, int days) {
  final date = parseDayKey(key);
  return dayKeyOf(DateTime(date.year, date.month, date.day + days));
}

/// Monday of the week that contains [key] (weeks start on Monday, ISO 8601).
String mondayOf(String key) {
  final date = parseDayKey(key);
  return addDays(key, -(date.weekday - DateTime.monday));
}

/// ISO 8601 week number (1–53) of the day [key].
int isoWeekNumber(String key) {
  final date = parseDayKey(key);
  // The ISO week belongs to the year of its Thursday. UTC dates make every
  // day exactly 24 hours long (no daylight-saving gaps).
  final thursday = DateTime.utc(
    date.year,
    date.month,
    date.day + 4 - date.weekday,
  );
  final dayOfYear = thursday.difference(DateTime.utc(thursday.year)).inDays;
  return dayOfYear ~/ 7 + 1;
}
