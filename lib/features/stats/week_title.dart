import 'package:intl/intl.dart';

import '../../core/clock.dart';
import '../../l10n/app_localizations.dart';
import 'week_stats.dart';

/// The title of the week that starts on [monday]:
///
/// - the current week: "Diese Woche" / "This week"
/// - another week of the same year: "KW 45 · 2.–8. Nov." / "Week 45 · Nov 2–8"
/// - across two months: "KW 44 · 26. Okt. – 1. Nov."
/// - a week of another year gets the year: "KW 46/2025 · 10.–16. Nov."
///
/// [current] is the Monday of the current week. "KW" (Kalenderwoche) is the
/// ISO week number Germans know from calendars.
String weekTitle(
  String monday, {
  required String current,
  required AppLocalizations l10n,
}) {
  if (monday == current) return l10n.statsThisWeek;
  return weekNumberTitle(monday, current: current, l10n: l10n);
}

/// The week number and dates of the week that starts on [monday], also for
/// the current week: "KW 46 · 9.–15. Nov." (shown below "Diese Woche").
String weekNumberTitle(
  String monday, {
  required String current,
  required AppLocalizations l10n,
}) {
  final week = '${isoWeekNumber(monday)}';
  final range = _dayRange(monday, l10n);
  final year = isoWeekYear(monday);
  return year == isoWeekYear(current)
      ? l10n.statsWeekTitle(week, range)
      : l10n.statsWeekTitleWithYear(week, '$year', range);
}

/// "10.–16. Nov." / "Nov 10–16", or "26. Okt. – 1. Nov." / "Oct 26 – Nov 1".
String _dayRange(String monday, AppLocalizations l10n) {
  final first = parseDayKey(monday);
  final last = parseDayKey(addDays(monday, 6));
  final locale = l10n.localeName;
  // German and English order day and month differently, so the ARB files
  // hold the pattern.
  if (first.month == last.month) {
    return l10n.statsRangeSameMonth(
      '${first.day}',
      '${last.day}',
      _shortMonth(first, locale),
    );
  }
  final format = DateFormat.MMMd(locale);
  return l10n.statsRangeTwoMonths(format.format(first), format.format(last));
}

/// The short month name as written inside a date: German "Nov.", English
/// "Nov". `DateFormat.MMM` would give the stand-alone form ("Nov" in German,
/// as in a calendar header), which looks wrong after "10.–16.".
String _shortMonth(DateTime date, String locale) =>
    DateFormat.MMM(locale).dateSymbols.SHORTMONTHS[date.month - 1];
