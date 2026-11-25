import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/health_rating.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/features/products/off_product_mapper.dart';

import '../../helpers/off_fixtures.dart';

const low = Level.low;
const medium = Level.medium;
const high = Level.high;

const food = ['en:snacks'];
const drink = ['en:beverages'];

/// Expected plus points as (nutrient, strength).
typedef Plus = (PlusPointNutrient, PlusPointStrength);
const highFibre = (PlusPointNutrient.fibre, PlusPointStrength.high);
const fibreSource = (PlusPointNutrient.fibre, PlusPointStrength.source);
const highProtein = (PlusPointNutrient.protein, PlusPointStrength.high);
const proteinSource = (PlusPointNutrient.protein, PlusPointStrength.source);

/// A rated vector: basis, levels (fat, saturates, sugars, salt), plus points.
typedef RatedVector = (
  String name,
  List<String> categories,
  Nutrients nutrients,
  RatingBasis basis,
  List<Level?> levels,
  List<Plus> plus,
);

/// A not-rated vector: the category that excluded it (null = no category).
typedef NotRatedVector = (
  String name,
  List<String> categories,
  Nutrients nutrients,
  String? category,
);

RatingResult rateOff(List<String> categories, Nutrients nutrients) =>
    rateProduct(
      nutrients: nutrients,
      categories: categories,
      source: FoodSource.openFoodFacts,
      isLiquid: false,
    );

List<Level?> levelsOf(Rated rated) => [
  for (final nutrient in RatedNutrient.values) rated.levels[nutrient],
];

