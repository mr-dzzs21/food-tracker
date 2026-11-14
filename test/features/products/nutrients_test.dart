import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/format.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/nutrients.dart';

void main() {
  group('Nutrients.scaled', () {
    test('per 100 g × amount / 100, unknown stays unknown', () {
      const per100 = Nutrients(kcal: 536, fat: 30, sugars: 50);
      final portion = per100.scaled(30);
      expect(portion.kcal, closeTo(160.8, 1e-9));
      expect(portion.fat, closeTo(9, 1e-9));
      expect(portion.sugars, closeTo(15, 1e-9));
      expect(portion.protein, isNull);
      expect(portion.salt, isNull);
    });

    test('brief vector N10: 30 g of 536 kcal/100 g shows 161 kcal', () {
      final kcal = const Nutrients(kcal: 536).scaled(30).kcal!;
      expect(formatKcal(kcal, 'de'), '161');
    });

    test('brief vector N11: 330 ml cola → 139 kcal, 35 g sugars', () {
      final drink = const Nutrients(kcal: 42, sugars: 10.6).scaled(330);
      expect(formatKcal(drink.kcal!, 'de'), '139');
      expect(formatGrams(drink.sugars!, 'de'), '35');
    });

    test('0 is a known value, not unknown', () {
      final scaled = const Nutrients(fat: 0).scaled(250);
      expect(scaled.fat, 0);
    });
  });

  test('Nutrients equality and index operator', () {
    const a = Nutrients(kcal: 1, salt: 0.5);
    expect(a, const Nutrients(kcal: 1, salt: 0.5));
    expect(a == const Nutrients(kcal: 1), isFalse);
    expect(a.hashCode, const Nutrients(kcal: 1, salt: 0.5).hashCode);
    expect(a[Nutrient.salt], 0.5);
    expect(a[Nutrient.fat], isNull);
  });

  group('NutrientTotals', () {
    test('brief vector N14: missing sugars make the total "at least"', () {
      final entries = [
        const Nutrients(kcal: 536, sugars: 50).scaled(30),
        const Nutrients(kcal: 250),
      ];
      final totals = NutrientTotals.sum(entries);
      expect(formatKcal(totals[Nutrient.kcal].value, 'de'), '411');
      expect(totals.stateOf(Nutrient.kcal), TotalState.complete);
      expect(totals[Nutrient.sugars].value, closeTo(15, 1e-9));
      expect(totals[Nutrient.sugars].missingCount, 1);
      expect(totals.stateOf(Nutrient.sugars), TotalState.partial);
    });

    test('nothing known gives "unknown"', () {
      final totals = NutrientTotals.sum([
        const Nutrients(kcal: 100),
        const Nutrients(kcal: 50),
      ]);
      expect(totals.stateOf(Nutrient.fibre), TotalState.unknown);
      expect(totals[Nutrient.fibre].value, 0);
      expect(totals[Nutrient.fibre].missingCount, 2);
    });

    test('an empty day is complete with 0', () {
      final totals = NutrientTotals.sum(const []);
      expect(totals.entryCount, 0);
      for (final nutrient in Nutrient.values) {
        expect(totals[nutrient].value, 0);
        expect(totals.stateOf(nutrient), TotalState.complete);
      }
    });
  });

  group('extensions on database rows', () {
    final createdAt = DateTime(2026, 11, 14, 8);

    test('Food.nutrients copies the eight columns', () {
      final food = Food(
        id: 1,
        source: FoodSource.user,
        name: 'Haferflocken',
        isLiquid: false,
        isFavourite: false,
        createdAt: createdAt,
        kcal: 372,
        fat: 7,
        saturatedFat: 1.3,
        carbs: 58.7,
        sugars: 0.7,
        fibre: 10,
        protein: 13.5,
        salt: 0.03,
      );
      expect(
        food.nutrients,
        const Nutrients(
          kcal: 372,
          fat: 7,
          saturatedFat: 1.3,
          carbs: 58.7,
          sugars: 0.7,
          fibre: 10,
          protein: 13.5,
          salt: 0.03,
        ),
      );
    });

    test('DiaryEntry.nutrients scales the snapshot to the amount', () {
      final entry = DiaryEntry(
        id: 1,
        day: '2026-11-14',
        mealSlotId: 1,
        name: 'Haferflocken',
        amount: 60,
        isLiquid: false,
        createdAt: createdAt,
        kcal: 372,
        protein: 13.5,
      );
      expect(entry.nutrientsPer100.kcal, 372);
      expect(entry.nutrients.kcal, closeTo(223.2, 1e-9));
      expect(entry.nutrients.protein, closeTo(8.1, 1e-9));
      expect(entry.nutrients.fat, isNull);
    });
  });
}
