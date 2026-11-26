import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/clock.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

const day = '2026-11-14';

void main() {
  late AppDatabase db;
  late DateTime now;
  late DiaryRepository repo;
  late List<MealSlot> slots;

  /// Default meal slots by built-in name.
  MealSlot slot(String builtIn) =>
      slots.firstWhere((s) => s.builtIn == builtIn);

  Future<Food> insertFood({
    String name = 'Haferflocken',
    String? brand = 'Kölln',
    bool isLiquid = false,
    double? kcal = 370,
    double? fat = 7,
    double? protein = 13.5,
    double? carbs = 58.7,
    String? servingLabel,
  }) {
    return db
        .into(db.foods)
        .insertReturning(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: name,
            brand: Value(brand),
            isLiquid: Value(isLiquid),
            servingLabel: Value(servingLabel),
            kcal: Value(kcal),
            fat: Value(fat),
            protein: Value(protein),
            carbs: Value(carbs),
            createdAt: testNow,
          ),
        );
  }

  setUp(() async {
    db = newTestDatabase();
    now = testNow;
    repo = DiaryRepository(db, Clock(() => now));
    slots = await repo.watchMealSlots().first;
  });

  tearDown(() => db.close());

  group('addEntry', () {
    test(
      'copies name, brand, unit, portion text and values per 100 g',
      () async {
        final food = await insertFood(
          name: 'Orangensaft',
          brand: 'Hohes C',
          isLiquid: true,
          kcal: 45,
          servingLabel: '1 Glas (200 ml)',
        );

        await repo.addEntry(
          food: food,
          amount: 200,
          day: day,
          mealSlotId: slot('breakfast').id,
        );

        final entry = (await repo.watchDay(day).first).single.entry;
        expect(entry.foodId, food.id);
        expect(entry.name, 'Orangensaft');
        expect(entry.brand, 'Hohes C');
        expect(entry.isLiquid, isTrue);
        expect(entry.servingLabel, '1 Glas (200 ml)');
        expect(entry.amount, 200);
        expect(entry.nutrientsPer100, food.nutrients);
        expect(entry.nutrients.kcal, 90);
        expect(entry.createdAt, testNow);
      },
    );

    test('marks the food as used ("Zuletzt gegessen")', () async {
      final food = await insertFood();
      now = testNow.add(const Duration(minutes: 5));

      await repo.addEntry(
        food: food,
        amount: 50,
        day: day,
        mealSlotId: slot('breakfast').id,
      );

      final stored = await (db.select(
        db.foods,
      )..where((f) => f.id.equals(food.id))).getSingle();
      expect(stored.lastUsedAt, now);
    });

    test('rejects impossible amounts and day keys', () async {
      final food = await insertFood();
      final mealId = slot('lunch').id;
      for (final amount in [0.0, -5.0, 10001.0, double.nan]) {
        expect(
          () => repo.addEntry(
            food: food,
            amount: amount,
            day: day,
            mealSlotId: mealId,
          ),
          throwsArgumentError,
          reason: '$amount',
        );
      }
      expect(
        () => repo.addEntry(
          food: food,
          amount: 50,
          day: '14.11.2026',
          mealSlotId: mealId,
        ),
        throwsArgumentError,
      );
    });
  });

  group('snapshot', () {
    test('the entry keeps its values when the food changes', () async {
      final food = await insertFood(name: 'Müsli', kcal: 380);
      await repo.addEntry(
        food: food,
        amount: 60,
        day: day,
        mealSlotId: slot('breakfast').id,
      );

      await (db.update(db.foods)..where((f) => f.id.equals(food.id))).write(
        const FoodsCompanion(name: Value('Knuspermüsli'), kcal: Value(450)),
      );

      final entry = (await repo.watchDay(day).first).single.entry;
      expect(entry.name, 'Müsli');
      expect(entry.kcal, 380);
      expect(entry.nutrients.kcal, closeTo(228, 1e-9));
    });

    test('the entry stays (without link) when the food is deleted', () async {
      final food = await insertFood(name: 'Eigenes Brot', kcal: 250);
      await repo.addEntry(
        food: food,
        amount: 80,
        day: day,
        mealSlotId: slot('lunch').id,
      );

      await (db.delete(db.foods)..where((f) => f.id.equals(food.id))).go();

      final entry = (await repo.watchDay(day).first).single.entry;
      expect(entry.foodId, isNull);
      expect(entry.name, 'Eigenes Brot');
      expect(entry.nutrients.kcal, 200);
    });
  });

  group('watchDay', () {
    test('sorts by meal position, then by time added; other days are '
        'left out', () async {
      final food = await insertFood();
      Future<void> add(String name, String meal, int minute, {String d = day}) {
        now = testNow.add(Duration(minutes: minute));
        return repo.addEntry(
          food: food.copyWith(name: name),
          amount: 10,
          day: d,
          mealSlotId: slot(meal).id,
        );
      }

      await add('Abend 1', 'dinner', 1);
      await add('Snack', 'snacks', 2);
      await add('Früh 2', 'breakfast', 4);
      await add('Früh 1', 'breakfast', 3);
      await add('Gestern', 'breakfast', 0, d: '2026-11-13');

      final items = await repo.watchDay(day).first;
      // Position order of the defaults: breakfast, lunch, dinner, snacks.
      expect(items.map((i) => i.entry.name), [
        'Früh 1',
        'Früh 2',
        'Abend 1',
        'Snack',
      ]);
      expect(items.first.slot.builtIn, 'breakfast');
    });

    test('emits again after a change', () async {
      final food = await insertFood();
      final stream = repo.watchDay(day);
      final lengths = stream.map((items) => items.length);
      final expectation = expectLater(lengths, emitsInOrder([0, 1]));
      // Let the first (empty) result arrive before inserting.
      await Future<void>.delayed(Duration.zero);
      await repo.addEntry(
        food: food,
        amount: 10,
        day: day,
        mealSlotId: slot('lunch').id,
      );
      await expectation;
    });
  });

  group('update, delete, restore', () {
    late Food food;
    late int entryId;

    setUp(() async {
      food = await insertFood();
      entryId = await repo.addEntry(
        food: food,
        amount: 40,
        day: day,
        mealSlotId: slot('breakfast').id,
      );
    });

    test('updateEntry changes amount and meal only', () async {
      await repo.updateEntry(
        entryId,
        amount: 75,
        mealSlotId: slot('snacks').id,
      );

      final item = (await repo.watchDay(day).first).single;
      expect(item.entry.amount, 75);
      expect(item.slot.builtIn, 'snacks');
      expect(item.entry.kcal, 370);
      expect(
        () =>
            repo.updateEntry(entryId, amount: 0, mealSlotId: slot('lunch').id),
        throwsArgumentError,
      );
    });

    test('delete and restore give back the same entry', () async {
      final before = (await repo.watchDay(day).first).single.entry;

      await repo.deleteEntry(entryId);
      expect(await repo.watchDay(day).first, isEmpty);

      await repo.restoreEntry(before);
      final after = (await repo.watchDay(day).first).single.entry;
      expect(after, before);
    });

    test('restore works even when the food was deleted meanwhile', () async {
      final before = (await repo.watchDay(day).first).single.entry;
      await repo.deleteEntry(entryId);
      await (db.delete(db.foods)..where((f) => f.id.equals(food.id))).go();

      await repo.restoreEntry(before);

      final after = (await repo.watchDay(day).first).single.entry;
      expect(after.id, before.id);
      expect(after.foodId, isNull);
      expect(after.kcal, before.kcal);
    });

    test('lastAmountFor returns the newest amount of that food', () async {
      expect(await repo.lastAmountFor(food.id), 40);
      now = testNow.add(const Duration(hours: 1));
      await repo.addEntry(
        food: food,
        amount: 55.5,
        day: '2026-11-13',
        mealSlotId: slot('lunch').id,
      );
      expect(await repo.lastAmountFor(food.id), 55.5);
      final other = await insertFood(name: 'Neu');
      expect(await repo.lastAmountFor(other.id), isNull);
    });
  });

  group('DayTotals', () {
    test('sums per meal and marks missing values as partial', () async {
      final complete = await insertFood(kcal: 200, protein: 10, fat: 5);
      final noProtein = await insertFood(kcal: 100, protein: null, fat: 2);
      final breakfast = slot('breakfast').id;
      final dinner = slot('dinner').id;
      await repo.addEntry(
        food: complete,
        amount: 50,
        day: day,
        mealSlotId: breakfast,
      );
      await repo.addEntry(
        food: noProtein,
        amount: 200,
        day: day,
        mealSlotId: breakfast,
      );
      await repo.addEntry(
        food: complete,
        amount: 100,
        day: day,
        mealSlotId: dinner,
      );

      final totals = DayTotals.of(await repo.watchDay(day).first);

      // 100 + 200 + 200 kcal
      expect(totals.all[Nutrient.kcal].value, closeTo(500, 1e-9));
      expect(totals.all.stateOf(Nutrient.kcal), TotalState.complete);
      // Protein: 5 + (unknown) + 10 → "mind. 15 g"
      expect(totals.all[Nutrient.protein].value, closeTo(15, 1e-9));
      expect(totals.all[Nutrient.protein].missingCount, 1);
      expect(totals.all.stateOf(Nutrient.protein), TotalState.partial);

      expect(
        totals.forMeal(breakfast)[Nutrient.kcal].value,
        closeTo(300, 1e-9),
      );
      expect(
        totals.forMeal(breakfast).stateOf(Nutrient.protein),
        TotalState.partial,
      );
      expect(totals.forMeal(dinner)[Nutrient.kcal].value, closeTo(200, 1e-9));
      expect(
        totals.forMeal(dinner).stateOf(Nutrient.protein),
        TotalState.complete,
      );
      // A meal without entries: complete zero.
      final lunch = totals.forMeal(slot('lunch').id);
      expect(lunch.entryCount, 0);
      expect(lunch[Nutrient.kcal].value, 0);
      expect(lunch.stateOf(Nutrient.kcal), TotalState.complete);
    });

    test('an empty day is complete zero', () {
      final totals = DayTotals.of(const []);
      expect(totals.all[Nutrient.kcal].value, 0);
      expect(totals.all.stateOf(Nutrient.fat), TotalState.complete);
    });
  });

  group('meal slots', () {
    test('come sorted by position', () {
      expect(slots.map((s) => s.builtIn), [
        'breakfast',
        'lunch',
        'dinner',
        'snacks',
      ]);
    });

    test('names: own name first, else translated default', () {
      final de = lookupAppLocalizations(const Locale('de'));
      final en = lookupAppLocalizations(const Locale('en'));
      expect(mealSlotName(slot('breakfast'), de), 'Frühstück');
      expect(mealSlotName(slot('breakfast'), en), 'Breakfast');
      expect(mealSlotName(slot('snacks'), de), 'Snacks');
      final renamed = slot('lunch')
          .copyWith(customName: const Value('Brotzeit'));
      expect(mealSlotName(renamed, en), 'Brotzeit');
      final blank = slot('dinner').copyWith(customName: const Value('  '));
      expect(mealSlotName(blank, de), 'Abendessen');
      const custom = MealSlot(id: 9, position: 4, isHidden: false);
      expect(mealSlotName(custom, de), 'Mahlzeit');
    });

    test('German articles: "Zum Frühstück", "Zu den Snacks", own names '
        'with "Zu"', () {
      final de = lookupAppLocalizations(const Locale('de'));
      final en = lookupAppLocalizations(const Locale('en'));
      String added(MealSlot s, AppLocalizations l10n) =>
          l10n.productAdded(mealSlotTextKey(s), mealSlotName(s, l10n));
      String add(MealSlot s, AppLocalizations l10n) =>
          l10n.mealAddTooltip(mealSlotTextKey(s), mealSlotName(s, l10n));

      expect(added(slot('breakfast'), de), 'Zum Frühstück hinzugefügt');
      expect(added(slot('lunch'), de), 'Zum Mittagessen hinzugefügt');
      expect(added(slot('dinner'), de), 'Zum Abendessen hinzugefügt');
      expect(added(slot('snacks'), de), 'Zu den Snacks hinzugefügt');
      expect(add(slot('breakfast'), de), 'Zum Frühstück hinzufügen');
      expect(add(slot('snacks'), de), 'Zu den Snacks hinzufügen');
      final renamed = slot('lunch')
          .copyWith(customName: const Value('Brotzeit'));
      expect(mealSlotTextKey(renamed), 'other');
      expect(added(renamed, de), 'Zu Brotzeit hinzugefügt');
      expect(add(renamed, de), 'Zu Brotzeit hinzufügen');
      expect(added(slot('breakfast'), en), 'Added to Breakfast');
      expect(add(slot('snacks'), en), 'Add to Snacks');
    });
  });

  test('parseEntryAmount accepts comma and point, rejects the rest', () {
    expect(parseEntryAmount('12,5', 'de'), 12.5);
    expect(parseEntryAmount(' 200 ', 'de'), 200);
    expect(parseEntryAmount('0.5', 'de'), 0.5);
    expect(parseEntryAmount('0', 'de'), isNull);
    expect(parseEntryAmount('-3', 'de'), isNull);
    expect(parseEntryAmount('10001', 'de'), isNull);
    expect(parseEntryAmount('', 'de'), isNull);
    expect(parseEntryAmount('viel', 'de'), isNull);
  });

  test('parseEntryAmount: 1.000 ml (de) and 1,000 ml (en) are a litre', () {
    expect(parseEntryAmount('1.000', 'de'), 1000);
    expect(parseEntryAmount('1,000', 'en'), 1000);
    expect(parseEntryAmount('1.500,5', 'de'), 1500.5);
    expect(parseEntryAmount('10.001', 'de'), isNull); // above the maximum
  });

  group('selectedDayProvider', () {
    ProviderContainer container() => ProviderContainer.test(
      overrides: [clockProvider.overrideWithValue(Clock.fixed(testNow))],
    );

    test('starts at today and steps through days', () {
      final c = container();
      final notifier = c.read(selectedDayProvider.notifier);
      expect(c.read(selectedDayProvider), '2026-11-14');

      notifier.previous();
      expect(c.read(selectedDayProvider), '2026-11-13');
      notifier
        ..next()
        ..next();
      expect(c.read(selectedDayProvider), '2026-11-15');
      notifier.set('2026-12-31');
      notifier.next();
      expect(c.read(selectedDayProvider), '2027-01-01');
      notifier.today();
      expect(c.read(selectedDayProvider), '2026-11-14');
    });

    test('stays between 1 Jan 2000 and the end of next year', () {
      final c = container();
      final notifier = c.read(selectedDayProvider.notifier);
      notifier.set('2027-12-31');
      expect(notifier.canGoForward, isFalse);
      notifier.next();
      expect(c.read(selectedDayProvider), '2027-12-31');
      notifier.set('2031-05-01');
      expect(c.read(selectedDayProvider), '2027-12-31');

      notifier.set('1999-12-31');
      expect(c.read(selectedDayProvider), firstSelectableDay);
      expect(notifier.canGoBack, isFalse);
      notifier.previous();
      expect(c.read(selectedDayProvider), '2000-01-01');
      expect(notifier.canGoForward, isTrue);
    });

    test('a new day (todayProvider.refresh) moves "Heute" on, not a picked '
        'day', () {
      var now = DateTime(2026, 11, 14, 23, 50);
      final c = ProviderContainer.test(
        overrides: [clockProvider.overrideWithValue(Clock(() => now))],
      );
      expect(c.read(selectedDayProvider), '2026-11-14');

      now = DateTime(2026, 11, 15, 7);
      c.read(todayProvider.notifier).refresh();
      expect(c.read(selectedDayProvider), '2026-11-15');

      c.read(selectedDayProvider.notifier).previous(); // picked: the 14th
      now = DateTime(2026, 11, 16, 7);
      c.read(todayProvider.notifier).refresh();
      expect(c.read(selectedDayProvider), '2026-11-14');
    });

    test('set rejects text that is not a day', () {
      final c = container();
      expect(
        () => c.read(selectedDayProvider.notifier).set('morgen'),
        throwsArgumentError,
      );
    });
  });
}