void main() {
  // Every vector of .notes/research/health-nutrition.md, table M(1),
  // ported 1:1. "saturates" there is saturatedFat here.
  final ratedVectors = <RatedVector>[
    (
      'R1 food exactly on LOW bounds',
      food,
      const Nutrients(fat: 3.0, saturatedFat: 1.5, sugars: 5.0, salt: 0.3),
      RatingBasis.food,
      [low, low, low, low],
      [],
    ),
    (
      'R2 food just above LOW',
      food,
      const Nutrients(fat: 3.01, saturatedFat: 1.51, sugars: 5.01, salt: 0.31),
      RatingBasis.food,
      [medium, medium, medium, medium],
      [],
    ),
    (
      'R3 food exactly on HIGH bounds',
      food,
      const Nutrients(fat: 17.5, saturatedFat: 5.0, sugars: 22.5, salt: 1.5),
      RatingBasis.food,
      [medium, medium, medium, medium],
      [],
    ),
    (
      'R4 food just above HIGH',
      food,
      const Nutrients(
        fat: 17.51,
        saturatedFat: 5.01,
        sugars: 22.51,
        salt: 1.51,
      ),
      RatingBasis.food,
      [high, high, high, high],
      [],
    ),
    (
      'R5 drink exactly on LOW bounds',
      drink,
      const Nutrients(fat: 1.5, saturatedFat: 0.75, sugars: 2.5, salt: 0.3),
      RatingBasis.drink,
      [low, low, low, low],
      [],
    ),
    (
      'R6 drink exactly on HIGH bounds',
      drink,
      const Nutrients(fat: 8.75, saturatedFat: 2.5, sugars: 11.25, salt: 0.75),
      RatingBasis.drink,
      [medium, medium, medium, medium],
      [],
    ),
    (
      'R7 drink just above HIGH',
      drink,
      const Nutrients(fat: 8.76, saturatedFat: 2.51, sugars: 11.26, salt: 0.76),
      RatingBasis.drink,
      [high, high, high, high],
      [],
    ),
    (
      'R8 cola-like drink',
      drink,
      const Nutrients(
        kcal: 42,
        fat: 0,
        saturatedFat: 0,
        sugars: 10.6,
        salt: 0.02,
      ),
      RatingBasis.drink,
      [low, low, medium, low],
      [],
    ),
    (
      'R9 same 10.6 g sugar as food',
      food,
      const Nutrients(
        kcal: 42,
        fat: 0,
        saturatedFat: 0,
        sugars: 10.6,
        salt: 0.02,
      ),
      RatingBasis.food,
      [low, low, medium, low],
      [],
    ),
    (
      'R10 salt only via sodium 0.12 g',
      food,
      // The mapper computes salt = sodium × 2.5 (= 0.30000000000000004).
      const Nutrients(fat: 1, saturatedFat: 0.2, sugars: 1, salt: 0.12 * 2.5),
      RatingBasis.food,
      [low, low, low, low],
      [],
    ),
    (
      'R11 saturates missing, fat 120 invalid',
      food,
      const Nutrients(fat: 120, sugars: 2, salt: 0.1),
      RatingBasis.food,
      [null, null, low, low],
      [],
    ),
    (
      'R12 oat flakes',
      food,
      const Nutrients(
        kcal: 372,
        fat: 7.0,
        saturatedFat: 1.3,
        sugars: 1.0,
        salt: 0.01,
        fibre: 10.0,
        protein: 13.5,
      ),
      RatingBasis.food,
      [medium, low, low, low],
      [highFibre, proteinSource],
    ),
    (
      'R13 fibre via 100 kcal rule',
      food,
      const Nutrients(
        kcal: 50,
        fat: 0.2,
        saturatedFat: 0.0,
        sugars: 3.0,
        salt: 0.05,
        fibre: 1.0,
        protein: 1.0,
      ),
      RatingBasis.food,
      [low, low, low, low],
      [fibreSource],
    ),
    (
      'R14 chicken breast',
      food,
      const Nutrients(
        kcal: 110,
        fat: 1.5,
        saturatedFat: 0.4,
        sugars: 0.0,
        salt: 0.12,
        fibre: 0.0,
        protein: 23.0,
      ),
      RatingBasis.food,
      [low, low, low, low],
      [highProtein],
    ),
    (
      'R15 protein share exactly 12 %',
      food,
      const Nutrients(
        kcal: 100,
        fat: 5,
        saturatedFat: 1,
        sugars: 6,
        salt: 0.5,
        protein: 3.0,
      ),
      RatingBasis.food,
      [medium, low, medium, medium],
      [proteinSource],
    ),
    (
      'R15b protein share exactly 20 % (float trap 19.999..)',
      food,
      const Nutrients(
        kcal: 82,
        fat: 1,
        saturatedFat: 0.5,
        sugars: 1,
        salt: 0.2,
        protein: 4.1,
      ),
      RatingBasis.food,
      [low, low, low, low],
      [highProtein],
    ),
    (
      'R16 fibre exactly 3 g and 6 g',
      food,
      const Nutrients(
        kcal: 400,
        fat: 4,
        saturatedFat: 1,
        sugars: 4,
        salt: 0.4,
        fibre: 3.0,
      ),
      RatingBasis.food,
      [medium, low, low, medium],
      [fibreSource],
    ),
    (
      'R18 flavoured water with sugar',
      ['en:beverages', 'en:waters', 'en:flavored-waters'],
      const Nutrients(fat: 0, saturatedFat: 0, sugars: 4.5, salt: 0.0),
      RatingBasis.drink,
      [low, low, medium, low],
      [],
    ),
    (
      'R21 white sugar (en:sweeteners is NOT excluded)',
      ['en:sweeteners', 'en:sugars'],
      const Nutrients(fat: 0, saturatedFat: 0, sugars: 100, salt: 0),
      RatingBasis.food,
      [low, low, high, low],
      [],
    ),
    (
      'R24 iced coffee drink',
      ['en:beverages', 'en:coffees', 'en:coffee-drinks'],
      const Nutrients(fat: 1.6, saturatedFat: 1.0, sugars: 8.0, salt: 0.1),
      RatingBasis.drink,
      [medium, medium, medium, low],
      [],
    ),
    (
      'R26 salt delivered as 0.30000000000000004',
      food,
      const Nutrients(fat: 1, saturatedFat: 0.1, sugars: 1, salt: 0.1 * 3),
      RatingBasis.food,
      [low, low, low, low],
      [],
    ),
  ];

  final notRatedVectors = <NotRatedVector>[
    (
      'R17 spring water',
      ['en:beverages', 'en:waters', 'en:spring-waters'],
      const Nutrients(fat: 0, saturatedFat: 0, sugars: 0, salt: 0.01),
      'en:waters',
    ),
    (
      'R19 beer',
      ['en:beverages', 'en:alcoholic-beverages', 'en:beers'],
      const Nutrients(sugars: 0.3),
      'en:alcoholic-beverages',
    ),
    (
      'R20 baby food',
      ['en:baby-foods'],
      const Nutrients(sugars: 8),
      'en:baby-foods',
    ),
    (
      'R22 tabletop sweetener',
      ['en:sweeteners', 'en:sugar-substitutes', 'en:food-additives'],
      const Nutrients(sugars: 90),
      'en:sugar-substitutes',
    ),
    (
      'R23 coffee beans',
      ['en:plant-based-foods', 'en:coffees', 'en:coffee-beans'],
      const Nutrients(fat: 0.5),
      'en:coffees',
    ),
    ('R25 no categories', [], const Nutrients(fat: 10), null),
  ];

  group('brief vectors M(1)', () {
    for (final (name, categories, nutrients, basis, levels, plus)
        in ratedVectors) {
      test(name, () {
        final result = rateOff(categories, nutrients);
        expect(result, isA<Rated>());
        final rated = result as Rated;
        expect(rated.basis, basis);
        expect(levelsOf(rated), levels);
        expect([
          for (final point in rated.plusPoints)
            (point.nutrient, point.strength),
        ], plus);
        // Only R11 holds an impossible value (fat 120 g per 100 g).
        expect(rated.suspicious, name.startsWith('R11'));
      });
    }

    for (final (name, categories, nutrients, category) in notRatedVectors) {
      test(name, () {
        final result = rateOff(categories, nutrients);
        expect(result, isA<NotRated>());
        final notRated = result as NotRated;
        expect(notRated.category, category);
        expect(
          notRated.reason,
          category == null
              ? NotRatedReason.unknownType
              : NotRatedReason.excludedType,
        );
      });
    }

    test('all 27 vectors are covered', () {
      expect(ratedVectors.length + notRatedVectors.length, 27);
    });
  });

  group('levelFor (Dart threshold snippet of the brief)', () {
    test('boundaries are inclusive and float noise is ignored', () {
      final fat = foodBounds[RatedNutrient.fat]!;
      final sugars = foodBounds[RatedNutrient.sugars]!;
      final drinkSugars = drinkBounds[RatedNutrient.sugars]!;
      final salt = foodBounds[RatedNutrient.salt]!;
      expect(levelFor(3.0, fat), low);
      expect(levelFor(3.01, fat), medium);
      expect(levelFor(22.5, sugars), medium);
      expect(levelFor(22.51, sugars), high);
      expect(levelFor(11.25, drinkSugars), medium);
      expect(levelFor(11.26, drinkSugars), high);
      expect(levelFor(0.1 * 3, salt), low);
      expect(levelFor(0.12 * 2.5, salt), low);
    });

    test('missing or impossible is "no data", never LOW', () {
      final fat = foodBounds[RatedNutrient.fat]!;
      expect(levelFor(null, fat), isNull);
      expect(levelFor(120, fat), isNull);
      expect(levelFor(-1, fat), isNull);
      expect(levelFor(double.nan, fat), isNull);
      expect(levelFor(0, fat), low); // 0 is a real value
    });
  });

  group('categories', () {
    test('powder to be rehydrated is not rated', () {
      final result = rateOff([
        'en:beverages',
        'en:tea-based-beverages',
        'en:dried-products-to-be-rehydrated',
      ], const Nutrients(sugars: 90));
      expect(result, isA<NotRated>());
      expect(
        (result as NotRated).category,
        'en:dried-products-to-be-rehydrated',
      );
    });

    test('honey (en:sweeteners) is rated', () {
      final result = rateOff([
        'en:sweeteners',
        'en:honeys',
      ], const Nutrients(sugars: 82));
      expect(result, isA<Rated>());
    });

    test('a liquid OFF product without en:beverages uses food limits', () {
      // Plain milk is not tagged en:beverages (brief, risks section).
      final result = rateProduct(
        nutrients: const Nutrients(sugars: 4.8),
        categories: const ['en:dairies', 'en:milks'],
        source: FoodSource.openFoodFacts,
        isLiquid: true,
      );
      expect((result as Rated).basis, RatingBasis.food);
      expect(result.levels[RatedNutrient.sugars], low);
    });

    test('nothing known: rated, but every level is "no data"', () {
      final result = rateOff(food, Nutrients.unknown) as Rated;
      expect(levelsOf(result), [null, null, null, null]);
      expect(result.plusPoints, isEmpty);
      expect(result.suspicious, isFalse);
    });
  });

  group('own foods', () {
    RatingResult rateOwn(Nutrients nutrients, {required bool isLiquid}) =>
        rateProduct(
          nutrients: nutrients,
          categories: const [],
          source: FoodSource.user,
          isLiquid: isLiquid,
        );

    test('no category needed: food limits for solids', () {
      final result = rateOwn(const Nutrients(sugars: 4), isLiquid: false);
      expect((result as Rated).basis, RatingBasis.food);
      expect(result.levels[RatedNutrient.sugars], low);
    });

    test('drink limits when the own food is a drink', () {
      final result = rateOwn(const Nutrients(sugars: 4), isLiquid: true);
      expect((result as Rated).basis, RatingBasis.drink);
      expect(result.levels[RatedNutrient.sugars], medium);
    });

    test('rateFood reads a stored row', () {
      Food row({required FoodSource source, String? categories}) => Food(
        id: 1,
        source: source,
        name: 'Test',
        isLiquid: false,
        isFavourite: false,
        createdAt: DateTime(2026, 11, 14),
        categories: categories,
        fat: 20,
      );
      final own = rateFood(row(source: FoodSource.user)) as Rated;
      expect(own.levels[RatedNutrient.fat], high);

      final off = rateFood(
        row(
          source: FoodSource.openFoodFacts,
          categories: 'en:beverages,en:waters',
        ),
      );
      expect((off as NotRated).category, 'en:waters');

      final noCategory = rateFood(row(source: FoodSource.openFoodFacts));
      expect((noCategory as NotRated).reason, NotRatedReason.unknownType);
    });
  });

  group('basic foods (BLS)', () {
    RatingResult rateBls(
      Nutrients nutrients, {
      required bool isLiquid,
      List<String> categories = const [],
    }) => rateProduct(
      nutrients: nutrients,
      categories: categories,
      source: FoodSource.bls,
      isLiquid: isLiquid,
    );

    test('no category: food limits, not "unknown type"', () {
      final result = rateBls(const Nutrients(sugars: 4), isLiquid: false);
      expect((result as Rated).basis, RatingBasis.food);
      expect(result.levels[RatedNutrient.sugars], low);
    });

    test('drinks use the drink limits', () {
      // Orange juice: 8.6 g sugars per 100 ml.
      final result = rateBls(const Nutrients(sugars: 8.6), isLiquid: true);
      expect((result as Rated).basis, RatingBasis.drink);
      expect(result.levels[RatedNutrient.sugars], medium);
    });

    test('kinds without a traffic light carry their category', () {
      for (final category in [
        'en:waters',
        'en:coffees',
        'en:teas',
        'en:herbal-teas',
        'en:alcoholic-beverages',
        'en:spices',
        'en:salts',
        'en:sugar-substitutes',
        'en:dried-products-to-be-rehydrated',
      ]) {
        final result = rateBls(
          const Nutrients(salt: 99),
          isLiquid: false,
          categories: [category],
        );
        expect(
          result,
          isA<NotRated>()
              .having((r) => r.reason, 'reason', NotRatedReason.excludedType)
              .having((r) => r.category, 'category', category),
        );
      }
    });

    test('rateFood reads a stored BLS row', () {
      final food = Food(
        id: 1,
        source: FoodSource.bls,
        externalId: 'B782100',
        name: 'Weizenfladenbrot',
        isLiquid: false,
        isFavourite: false,
        createdAt: DateTime(2026, 11, 14),
        salt: 1.26,
      );
      expect((rateFood(food) as Rated).levels[RatedNutrient.salt], medium);
    });
  });

  test('Open Food Facts averages are rated like basic foods', () {
    // Energy drink: 11 g sugars per 100 ml, no categories – drink limits
    // (high only above 11.25 g).
    final drink = rateProduct(
      nutrients: const Nutrients(sugars: 11),
      categories: const [],
      source: FoodSource.offAverage,
      isLiquid: true,
    );
    expect((drink as Rated).basis, RatingBasis.drink);
    expect(drink.levels[RatedNutrient.sugars], medium);

    final bar = rateProduct(
      nutrients: const Nutrients(sugars: 3.4),
      categories: const [],
      source: FoodSource.offAverage,
      isLiquid: false,
    );
    expect((bar as Rated).basis, RatingBasis.food);
    expect(bar.levels[RatedNutrient.sugars], low);
  });

  group('plus points', () {
    test('fibre exactly 6 g is high; the value is kept for the text', () {
      final points = plusPointsFor(const Nutrients(kcal: 400, fibre: 6.0));
      expect(points, [
        const PlusPoint(PlusPointNutrient.fibre, PlusPointStrength.high, 6.0),
      ]);
    });

    test('0 kcal: no protein point and no division by zero', () {
      final points = plusPointsFor(const Nutrients(kcal: 0, protein: 5));
      expect(points, isEmpty);
    });

    test('fibre counts even without kcal (per 100 g rule)', () {
      final points = plusPointsFor(const Nutrients(fibre: 3));
      expect(points.single.strength, PlusPointStrength.source);
    });
  });

  group('suspicious values (R6)', () {
    test('brief vector N15: kcal plausibility', () {
      const label = Nutrients(fat: 30, carbs: 50, protein: 7, fibre: 3);
      // computed 504 kcal: 536 is 6.3 % off (fine), 150 is 70 % off.
      expect(
        hasSuspiciousValues(
          const Nutrients(kcal: 536, fat: 30, carbs: 50, protein: 7, fibre: 3),
        ),
        isFalse,
      );
      expect(
        hasSuspiciousValues(
          const Nutrients(kcal: 150, fat: 30, carbs: 50, protein: 7, fibre: 3),
        ),
        isTrue,
      );
      expect(hasSuspiciousValues(label), isFalse); // no kcal → no check
    });

    test('saturates above fat, sugars above carbs', () {
      expect(
        hasSuspiciousValues(const Nutrients(fat: 2, saturatedFat: 2.1)),
        isFalse, // within the 0.1 g tolerance
      );
      expect(
        hasSuspiciousValues(const Nutrients(fat: 2, saturatedFat: 2.2)),
        isTrue,
      );
      expect(
        hasSuspiciousValues(const Nutrients(carbs: 10, sugars: 12)),
        isTrue,
      );
    });

    test('more than 105 g per 100 g in total', () {
      expect(
        hasSuspiciousValues(const Nutrients(fat: 60, carbs: 40, protein: 6)),
        isTrue,
      );
      expect(
        hasSuspiciousValues(const Nutrients(fat: 60, carbs: 40, protein: 5)),
        isFalse,
      );
    });

    test('impossible kcal', () {
      expect(hasSuspiciousValues(const Nutrients(kcal: 1200)), isTrue);
    });
  });

  group('recorded products', () {
    Rated rateFixture(String name) {
      final product = parseOffProduct(fixtureProduct(name), languageCode: 'de');
      return rateProduct(
        nutrients: product.nutrients,
        categories: product.categories,
        source: FoodSource.openFoodFacts,
        isLiquid: product.isLiquid,
      ) as Rated;
    }

    test('crisps: high fat, source of fibre', () {
      final rated = rateFixture('crisps.json');
      expect(rated.basis, RatingBasis.food);
      expect(levelsOf(rated), [high, medium, low, medium]);
      expect(rated.plusPoints.single.nutrient, PlusPointNutrient.fibre);
      expect(rated.plusPoints.single.strength, PlusPointStrength.source);
      expect(rated.suspicious, isFalse);
    });

    test('cola: drink limits', () {
      final rated = rateFixture('soft_drink.json');
      expect(rated.basis, RatingBasis.drink);
      expect(levelsOf(rated), [low, low, medium, low]);
    });

    test('salt from sodium through the mapper (R10)', () {
      final product = parseOffProduct({
        'categories_tags': food,
        'nutriments': {
          'fat_100g': 1,
          'saturated-fat_100g': 0.2,
          'sugars_100g': 1,
          'sodium_100g': 0.12,
        },
      }, languageCode: 'de');
      final rated = rateOff(product.categories, product.nutrients) as Rated;
      expect(rated.levels[RatedNutrient.salt], low);
    });
  });
}
