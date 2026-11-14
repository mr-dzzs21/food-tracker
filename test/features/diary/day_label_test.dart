import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/format.dart';
import 'package:food_tracker/features/diary/day_label.dart';
import 'package:food_tracker/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  // In the app the localisation delegates load the date symbols; a plain
  // unit test has to do it itself.
  setUpAll(() async {
    await initializeDateFormatting('de');
    await initializeDateFormatting('en');
  });

  const today = '2026-11-14'; // a Saturday

  test('German: Heute, Gestern, Morgen, otherwise the weekday', () {
    final l10n = lookupAppLocalizations(const Locale('de'));
    expect(dayLabel(today, today: today, l10n: l10n), 'Heute, 14. Nov.');
    expect(
      dayLabel('2026-11-13', today: today, l10n: l10n),
      'Gestern, 13. Nov.',
    );
    expect(
      dayLabel('2026-11-15', today: today, l10n: l10n),
      'Morgen, 15. Nov.',
    );
    expect(dayLabel('2026-11-11', today: today, l10n: l10n), 'Mi., 11. Nov.');
  });

  test('English', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(dayLabel(today, today: today, l10n: l10n), 'Today, Nov 14');
    expect(dayLabel('2026-11-11', today: today, l10n: l10n), 'Wed, Nov 11');
  });

  test('formatInputNumber has no thousands separator', () {
    expect(formatInputNumber(1000, 'de'), '1000');
    expect(formatInputNumber(12.5, 'de'), '12,5');
    expect(formatInputNumber(12.5, 'en'), '12.5');
    expect(formatInputNumber(30, 'de'), '30');
    expect(formatInputNumber(33.333, 'de'), '33,3');
  });
}
