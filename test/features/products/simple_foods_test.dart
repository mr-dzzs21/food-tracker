import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/features/products/basic_foods.dart';
import 'package:food_tracker/features/products/basic_foods_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/features/products/simple_foods.dart';
import 'package:food_tracker/features/products/simple_foods_repository.dart';

/// A small file in the format of assets/data/simple_foods_*.tsv.
const _sample =
    '# comment line\n'
    'order\tkey\tname_de\tname_en\tsynonyms_de\tsynonyms_en\tkcal\tfat'
    '\tsaturated_fat\tcarbs\tsugars\tfibre\tprotein\tsalt\tliquid\tcategory'
    '\tportion_g\tportion_de\tportion_en\tbls_code\toff_products\n'
    '12\tbanane\tBanane\tBanana\tBananen\tbananas\t79\t0.2\t0.1\t18\t17'
    '\t2\t1.2\t0\t0\t\t120\t1 Banane\t1 banana\tF503100\t\n'
    '30\tskyr-vanille\tSkyr Vanille\tSkyr, vanilla\tVanilleskyr| Skyr \t'
    '\t75\t0.2\t0.1\t9.5\t9\t\t9.2\t0.1\t0\t\t150\t1 Portion\t1 serving'
    '\t\t23\r\n';

List<SimpleFood> _bundled() => [
  for (final asset in simpleFoodsAssets)
    ...parseSimpleFoods(File(asset).readAsStringSync()),
];

SimpleFood _food(String nameDe, {List<String> synonyms = const []}) =>
    SimpleFood(
      key: nameDe,
      nameDe: nameDe,
      nameEn: nameDe,
      synonymsDe: synonyms,
      nutrients: const Nutrients(kcal: 100),
    );

