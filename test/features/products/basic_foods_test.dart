import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/features/products/basic_foods.dart';
import 'package:food_tracker/features/products/basic_foods_repository.dart';
import 'package:food_tracker/features/products/nutrients.dart';

/// A small file in the format of assets/data/bls_4_0.tsv.
const _sample =
    '# comment line\n'
    'code\tname_de\tname_en\tkcal\tfat\tsaturated_fat\tcarbs\tsugars\tfibre'
    '\tprotein\tsalt\tliquid\tcategory\n'
    'B782100\tWeizenfladenbrot\tWheat flatbread\t248\t2.3\t0.2\t47\t0.3\t3.3'
    '\t8.2\t1.26\t0\t\n'
    'N110000\tTrinkwasser\tDrinking water\t0\t0\t0\t0\t0\t0\t0\t0.01\t1'
    '\ten:waters\r\n'
    'R172000\tGlutamat\tMonosodium glutamate\t0\t\t\t0\t0\t\t0\t34\t0'
    '\ten:food-additives\n';

BasicFood _food(String nameDe, {String? nameEn}) => BasicFood(
  code: nameDe,
  nameDe: nameDe,
  nameEn: nameEn ?? nameDe,
  nutrients: const Nutrients(kcal: 100),
);

void main() {
  group('parseBasicFoods', () {
    test('reads every column; empty values stay unknown', () {
      final foods = parseBasicFoods(_sample);
      expect(foods, hasLength(3));

      final [bread, water, glutamate] = foods;
      expect(bread.code, 'B782100');
      expect(bread.nameDe, 'Weizenfladenbrot');
      expect(bread.nameEn, 'Wheat flatbread');
      expect(
        bread.nutrients,
        const Nutrients(
          kcal: 248,
          fat: 2.3,
          saturatedFat: 0.2,
          carbs: 47,
          sugars: 0.3,
          fibre: 3.3,
          protein: 8.2,
          salt: 1.26,
        ),
      );
      expect(bread.isLiquid, isFalse);
      expect(bread.category, isNull);
      expect(bread.nameFor('de'), 'Weizenfladenbrot');
      expect(bread.nameFor('en'), 'Wheat flatbread');

      // Windows line end, drink, category.
      expect(water.isLiquid, isTrue);
      expect(water.category, 'en:waters');
      expect(water.nutrients.salt, 0.01);

      // Unknown is null, never 0.
      expect(glutamate.nutrients.fat, isNull);
      expect(glutamate.nutrients.saturatedFat, isNull);
      expect(glutamate.nutrients.fibre, isNull);
      expect(glutamate.nutrients.carbs, 0);
    });

    test('a broken file is an error, not a silent gap', () {
      expect(parseBasicFoods(''), isEmpty);
      expect(
        () => parseBasicFoods('code\tname_de\n'),
        throwsFormatException, // columns missing
      );
      expect(
        () => parseBasicFoods(_sample.replaceFirst('\t248\t', '\t2,48\t')),
        throwsFormatException, // not a number
      );
      expect(
        () => parseBasicFoods(_sample.replaceFirst('\t0.01\t1', '\t0.01')),
        throwsFormatException, // a column missing in one line
      );
    });
  });

  group('the bundled file (BLS 4.0)', () {
    // `flutter test` runs in the project folder.
    final foods = parseBasicFoods(File(basicFoodsAsset).readAsStringSync());
    final byCode = {for (final food in foods) food.code: food};

    test('7,140 foods, unique codes, all with kcal and both names', () {
      expect(foods, hasLength(7140));
      expect(byCode, hasLength(7140));
      for (final food in foods) {
        expect(food.code, matches(RegExp(r'^[A-Z][0-9A-Z]{6}$')));
        expect(food.nameDe, isNotEmpty);
        expect(food.nameEn, isNotEmpty);
        expect(food.nutrients.kcal, isNotNull, reason: food.code);
        for (final nutrient in Nutrient.values) {
          final value = food.nutrients[nutrient];
          if (value == null) continue;
          final max = nutrient == Nutrient.kcal ? 900 : 100;
          expect(value, inInclusiveRange(0, max), reason: food.code);
        }
      }
    });

    testWidgets('the app loads it from the assets in a background isolate', (
      tester,
    ) async {
      // runAsync: real time, so the isolate can finish (widget tests use
      // fake time otherwise).
      final index = await tester.runAsync(loadBundledBasicFoods);
      expect(index!.foods, hasLength(7140));
      expect(
        index.search('fladenbrot', languageCode: 'de').first.nameDe,
        'Weizenfladenbrot',
      );
    });

    test('drinks and kinds without a traffic light (tool/bls/README.md)', () {
      BasicFood food(String code) => byCode[code]!;
      expect(food('B782100').nameDe, 'Weizenfladenbrot');
      expect(food('B782100').nutrients.kcal, 248);
      expect(food('B782100').isLiquid, isFalse);

      expect(food('N110000').isLiquid, isTrue); // Trinkwasser
      expect(food('N110000').category, 'en:waters');
      expect(food('F603600').isLiquid, isTrue); // Orangensaft
      expect(food('F603600').category, isNull);
      expect(food('M111300').isLiquid, isTrue); // Vollmilch
      expect(food('P163000').category, 'en:alcoholic-beverages'); // Pils
      expect(food('P163100').category, isNull); // Pils alkoholfrei
      expect(food('N420900').isLiquid, isFalse); // Instantkaffeepulver
      expect(food('N420900').category, 'en:coffees');
      expect(food('R111000').category, 'en:salts'); // Speisesalz
    });
  });

  group('search ranking', () {
    List<String> names(
      BasicFoodIndex index,
      String query, {
      String languageCode = 'de',
      int limit = BasicFoodIndex.defaultLimit,
    }) => [
      for (final food in index.search(
        query,
        languageCode: languageCode,
        limit: limit,
      ))
        food.nameFor(languageCode),
    ];

    test('the rules on a few names', () {
      final index = BasicFoodIndex([
        _food('Schwein Vordereisbein, roh'),
        _food('Paprika gefüllt mit Reis'),
        _food('Reisdrink'),
        _food('Milchreis gekocht'),
        _food('Reis poliert, gekocht'),
        _food('Reis poliert, roh'),
        _food('Apfel-Reis-Auflauf'),
      ]);
      expect(names(index, 'reis'), [
        'Reis poliert, roh', // whole word, first, raw
        'Reis poliert, gekocht', // whole word, first
        'Milchreis gekocht', // end of a compound: it is rice
        'Reisdrink', // start of a word
        // Before a hyphen it only describes the Auflauf: counts like the
        // start of a word (then the shorter name wins).
        'Apfel-Reis-Auflauf',
        'Paprika gefüllt mit Reis', // after "mit": an ingredient
        'Schwein Vordereisbein, roh', // only inside a word
      ]);
    });

    test('every query word must match; case and umlauts do not matter', () {
      final index = BasicFoodIndex([
        _food('Karotte/Möhre, roh'),
        _food('Weizenbrot/Weißbrot'),
        _food('Reis poliert, gekocht'),
        _food('Reis poliert, roh'),
      ]);
      expect(names(index, 'reis gekocht'), ['Reis poliert, gekocht']);
      expect(names(index, 'MOHRE'), ['Karotte/Möhre, roh']);
      expect(names(index, 'möhre'), ['Karotte/Möhre, roh']);
      expect(names(index, 'weissbrot'), ['Weizenbrot/Weißbrot']);
      expect(names(index, 'weißbrot'), ['Weizenbrot/Weißbrot']);
      expect(names(index, ''), isEmpty);
      expect(names(index, ' , '), isEmpty);
      expect(names(index, 'pizza'), isEmpty);
    });

    group('with the bundled file', () {
      final index = BasicFoodIndex(
        parseBasicFoods(File(basicFoodsAsset).readAsStringSync()),
      );

      test('reis: raw rice first, "Vordereisbein" far behind', () {
        final all = names(index, 'reis', limit: 1000);
        expect(all.take(3), [
          'Reis poliert, roh',
          'Reis unpoliert, roh',
          'Reis parboiled, poliert, roh',
        ]);
        expect(names(index, 'reis'), contains('Reis gekocht'));
        // Only "reis" inside a word: after every food with a word that
        // starts or ends with it.
        expect(
          all.indexOf('Schwein Vordereisbein/Vorderhaxe, roh'),
          greaterThan(all.indexOf('Reisnudeln roh')),
        );
        expect(names(index, 'reis'), isNot(contains(startsWith('Schwein'))));
      });

      test('fladenbrot finds Weizenfladenbrot first', () {
        expect(names(index, 'fladenbrot').first, 'Weizenfladenbrot');
        expect(names(index, 'Fladenbrot').first, 'Weizenfladenbrot');
      });

      test('apfel: the raw apple first, cakes with apple later', () {
        final result = names(index, 'apfel');
        expect(result.take(2), ['Apfel roh', 'Apfel geschält, roh']);
        expect(result, contains('Apfel getrocknet'));
        expect(result, isNot(contains(startsWith('Apfel-Streuselkuchen'))));
      });

      test('milch: milk itself, including Vollmilch, before milk products', () {
        final result = index.search('milch', languageCode: 'de');
        expect(result.take(8).every((food) => food.isLiquid), isTrue);
        expect(result.first.nameDe, startsWith('Milch'));
        final resultNames = [for (final food in result) food.nameDe];
        expect(
          resultNames,
          contains('Vollmilch frisch, 3,5 % Fett, pasteurisiert'),
        );
        expect(resultNames, isNot(contains('Milchschokolade')));
      });

      test('names in two words are found as one, pasta as "Nudeln"', () {
        expect(names(index, 'haferflocken').first, 'Hafer Flocken');
        expect(names(index, 'haferflo').first, 'Hafer Flocken');
        expect(names(index, 'nudeln'), contains('Teigwaren eifrei, gekocht'));
      });

      test('the English UI searches the English names', () {
        expect(
          names(index, 'flatbread', languageCode: 'en').first,
          'Wheat flatbread',
        );
        expect(names(index, 'apple', languageCode: 'en').first, 'Apple raw');
      });
    });
  });
}
