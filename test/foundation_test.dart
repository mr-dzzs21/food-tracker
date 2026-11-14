import 'package:drift/drift.dart' show OrderingTerm, Value, Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/clock.dart';
import 'package:food_tracker/core/format.dart';
import 'package:food_tracker/core/widgets/app_nav_bar.dart';
import 'package:food_tracker/data/database.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

void main() {
  group('day keys', () {
    test('format and parse', () {
      expect(dayKeyOf(DateTime(2026, 11, 14, 23, 59)), '2026-11-14');
      expect(parseDayKey('2026-03-01'), DateTime(2026, 3));
      expect(() => parseDayKey('2026-02-31'), throwsFormatException);
      expect(() => parseDayKey('14.11.2026'), throwsFormatException);
      expect(isDayKey('2026-11-14'), isTrue);
      expect(isDayKey('abc'), isFalse);
    });

    test('addDays crosses months, years and daylight-saving changes', () {
      expect(addDays('2026-11-30', 1), '2026-12-01');
      expect(addDays('2026-12-31', 1), '2027-01-01');
      expect(addDays('2026-03-01', -1), '2026-02-28');
      // Germany switches to summer time on 29 March 2026.
      expect(addDays('2026-03-28', 1), '2026-03-29');
      expect(addDays('2026-03-29', 1), '2026-03-30');
      expect(addDays('2026-10-25', 1), '2026-10-26');
    });

    test('weeks start on Monday and use ISO numbers', () {
      expect(mondayOf('2026-11-14'), '2026-11-09'); // Saturday → Monday
      expect(mondayOf('2026-11-09'), '2026-11-09');
      expect(mondayOf('2026-11-15'), '2026-11-09'); // Sunday
      expect(isoWeekNumber('2026-11-14'), 46);
      expect(isoWeekNumber('2027-01-01'), 53); // belongs to week 53 of 2026
      expect(isoWeekNumber('2026-01-01'), 1);
    });
  });

  group('number formatting', () {
    test('kcal are whole numbers with grouping', () {
      expect(formatKcal(1240.4, 'de'), '1.240');
      expect(formatKcal(1240.5, 'en'), '1,241');
    });

    test('grams follow the EU rounding steps', () {
      expect(formatGrams(4.46, 'de'), '4,5');
      expect(formatGrams(4.0, 'de'), '4');
      expect(formatGrams(12.4, 'de'), '12');
      expect(formatGrams(2.675, 'en'), '2.7');
      expect(formatSalt(0.1075, 'de'), '0,11');
      expect(formatSalt(1.56, 'de'), '1,6');
    });

    test('half rounds away from zero without binary errors', () {
      expect(roundHalfUp(2.675, 2), 2.68);
      expect(roundHalfUp(0.125, 2), 0.13);
      expect(roundHalfUp(160.5, 0), 161);
    });

    test('amounts and user input', () {
      expect(formatAmount(60, isLiquid: false, locale: 'de'), '60 g');
      expect(formatAmount(12.5, isLiquid: true, locale: 'de'), '12,5 ml');
      expect(parseUserNumber(' 4,5 '), 4.5);
      expect(parseUserNumber('4.5'), 4.5);
      expect(parseUserNumber(''), isNull);
      expect(parseUserNumber('abc'), isNull);
    });
  });

  group('database', () {
    late AppDatabase db;
    setUp(() => db = newTestDatabase());
    tearDown(() => db.close());

    test('starts with the four default meals in order', () async {
      final slots = await (db.select(
        db.mealSlots,
      )..orderBy([(s) => OrderingTerm.asc(s.position)])).get();
      expect(slots.map((s) => s.builtIn), [
        'breakfast',
        'lunch',
        'dinner',
        'snacks',
      ]);
      expect(slots.every((s) => !s.isHidden), isTrue);
    });

    test('foreign keys are switched on', () async {
      final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(row.read<int>('foreign_keys'), 1);
    });

    test('deleteAllData restores the default meals', () async {
      await db
          .into(db.mealSlots)
          .insert(
            MealSlotsCompanion.insert(
              customName: const Value('Nachtsnack'),
              position: 4,
            ),
          );
      await db.deleteAllData();
      final count = await db
          .customSelect(
            'SELECT COUNT(*) AS c FROM meal_slots WHERE built_in IS NOT ?',
            variables: [Variable.withString('')],
          )
          .getSingle();
      expect(count.read<int>('c'), 4);
    });
  });

  testWidgets('app starts on "Heute" with four tabs, in German', (
    tester,
  ) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    await pumpFoodTrackerApp(tester, db: db);

    expect(find.byType(AppNavBar), findsOneWidget);
    // The open tab shows its label, the others their icon (all four are
    // named for screen readers).
    expect(find.text('Heute'), findsWidgets);
    for (final label in ['Heute', 'Scannen', 'Statistik', 'Profil']) {
      expect(
        find.descendant(
          of: find.byType(AppNavBar),
          matching: find.bySemanticsLabel(label),
        ),
        findsOneWidget,
        reason: label,
      );
    }

    // Material's own texts are German too (material_ui delegates work).
    final context = tester.element(find.byType(AppNavBar));
    expect(MaterialLocalizations.of(context).backButtonTooltip, 'Zurück');
  });

  testWidgets('tabs switch, and the app also runs in English', (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    await pumpFoodTrackerApp(tester, db: db, locale: const Locale('en'));

    expect(find.bySemanticsLabel('Statistics'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(AppNavBar), findsOneWidget);
    expect(find.text('Your daily goal'), findsOneWidget);
  });
}
