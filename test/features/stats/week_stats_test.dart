import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/clock.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/features/stats/stats_providers.dart';
import 'package:food_tracker/features/stats/week_stats.dart';
import 'package:food_tracker/features/stats/week_title.dart';
import 'package:food_tracker/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

/// Monday of the test week (testNow is Saturday, 14 Nov 2026, ISO week 46).
const monday = '2026-11-09';

var _nextId = 1;

/// A diary entry of [amount] g with values per 100 g.
DiaryEntry entry(
  String day, {
  double amount = 100,
  double? kcal = 500,
  double? protein = 20,
  double? carbs = 60,
  double? fat = 10,
}) => DiaryEntry(
  id: _nextId++,
  day: day,
  mealSlotId: 1,
  name: 'Test',
  amount: amount,
  isLiquid: false,
  kcal: kcal,
  protein: protein,
  carbs: carbs,
  fat: fat,
  createdAt: testNow,
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de');
    await initializeDateFormatting('en');
  });

  group('WeekStats', () {
    test('has the seven days Monday to Sunday', () {
      final stats = WeekStats.of(monday, const []);
      expect(stats.days, [
        '2026-11-09',
        '2026-11-10',
        '2026-11-11',
        '2026-11-12',
        '2026-11-13',
        '2026-11-14',
        '2026-11-15',
      ]);
      expect(stats.dayTotals, hasLength(7));
    });

    test('a week across the turn of the year', () {
      expect(weekDays('2026-12-28').last, '2027-01-03');
    });

    test('rejects a day that is not a Monday', () {
      expect(() => WeekStats.of('2026-11-10', const []), throwsArgumentError);
    });

    test('sums each day and ignores entries outside the week', () {
      final stats = WeekStats.of(monday, [
        entry('2026-11-08'), // Sunday before
        entry('2026-11-09', amount: 200), // Monday: 1000 kcal
        entry('2026-11-09', amount: 50), // Monday: + 250 kcal
        entry('2026-11-15', amount: 100), // Sunday: 500 kcal
        entry('2026-11-16'), // Monday after
      ]);
      expect(stats.dayTotals.first[Nutrient.kcal].value, 1250);
      expect(stats.dayTotals.first.entryCount, 2);
      expect(stats.dayTotals.last[Nutrient.kcal].value, 500);
      expect(stats.dayTotals[2].entryCount, 0);
      expect(stats.daysLogged, 2);
      expect(stats.weekTotals.entryCount, 3);
    });

    test('averages only over the days with entries', () {
      final stats = WeekStats.of(monday, [
        entry('2026-11-09', amount: 400), // 2000 kcal, 80 g protein
        entry('2026-11-11', amount: 200), // 1000 kcal, 40 g protein
      ]);
      // 3000 kcal on 2 days – not divided by 7.
      expect(stats.average(Nutrient.kcal), 1500);
      expect(stats.average(Nutrient.protein), 60);
      expect(stats.average(Nutrient.carbs), 180);
      expect(stats.average(Nutrient.fat), 30);
      expect(stats.averageState(Nutrient.kcal), TotalState.complete);
      expect(stats.isEmpty, isFalse);
    });

    test('missing values make the average a lower bound, not 0', () {
      final stats = WeekStats.of(monday, [
        entry('2026-11-09', amount: 200, protein: null),
        entry('2026-11-10', kcal: null, protein: null),
      ]);
      // The known 1000 kcal over 2 logged days; the second day is unknown.
      expect(stats.average(Nutrient.kcal), 500);
      expect(stats.averageState(Nutrient.kcal), TotalState.partial);
      expect(stats.dayTotals[1].stateOf(Nutrient.kcal), TotalState.unknown);
      // No entry knows protein: unknown, shown as "–".
      expect(stats.averageState(Nutrient.protein), TotalState.unknown);
    });

    test('an empty week has no average', () {
      final stats = WeekStats.of(monday, const []);
      expect(stats.isEmpty, isTrue);
      expect(stats.daysLogged, 0);
      expect(stats.average(Nutrient.kcal), isNull);
    });
  });

  group('ISO week', () {
    test('the week year is the year of the Thursday', () {
      expect(isoWeekYear('2026-11-14'), 2026);
      expect(isoWeekYear('2027-01-03'), 2026); // week 53 of 2026
      expect(isoWeekYear('2025-12-29'), 2026); // week 1 of 2026
      expect(isoWeekNumber('2027-01-03'), 53);
    });

    test('currentMonday follows the clock', () {
      expect(currentMonday(Clock.fixed(testNow)), monday);
      // Sunday still belongs to the week that started on Monday.
      expect(currentMonday(Clock.fixed(DateTime(2026, 11, 15, 23))), monday);
      expect(currentMonday(Clock.fixed(DateTime(2026, 11, 16))), '2026-11-16');
    });
  });

  group('weekTitle', () {
    final de = lookupAppLocalizations(const Locale('de'));
    final en = lookupAppLocalizations(const Locale('en'));

    String title(String week, AppLocalizations l10n) =>
        weekTitle(week, current: monday, l10n: l10n);

    test('the current week is "Diese Woche"', () {
      expect(title(monday, de), 'Diese Woche');
      expect(title(monday, en), 'This week');
    });

    test('a past week inside one month', () {
      expect(title('2026-11-02', de), 'KW 45 · 2.–8. Nov.');
      expect(title('2026-11-02', en), 'Week 45 · Nov 2–8');
    });

    test('a week across two months', () {
      expect(title('2026-10-26', de), 'KW 44 · 26. Okt. – 1. Nov.');
      expect(title('2026-10-26', en), 'Week 44 · Oct 26 – Nov 1');
    });

    test('a week of another year shows the year', () {
      expect(title('2025-11-10', de), 'KW 46/2025 · 10.–16. Nov.');
      expect(title('2025-11-10', en), 'Week 46/2025 · Nov 10–16');
      // 29 Dec 2025 – 4 Jan 2026 is week 1 of 2026: no year needed.
      expect(title('2025-12-29', de), 'KW 1 · 29. Dez. – 4. Jan.');
    });
  });

  group('weekStatsProvider and selectedWeekProvider', () {
    late AppDatabase db;

    setUp(() => db = newTestDatabase());
    tearDown(() => db.close());

    ProviderContainer container() =>
        ProviderContainer.test(overrides: testOverrides(db: db));

    test('loads the entries of the week from the database', () async {
      final repo = DiaryRepository(db, Clock.fixed(testNow));
      final food = await db
          .into(db.foods)
          .insertReturning(
            FoodsCompanion.insert(
              source: FoodSource.user,
              name: 'Brot',
              kcal: const Value(250),
              createdAt: testNow,
            ),
          );
      final slotId = (await db.select(db.mealSlots).get()).first.id;
      for (final day in ['2026-11-08', '2026-11-09', '2026-11-15']) {
        await repo.addEntry(
          food: food,
          amount: 200,
          day: day,
          mealSlotId: slotId,
        );
      }

      final c = container();
      // Riverpod pauses providers without listeners; listen, then read.
      final subscription = c.listen(
        weekStatsProvider(monday).future,
        (_, _) {},
      );
      final stats = await subscription.read();
      expect(stats.daysLogged, 2); // the Sunday before is not in this week
      expect(stats.average(Nutrient.kcal), 500);
    });

    test('a new week (todayProvider.refresh) moves the current week on, not '
        'a picked one', () {
      var now = DateTime(2026, 11, 15, 23, 50); // Sunday
      final c = ProviderContainer.test(
        overrides: testOverrides(db: db, clock: Clock(() => now)),
      );
      expect(c.read(selectedWeekProvider), '2026-11-09');

      now = DateTime(2026, 11, 16, 7); // Monday
      c.read(todayProvider.notifier).refresh();
      expect(c.read(selectedWeekProvider), '2026-11-16');
      expect(c.read(selectedWeekProvider.notifier).isCurrentWeek, isTrue);

      c.read(selectedWeekProvider.notifier).previous();
      now = DateTime(2026, 11, 23, 7);
      c.read(todayProvider.notifier).refresh();
      expect(c.read(selectedWeekProvider), '2026-11-09');
    });

    test('starts at this week, goes back, never into the future', () {
      final c = container();
      final notifier = c.read(selectedWeekProvider.notifier);
      expect(c.read(selectedWeekProvider), monday);
      expect(notifier.isCurrentWeek, isTrue);

      notifier.next();
      expect(c.read(selectedWeekProvider), monday);

      notifier
        ..previous()
        ..previous();
      expect(c.read(selectedWeekProvider), '2026-10-26');
      expect(notifier.isCurrentWeek, isFalse);

      notifier
        ..next()
        ..next()
        ..next();
      expect(c.read(selectedWeekProvider), monday);
    });
  });
}
