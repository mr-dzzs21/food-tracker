import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';

import '../../helpers/pump_app.dart';

// The meal-slot methods of DiaryRepository (settings page "Mahlzeiten").

void main() {
  late AppDatabase db;
  late DiaryRepository repo;

  setUp(() {
    db = newTestDatabase();
    repo = DiaryRepository(db, Clock.fixed(testNow));
  });

  tearDown(() => db.close());

  Future<List<MealSlot>> slots() => repo.watchMealSlots().first;

  Future<MealSlot> slot(String builtIn) async =>
      (await slots()).firstWhere((s) => s.builtIn == builtIn);

  Future<void> logInto(MealSlot slot) async {
    final food = await db
        .into(db.foods)
        .insertReturning(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: 'Apfel',
            createdAt: testNow,
          ),
        );
    await repo.addEntry(
      food: food,
      amount: 150,
      day: '2026-11-01',
      mealSlotId: slot.id,
    );
  }

  test('addMealSlot puts the new meal at the end, name trimmed', () async {
    final id = await repo.addMealSlot(name: '  Spätsnack ', startMinute: 1320);
    final all = await slots();
    expect(all.last.id, id);
    expect(all.last.customName, 'Spätsnack');
    expect(all.last.builtIn, isNull);
    expect(all.last.position, 4);
    expect(all.last.startMinute, 1320);
    expect(() => repo.addMealSlot(name: '  '), throwsArgumentError);
    expect(
      () => repo.addMealSlot(name: 'x', startMinute: 1440),
      throwsArgumentError,
    );
  });

  test('updateMealSlot: empty name brings back the default name', () async {
    final breakfast = await slot('breakfast');
    await repo.updateMealSlot(
      breakfast.id,
      customName: ' Morgens ',
      startMinute: 300,
    );
    var updated = await slot('breakfast');
    expect(updated.customName, 'Morgens');
    expect(updated.startMinute, 300);

    await repo.updateMealSlot(breakfast.id, customName: '', startMinute: null);
    updated = await slot('breakfast');
    expect(updated.customName, isNull);
    expect(updated.startMinute, isNull);
  });

  test('the last visible meal cannot be hidden', () async {
    final all = await slots();
    for (final s in all.skip(1)) {
      expect(await repo.setMealSlotHidden(s.id, hidden: true), isTrue);
    }
    expect(await repo.setMealSlotHidden(all.first.id, hidden: true), isFalse);
    expect((await slots()).first.isHidden, isFalse);
    // Showing again is always allowed.
    expect(await repo.setMealSlotHidden(all[1].id, hidden: false), isTrue);
    expect(await repo.setMealSlotHidden(all.first.id, hidden: true), isTrue);
  });

  test('a meal with diary entries cannot be deleted', () async {
    final lunch = await slot('lunch');
    await logInto(lunch);
    expect(await repo.mealSlotHasEntries(lunch.id), isTrue);
    expect(
      await repo.deleteMealSlot(lunch.id),
      MealSlotDeleteResult.hasEntries,
    );
    expect((await slots()).map((s) => s.id), contains(lunch.id));
  });

  test('a meal without entries is deleted', () async {
    final snacks = await slot('snacks');
    expect(await repo.mealSlotHasEntries(snacks.id), isFalse);
    expect(await repo.deleteMealSlot(snacks.id), MealSlotDeleteResult.deleted);
    expect((await slots()).map((s) => s.builtIn), isNot(contains('snacks')));
  });

  test('the last visible meal cannot be deleted', () async {
    final all = await slots();
    for (final s in all.skip(1)) {
      await repo.setMealSlotHidden(s.id, hidden: true);
    }
    expect(
      await repo.deleteMealSlot(all.first.id),
      MealSlotDeleteResult.lastVisible,
    );
    // A hidden meal can go.
    expect(
      await repo.deleteMealSlot(all.last.id),
      MealSlotDeleteResult.deleted,
    );
  });

  test('reorderMealSlots stores the new positions', () async {
    final ids = [for (final s in await slots()) s.id];
    await repo.reorderMealSlots(ids.reversed.toList());
    final reordered = await slots();
    expect(reordered.map((s) => s.id), ids.reversed);
    expect(reordered.map((s) => s.position), [0, 1, 2, 3]);
  });
}