void main() {
  group('parseSimpleFoods', () {
    test('reads every column; empty values stay unknown', () {
      final [banana, skyr] = parseSimpleFoods(_sample);

      expect(banana.order, 12);
      expect(banana.key, 'banane');
      expect(banana.nameFor('de'), 'Banane');
      expect(banana.nameFor('en'), 'Banana');
      expect(banana.synonymsDe, ['Bananen']);
      expect(banana.nutrients.kcal, 79);
      expect(banana.nutrients.salt, 0);
      expect(banana.portionGrams, 120);
      expect(banana.portionFor('de'), '1 Banane');
      expect(banana.portionFor('en'), '1 banana');
      expect(banana.blsCode, 'F503100');
      expect(banana.offProductCount, isNull);
      // Stored in its own row (not the BLS food's), by the list key.
      expect(banana.source, FoodSource.simpleBls);
      expect(banana.externalId, 'banane');

      // Search words are trimmed; unknown fibre is null, never 0.
      expect(skyr.synonymsDe, ['Vanilleskyr', 'Skyr']);
      expect(skyr.synonymsEn, isEmpty);
      expect(skyr.nutrients.fibre, isNull);
      expect(skyr.blsCode, isNull);
      expect(skyr.offProductCount, 23);
      expect(skyr.source, FoodSource.offAverage);
      expect(skyr.externalId, 'skyr-vanille');
    });

    test('a broken file is an error, not a silent gap', () {
      expect(parseSimpleFoods(''), isEmpty);
      expect(
        () => parseSimpleFoods('key\tname_de\n'),
        throwsFormatException, // columns missing
      );
      expect(
        () => parseSimpleFoods(_sample.replaceFirst('\t79\t', '\t7,9\t')),
        throwsFormatException, // not a number
      );
      expect(
        () => parseSimpleFoods(_sample.replaceFirst('\tF503100\t', '\t')),
        throwsFormatException, // a column missing in one line
      );
    });
  });

  group('the bundled list', () {
    final foods = _bundled();
    final bls = {
      for (final food in parseBasicFoods(
        File(basicFoodsAsset).readAsStringSync(),
      ))
        food.code: food,
    };

    test('300 to 450 foods; keys, names and BLS codes are unique', () {
      expect(foods.length, inInclusiveRange(300, 450));
      Set<String> unique(Iterable<String> values) {
        final list = values.toList();
        final set = list.toSet();
        expect(set.length, list.length, reason: 'duplicates in $list');
        return set;
      }

      unique(foods.map((f) => f.key));
      unique(foods.map((f) => f.nameDe.toLowerCase()));
      unique(foods.map((f) => f.nameEn.toLowerCase()));
      unique(foods.map((f) => f.blsCode).nonNulls);
      unique(foods.map((f) => '${f.order}'));
    });

    test('plausible values: kcal 0–900, grams 0–100, saturated fat ≤ fat, '
        'sugars ≤ carbs', () {
      for (final food in foods) {
        final n = food.nutrients;
        final reason = food.key;
        expect(n.kcal, isNotNull, reason: reason);
        expect(n.kcal, inInclusiveRange(0, 900), reason: reason);
        for (final nutrient in Nutrient.values) {
          final value = n[nutrient];
          if (nutrient == Nutrient.kcal || value == null) continue;
          expect(value, inInclusiveRange(0, 100), reason: '$reason $nutrient');
        }
        if (n.fat != null && n.saturatedFat != null) {
          expect(n.saturatedFat, lessThanOrEqualTo(n.fat!), reason: reason);
        }
        if (n.carbs != null && n.sugars != null) {
          expect(n.sugars, lessThanOrEqualTo(n.carbs!), reason: reason);
        }
        expect(food.nameDe.trim(), isNotEmpty, reason: reason);
        expect(food.nameEn.trim(), isNotEmpty, reason: reason);
      }
    });

    test('every portion has grams and a name in both languages', () {
      for (final food in foods) {
        final grams = food.portionGrams;
        if (grams == null) continue;
        expect(grams, inExclusiveRange(0, 1000), reason: food.key);
        expect(food.portionFor('de'), isNotNull, reason: food.key);
        expect(food.portionFor('en'), isNotNull, reason: food.key);
      }
    });

    test('BLS rows have exactly the values of their BLS food', () {
      final fromBls = foods.where((f) => f.blsCode != null).toList();
      expect(fromBls.length, greaterThan(300));
      for (final food in fromBls) {
        final source = bls[food.blsCode];
        expect(source, isNotNull, reason: '${food.key}: ${food.blsCode}');
        expect(food.nutrients, source!.nutrients, reason: food.key);
        expect(food.category, source.category, reason: food.key);
      }
    });

    test('Open Food Facts averages name their product count', () {
      final averages = foods.where((f) => f.blsCode == null).toList();
      expect(averages, isNotEmpty);
      for (final food in averages) {
        expect(food.offProductCount, greaterThanOrEqualTo(5), reason: food.key);
        expect(food.source, FoodSource.offAverage);
      }
      expect(averages.map((f) => f.key), contains('skyr-vanille'));
    });

    test('drinks are drinks: water, cola, milk, beer, energy drink', () {
      final byKey = {for (final food in foods) food.key: food};
      for (final key in [
        'wasser',
        'cola',
        'milch-15',
        'bier',
        'energy-drink',
        'kefir',
      ]) {
        expect(byKey[key]?.isLiquid, isTrue, reason: key);
      }
      expect(byKey['skyr-natur']?.isLiquid, isFalse);
      // Kinds without a traffic light keep the BLS tag.
      expect(byKey['wasser']?.category, 'en:waters');
    });

    testWidgets('the app loads both files from the assets', (tester) async {
      // runAsync: real time, rootBundle decodes larger files in an isolate.
      final index = await tester.runAsync(loadBundledSimpleFoods);
      expect(index!.foods, hasLength(foods.length));
      // Sorted like the hand-written list, both files mixed.
      final orders = [for (final food in index.foods) food.order];
      expect(orders, [...orders]..sort());
    });
  });

  group('search ranking', () {
    test('plural forms, compound words, search words, umlauts', () {
      final index = SimpleFoodIndex([
        _food('Süßkartoffel'),
        _food('Kartoffelpüree'),
        _food('Kartoffeln gekocht'),
        _food('Nudeln gekocht', synonyms: ['Pasta', 'Spaghetti']),
        _food('Spaghetti Bolognese'),
        _food('Brötchen', synonyms: ['Semmel']),
      ]);
      List<String> names(String query) => [
        for (final food in index.search(query, languageCode: 'de')) food.nameDe,
      ];

      // "kartoffel" is the whole word "Kartoffeln"; the end of a compound
      // word comes next, the start of one last.
      expect(names('kartoffel'), [
        'Kartoffeln gekocht',
        'Süßkartoffel',
        'Kartoffelpüree',
      ]);
      expect(names('Kartoffeln').first, 'Kartoffeln gekocht');
      // The name counts more than a search word.
      expect(names('spaghetti'), ['Spaghetti Bolognese', 'Nudeln gekocht']);
      expect(names('pasta'), ['Nudeln gekocht']);
      expect(names('nudel'), ['Nudeln gekocht']);
      expect(names('BROTCHEN'), ['Brötchen']);
      expect(names('semmel'), ['Brötchen']);
      // Every word must match.
      expect(names('nudeln bolognese'), isEmpty);
      expect(names('spaghetti bolo'), ['Spaghetti Bolognese']);
      expect(names('  '), isEmpty);
    });

    test('equally good hits keep the order of the list', () {
      final index = SimpleFoodIndex([
        _food('Skyr Vanille'),
        _food('Skyr natur'),
      ]);
      expect(
        index.search('skyr', languageCode: 'de').first.nameDe,
        'Skyr Vanille',
      );
    });

    group('with the bundled list', () {
      final index = SimpleFoodIndex(_bundled());
      List<String> names(String query, {String language = 'de'}) => [
        for (final food in index.search(query, languageCode: language))
          food.nameFor(language),
      ];

      test('skyr: Skyr natur first, then the flavours', () {
        expect(names('skyr').take(3), [
          'Skyr natur',
          'Skyr Vanille',
          'Skyr Frucht',
        ]);
        expect(names('skyr vanille').first, 'Skyr Vanille');
        expect(names('skyr erdbeere').first, 'Skyr Frucht');
      });

      test('reis: cooked and raw rice before anything else', () {
        expect(names('reis').take(2), ['Reis gekocht', 'Reis roh']);
        expect(names('Reis gekocht').first, 'Reis gekocht');
        expect(names('basmati').first, 'Reis gekocht');
      });

      test('nudeln and pasta find the pasta itself first', () {
        expect(names('nudeln').take(2), ['Nudeln gekocht', 'Nudeln roh']);
        expect(names('pasta').take(2), ['Nudeln gekocht', 'Nudeln roh']);
        expect(names('spaghetti').first, 'Spaghetti Bolognese');
        expect(names('spaghetti'), contains('Nudeln gekocht'));
      });

      test('fladenbrot, kartoffel, hähnchen, cola', () {
        expect(names('fladenbrot').first, 'Fladenbrot');
        expect(names('kartoffel').first, 'Kartoffeln gekocht');
        expect(names('kartoffeln').take(2), [
          'Kartoffeln gekocht',
          'Kartoffeln roh',
        ]);
        expect(names('hähnchen').first, 'Hähnchenbrust roh');
        expect(names('hahnchen').first, 'Hähnchenbrust roh');
        expect(names('huhn').first, 'Hähnchenbrust roh');
        expect(names('cola').take(2), ['Cola', 'Cola Zero']);
        // "Rucola" is no compound word with "cola".
        expect(names('cola'), isNot(contains('Rucola')));
      });

      test('everyday words: brot, milch, joghurt, quark, ei, wasser', () {
        expect(names('brot').first, 'Vollkornbrot');
        expect(names('brötchen').first, 'Brötchen');
        expect(names('milch').first, 'Milch 1,5 %');
        expect(names('joghurt').first, 'Joghurt natur 1,5 %');
        expect(names('quark').first, 'Magerquark');
        expect(names('ei').first, 'Ei');
        expect(names('wasser').first, 'Wasser');
        expect(names('döner').first, 'Döner Kebab');
      });

      test('the English UI searches the English names (and the German)', () {
        expect(names('rice', language: 'en').take(2), [
          'Rice, cooked',
          'Rice, uncooked',
        ]);
        expect(names('skyr', language: 'en').first, 'Skyr, plain');
        expect(names('brötchen', language: 'en').first, 'Bread roll');
      });

      test('at most 10 hits', () {
        expect(names('a'), hasLength(SimpleFoodIndex.defaultLimit));
      });
    });
  });
}
