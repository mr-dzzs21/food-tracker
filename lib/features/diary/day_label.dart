import 'package:intl/intl.dart';

import '../../core/clock.dart';
import '../../l10n/app_localizations.dart';

/// A short title for a diary [day] relative to [today] (both `yyyy-MM-dd`):
///
/// - "Heute, 14. Nov." / "Today, Nov 14"
/// - "Gestern, 13. Nov." and "Morgen, 15. Nov."
/// - otherwise with the weekday: "Mi., 11. Nov." / "Wed, Nov 11"
///
/// Uses the language of [l10n]. Needs the date symbols of that language,
/// which the app's localisation delegates load.
String dayLabel(
  String day, {
  required String today,
  required AppLocalizations l10n,
}) {
  final date = parseDayKey(day);
  final locale = l10n.localeName;
  final short = DateFormat.MMMd(locale).format(date);
  if (day == today) return l10n.dayTitleToday(short);
  if (day == addDays(today, -1)) return l10n.dayTitleYesterday(short);
  if (day == addDays(today, 1)) return l10n.dayTitleTomorrow(short);
  return DateFormat.MMMEd(locale).format(date);
}
