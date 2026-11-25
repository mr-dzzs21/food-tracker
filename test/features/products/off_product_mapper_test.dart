import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/features/products/off_product_mapper.dart';

import '../../helpers/off_fixtures.dart';

OffProduct parse(Map<String, Object?> json, {String languageCode = 'de'}) =>
    parseOffProduct(json, languageCode: languageCode, requestedCode: '1');

void main() {
  group('recorded products', () {
    test('crisps: every field', () {
      final p = parse(fixtureProduct('crisps.json'));
      expect(p.barcode, '4003586100313');
      expect(p.name, 'chipsfrisch ungarisch');
      expect(p.brand, 'funny-frisch');
      expect(p.quantityLabel, '150g');
      expect(p.isLiquid, isFalse);
      expect(p.servingSize, 30);
      expect(p.servingLabel, '30 g');
      expect(
        p.nutrients,
        const Nutrients(
          kcal: 533,
          fat: 33,
          saturatedFat: 3,
          carbs: 49,
          sugars: 2.5,
          fibre: 4.5,
          protein: 6,
          salt: 1.5,
        ),
      );
      expect(p.nutriScore, 'D');
      expect(p.novaGroup, 4);
      expect(p.categories, contains('en:potato-crisps'));
      expect(p.imageUrl, endsWith('front_de.63.200.jpg'));
      expect(p.completeness, 0.9);
      expect(p.productType, 'food');
    });

    test('crisps in English use the English name', () {
      final p = parse(fixtureProduct('crisps.json'), languageCode: 'en');
      expect(p.name, 'Chipsfrisch ungarisch');
    });

    test('soft drink: German name instead of the main-language name', () {
      final p = parse(fixtureProduct('soft_drink.json'));
      // product_name is "Coca-Cola Original" (the Spanish main language).
      expect(p.name, 'Coca-Cola');
      expect(p.isLiquid, isTrue);
      expect(p.servingSize, 330);
      expect(p.servingLabel, '1 portion (330 ml)');
      expect(p.nutrients.kcal, 44);
      expect(p.nutrients.sugars, 10.9);
      expect(p.nutrients.fibre, isNull); // not declared → unknown, not 0
      expect(p.nutriScore, 'E');
      // Non-normalised tags are kept as they are (only exact matches count).
      expect(p.categories, contains('pt:bebidas cafeína'));
    });

    test('water: no energy value means 0 kcal; EAN-8 code stays short', () {
      final p = parse(fixtureProduct('water.json'));
      expect(p.barcode, '42376095');
      expect(p.isLiquid, isTrue);
      expect(p.nutrients.kcal, 0);
      expect(p.nutrients.salt, 0.004925);
      expect(p.nutrients.fat, isNull);
      expect(p.brand, 'Saskia, LIDL, LIDL Saskia');
    });

    test('yoghurt: estimated fibre is ignored', () {
      final p = parse(fixtureProduct('yoghurt.json'));
      expect(p.name, 'Cremiges Heumilch Naturjoghurt');
      expect(p.nutrients.fibre, isNull);
      expect(p.nutrients.salt, 0.12);
      expect(p.servingSize, 250);
      expect(p.nutriScore, 'B');
      expect(p.completeness, 0.675);
    });

    test('sparse product: missing data stays missing', () {
      final p = parse(fixtureProduct('sparse_product.json'));
      expect(p.name, 'Naturjoghurt');
      expect(p.brand, isNull);
      expect(p.imageUrl, isNull);
      expect(p.categories, isEmpty);
      expect(p.nutriScore, isNull); // "unknown"
      expect(p.novaGroup, isNull);
      expect(p.nutrients.kcal, 67);
      expect(p.nutrients.salt, isNull);
      expect(p.completeness, 0.2);
    });

    test('product without energy has unknown kcal', () {
      final p = parse(fixtureProduct('no_energy.json'));
      expect(p.nutrients.kcal, isNull);
      expect(p.nutrients.fat, 3.5);
    });
  });

  group('nutrient fallbacks and sanity', () {
    Nutrients nutrientsOf(
      Map<String, Object?> nutriments, {
      List<String> categories = const [],
    }) =>
        parse({'nutriments': nutriments, 'categories_tags': categories})
            .nutrients;

    test('kcal from kJ when the kcal value is missing', () {
      final n = nutrientsOf({'energy-kj_100g': 2223});
      expect(n.kcal, closeTo(531.31, 0.01));
    });

    test('salt from sodium (× 2.5); a declared salt value wins', () {
      expect(nutrientsOf({'sodium_100g': 0.4}).salt, closeTo(1.0, 1e-9));
      expect(nutrientsOf({'salt_100g': 1.1, 'sodium_100g': 0.4}).salt, 1.1);
    });

    test('numbers sent as text are read, also with a decimal comma', () {
      final n = nutrientsOf({'fat_100g': '4.5', 'sugars_100g': ' 2,5 '});
      expect(n.fat, 4.5);
      expect(n.sugars, 2.5);
      expect(parse({'completeness': '0.9'}).completeness, 0.9);
    });

    test('impossible values become unknown', () {
      final n = nutrientsOf({
        'fat_100g': 120,
        'sugars_100g': -1,
        'proteins_100g': 'n/a',
        'energy-kcal_100g': 5000,
      });
      expect(n.fat, isNull);
      expect(n.sugars, isNull);
      expect(n.protein, isNull);
      expect(n.kcal, isNull);
    });

    test('an impossible kcal value falls back to kJ', () {
      final n = nutrientsOf({
        'energy-kcal_100g': 5000,
        'energy-kj_100g': 418.4,
      });
      expect(n.kcal, closeTo(100, 1e-9));
    });

    test('flavoured water without energy is unknown, not 0', () {
      final n = nutrientsOf(
        {'sugars_100g': 4.5},
        categories: ['en:beverages', 'en:waters', 'en:flavored-waters'],
      );
      expect(n.kcal, isNull);
    });

    test('a missing nutriments object gives unknown values', () {
      expect(parse({}).nutrients, Nutrients.unknown);
    });
  });

  group('other fields', () {
    test('name fallback order (brief R3)', () {
      expect(
        parse({'product_name': ' Main ', 'product_name_en': 'English'}).name,
        'Main',
      );
      expect(
        parse({
          'product_name': 'Main',
          'product_name_en': 'English',
        }, languageCode: 'en').name,
        'English',
      );
      expect(
        parse({'product_name': ' ', 'generic_name_de': 'Joghurt'}).name,
        'Joghurt',
      );
      expect(parse({'abbreviated_product_name': 'Abk.'}).name, 'Abk.');
      expect(parse({}).name, isNull);
    });

    test('liquid by unit, even without categories', () {
      expect(parse({'product_quantity_unit': 'ml'}).isLiquid, isTrue);
      expect(parse({'serving_quantity_unit': 'ML'}).isLiquid, isTrue);
      expect(parse({'product_quantity_unit': 'g'}).isLiquid, isFalse);
    });

    test('portion size 0 or missing means no portion', () {
      expect(parse({'serving_quantity': 0}).servingSize, isNull);
      expect(parse({'serving_quantity': '40'}).servingSize, 40);
      expect(parse({}).servingSize, isNull);
    });

    test('Nutri-Score only A–E, NOVA only 1–4', () {
      expect(parse({'nutriscore_grade': 'b'}).nutriScore, 'B');
      expect(parse({'nutriscore_grade': 'not-applicable'}).nutriScore, isNull);
      expect(parse({'nova_group': 5}).novaGroup, isNull);
      expect(parse({'nova_group': 2.5}).novaGroup, isNull);
      expect(parse({'nova_group': '3'}).novaGroup, 3);
    });

    test('thumbnail when there is no small image', () {
      expect(
        parse({'image_front_thumb_url': 'https://x/t.jpg'}).imageUrl,
        'https://x/t.jpg',
      );
    });

    test('barcode is normalised; requested code is the fallback', () {
      expect(parse({'code': '0000042376095'}).barcode, '42376095');
      expect(
        parseOffProduct(
          {},
          languageCode: 'de',
          requestedCode: '036000291452',
        ).barcode,
        '0036000291452',
      );
    });
  });

  group('search results', () {
    test('recorded page (2026-11): brand tags, kcal from nutriscore_data', () {
      final page = parseOffSearchPage(
        fixtureJson('search_haferflocken.json'),
        languageCode: 'de',
      );
      expect(page.products, hasLength(4));
      expect(page.count, 525);
      expect(page.page, 1);
      expect(page.pageCount, 132);
      expect(page.hasMore, isTrue);

      final [kleinblatt, spielberger, biobio, kClassic] = page.products;
      expect(spielberger.barcode, '4022381304184');
      expect(spielberger.name, 'Kleinblatt Haferflocken Vollkorn');
      // "xx:Spielberger Mühle": the language part of the tag is not shown.
      expect(spielberger.brand, 'Spielberger Mühle');
      // No nutriments any more: 1486.4 kJ from the Nutri-Score data.
      expect(spielberger.nutrients.kcal, closeTo(355.3, 0.05));
      expect(spielberger.nutrients.fat, isNull);
      expect(spielberger.isLiquid, isFalse);
      expect(kClassic.brand, 'k-classic');
      expect(kClassic.nutrients.kcal, closeTo(372.8, 0.05)); // 1560 kJ
      // Only "energy_from_saturated_fat" (fats/nuts formula): not the total.
      expect(kleinblatt.nutrients.kcal, isNull);
      // No nutriscore_data at all.
      expect(biobio.nutrients.kcal, isNull);
    });

    group('kcal of a search hit', () {
      Map<String, Object?> hit(
        Object? components, {
        Map<String, Object?>? nutriments,
        int isBeverage = 0,
      }) => {
        'code': '4000000000001',
        'nutriments': ?nutriments,
        'nutriscore_data': {
          'is_beverage': isBeverage,
          'components': {'negative': components},
        },
      };
      double? kcalOf(Map<String, Object?> json) =>
          parseOffProduct(json, languageCode: 'de').nutrients.kcal;

      test('energy in kJ is converted (Nutella: 2252 kJ ≈ 538 kcal)', () {
        expect(
          kcalOf(
            hit([
              {'id': 'energy', 'value': 2252, 'unit': 'kJ'},
            ]),
          ),
          closeTo(538.2, 0.05),
        );
      });

      test('energy in kcal is taken as it is', () {
        expect(
          kcalOf(
            hit([
              {'id': 'energy', 'value': 42, 'unit': 'kcal'},
            ]),
          ),
          42,
        );
      });

      test('missing, unknown unit or impossible energy → unknown', () {
        expect(kcalOf(hit(null)), isNull);
        expect(kcalOf(hit(<Object?>[])), isNull);
        expect(
          kcalOf(
            hit([
              {'id': 'energy', 'value': null, 'unit': 'kJ'},
            ]),
          ),
          isNull,
        );
        expect(
          kcalOf(
            hit([
              {'id': 'energy', 'value': 300, 'unit': 'g'},
            ]),
          ),
          isNull,
        );
        // 9999 kJ ≈ 2390 kcal per 100 g: more than pure fat.
        expect(
          kcalOf(
            hit([
              {'id': 'energy', 'value': 9999, 'unit': 'kJ'},
            ]),
          ),
          isNull,
        );
      });

      test('nutriments win when they are there', () {
        expect(
          kcalOf(
            hit(
              [
                {'id': 'energy', 'value': 2252, 'unit': 'kJ'},
              ],
              nutriments: {'energy-kcal_100g': 539},
            ),
          ),
          539,
        );
      });

      test('is_beverage marks a drink (kcal per 100 ml in the list)', () {
        final json = hit(const [], isBeverage: 1);
        expect(parseOffProduct(json, languageCode: 'de').isLiquid, isTrue);
      });
    });

    test('hits without a barcode are skipped; last page has no more', () {
      final page = parseOffSearchPage({
        'hits': [
          {'product_name': 'No code'},
          {
            'code': '5449000000996',
            'product_name': 'Cola',
            'brands': <String>[],
          },
          'not a map',
        ],
        'count': 1,
        'page': 2,
        'page_count': 2,
      }, languageCode: 'de');
      expect(page.products.single.name, 'Cola');
      expect(page.products.single.brand, isNull);
      expect(page.hasMore, isFalse);
    });

    test('an empty answer gives an empty page', () {
      final page = parseOffSearchPage({}, languageCode: 'de');
      expect(page.products, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });
}
