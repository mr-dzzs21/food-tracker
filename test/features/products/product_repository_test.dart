import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/errors.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/products/basic_foods.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/health_rating.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/features/products/off_client.dart';
import 'package:food_tracker/features/products/product_repository.dart';
import 'package:food_tracker/features/products/simple_foods.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/off_fixtures.dart';
import '../../helpers/pump_app.dart';

const crispsCode = '4003586100313';

/// The crisps response with a different name (OFF data changed).
String renamedCrisps(String name) {
  final json = fixtureJson('crisps.json');
  (json['product']! as Map<String, Object?>)['product_name_de'] = name;
  return jsonEncode(json);
}

void main() {
  late AppDatabase db;
  late DateTime now;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) respond;
  late ProductRepository repo;

  setUp(() {
    db = newTestDatabase();
    now = testNow;
    requests = [];
    respond = (_) async => jsonResponse(fixtureText('crisps.json'));
    final clock = Clock(() => now);
    final client = OpenFoodFactsClient(
      MockClient((request) {
        requests.add(request);
        return respond(request);
      }),
      userAgent: 'test',
      clock: clock,
      delay: (_) async {},
    );
    repo = ProductRepository(db, client, clock);
  });

  tearDown(() => db.close());

  Future<int> insertOwnFood(String name, {String? brand}) => repo.saveOwnFood(
    name: name,
    brand: brand,
    nutrients: const Nutrients(kcal: 100),
  );

  group('lookupBarcode', () {
    test('downloads, stores and then answers from the device', () async {
      final food = await repo.lookupBarcode(crispsCode);

      expect(food.source, FoodSource.openFoodFacts);
      expect(food.barcode, crispsCode);
      expect(food.name, 'chipsfrisch ungarisch');
      expect(food.kcal, 533);
      expect(food.servingSize, 30);
      expect(food.nutriScore, 'D');
      expect(
        food.categories,
        startsWith('en:plant-based-foods-and-beverages,'),
      );
      expect(food.fetchedAt, testNow);
      expect(food.createdAt, testNow);
      expect(requests, hasLength(1));

      now = now.add(const Duration(days: 29));
      final again = await repo.lookupBarcode(crispsCode);
      expect(again.id, food.id);
      expect(requests, hasLength(1)); // fresh cache, no request
    });

    test('any spelling of a barcode finds the same row', () async {
      respond = (_) async => jsonResponse(fixtureText('water.json'));
      final first = await repo.lookupBarcode('0000042376095');
      expect(first.barcode, '42376095');
      final second = await repo.lookupBarcode('42376095');
      expect(second.id, first.id);
      expect(requests, hasLength(1));
    });

    test(
      'stale cache: returns at once and refreshes in the background',
      () async {
        final old = await repo.lookupBarcode(crispsCode);
        now = now.add(const Duration(days: 31));
        respond = (_) async => jsonResponse(renamedCrisps('Neuer Name'));

        final cached = await repo.lookupBarcode(crispsCode);
        expect(cached.name, 'chipsfrisch ungarisch');

        await expectLater(
          repo.watchFood(old.id),
          emitsThrough(
            isA<Food>()
                .having((f) => f.name, 'name', 'Neuer Name')
                .having((f) => f.fetchedAt, 'fetchedAt', now),
          ),
        );
        expect(requests, hasLength(2));
      },
    );

    test('stale cache offline: no error, data stays, no retry', () async {
      final old = await repo.lookupBarcode(crispsCode);
      now = now.add(const Duration(days: 40));
      respond = (_) async => throw http.ClientException('offline');

      final cached = await repo.lookupBarcode(crispsCode);
      await pumpEventQueue();

      expect(cached.name, old.name);
      expect(requests, hasLength(2)); // one background try only
      expect((await repo.getFood(old.id))!.fetchedAt, testNow);
    });

    test('a refresh keeps favourite, recents and the id', () async {
      final food = await repo.lookupBarcode(crispsCode);
      await repo.toggleFavourite(food.id);
      await repo.markUsed(food.id);
      await repo.markViewed(food.id);

      now = now.add(const Duration(days: 31));
      respond = (_) async => jsonResponse(renamedCrisps('Neu'));
      await repo.lookupBarcode(crispsCode);
      await expectLater(
        repo.watchFood(food.id),
        emitsThrough(isA<Food>().having((f) => f.name, 'name', 'Neu')),
      );

      final refreshed = (await repo.getFood(food.id))!;
      expect(refreshed.isFavourite, isTrue);
      expect(refreshed.lastUsedAt, testNow);
      expect(refreshed.lastViewedAt, testNow);
      expect(refreshed.createdAt, testNow);
    });

    test('product without kcal: stored, but IncompleteProduct', () async {
      respond = (_) async => jsonResponse(fixtureText('no_energy.json'));

      await expectLater(
        repo.lookupBarcode('4260426710013'),
        throwsA(isA<IncompleteProduct>()),
      );
      final stored = await repo.getFoodByBarcode('4260426710013');
      expect(stored, isNotNull);
      expect(stored!.kcal, isNull);
      expect(stored.fat, 3.5); // the form can be prefilled with this

      // From the cache it is still incomplete, without a new request.
      await expectLater(
        repo.lookupBarcode('4260426710013'),
        throwsA(isA<IncompleteProduct>()),
      );
      expect(requests, hasLength(1));
    });

    test('not found and invalid barcodes store nothing', () async {
      respond = (_) async =>
          jsonResponse(fixtureText('not_found.json'), status: 404);
      await expectLater(
        repo.lookupBarcode('4099999999996'),
        throwsA(isA<ProductNotFound>()),
      );
      await expectLater(
        repo.lookupBarcode('3017624010702'),
        throwsA(isA<InvalidBarcode>()),
      );
      expect(requests, hasLength(1));
      expect(await db.select(db.foods).get(), isEmpty);
    });

    test('an own food with a barcode is never fetched', () async {
      final id = await repo.saveOwnFood(
        name: 'Omas Marmelade',
        barcode: crispsCode,
        nutrients: const Nutrients(kcal: 250),
      );
      now = now.add(const Duration(days: 365));
      final food = await repo.lookupBarcode(crispsCode);
      await pumpEventQueue();
      expect(food.id, id);
      expect(food.name, 'Omas Marmelade');
      expect(requests, isEmpty);
    });
  });

  test('search goes online and passes the page', () async {
    respond = (_) async =>
        jsonResponse(fixtureText('search_haferflocken.json'));
    final page = await repo.search('haferflocken', page: 3);
    expect(page.products, hasLength(4));
    expect(requests.single.url.queryParameters['page'], '3');
  });

  group('searchLocal', () {
    test('ignores case, also for umlauts, and searches the brand', () async {
      await insertOwnFood('Bircher Müsli', brand: 'Seitenbacher');
      await insertOwnFood('Äpfel');
      await repo.lookupBarcode(crispsCode); // a cached OFF product

      List<String> names(List<Food> foods) => [for (final f in foods) f.name];
      expect(names(await repo.searchLocal('müsli')), ['Bircher Müsli']);
      expect(names(await repo.searchLocal('MÜSLI')), ['Bircher Müsli']);
      expect(names(await repo.searchLocal('äpfel')), ['Äpfel']);
      expect(names(await repo.searchLocal('seitenbacher')), ['Bircher Müsli']);
      expect(names(await repo.searchLocal('funny chips')), [
        'chipsfrisch ungarisch',
      ]);
      expect(await repo.searchLocal('  '), isEmpty);
      expect(await repo.searchLocal('pizza'), isEmpty);
    });

    test('favourites come first, then by name', () async {
      await insertOwnFood('b Joghurt');
      final favourite = await insertOwnFood('Z Joghurt');
      await insertOwnFood('A Joghurt');
      await repo.toggleFavourite(favourite);

      final result = await repo.searchLocal('joghurt');
      expect(
        [for (final f in result) f.name],
        ['Z Joghurt', 'A Joghurt', 'b Joghurt'],
      );
    });
  });

  group('basic foods (BLS)', () {
    const flatbread = BasicFood(
      code: 'B782100',
      nameDe: 'Weizenfladenbrot',
      nameEn: 'Wheat flatbread',
      // The values of the bundled file.
      nutrients: Nutrients(
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
    const water = BasicFood(
      code: 'N110000',
      nameDe: 'Trinkwasser',
      nameEn: 'Drinking water',
      nutrients: Nutrients(kcal: 0),
      isLiquid: true,
      category: 'en:waters',
    );

    test('opening one stores it as a normal food', () async {
      final id = await repo.saveBasicFood(flatbread, languageCode: 'de');

      final food = (await repo.getFood(id))!;
      expect(food.source, FoodSource.bls);
      expect(food.externalId, 'B782100');
      expect(food.name, 'Weizenfladenbrot');
      expect(food.brand, isNull);
      expect(food.barcode, isNull);
      expect(food.isLiquid, isFalse);
      expect(food.nutrients, flatbread.nutrients);
      expect(food.categories, isNull);
      expect(food.createdAt, testNow);
      // No Open Food Facts categories: food thresholds, not "unknown type".
      expect(rateFood(food), isA<Rated>());
    });

    test('opening it again updates the same row and keeps the star', () async {
      final id = await repo.saveBasicFood(flatbread, languageCode: 'de');
      await repo.toggleFavourite(id);
      await repo.markUsed(id);

      final again = await repo.saveBasicFood(flatbread, languageCode: 'en');

      expect(again, id);
      expect(await db.select(db.foods).get(), hasLength(1));
      final food = (await repo.getFood(id))!;
      expect(food.name, 'Wheat flatbread'); // the current UI language
      expect(food.isFavourite, isTrue);
      expect(food.lastUsedAt, testNow);
    });

    test('a drink of a kind without traffic light keeps both hints', () async {
      final id = await repo.saveBasicFood(water, languageCode: 'de');
      final food = (await repo.getFood(id))!;
      expect(food.isLiquid, isTrue);
      expect(food.categories, 'en:waters');
      expect(
        rateFood(food),
        isA<NotRated>().having(
          (r) => r.reason,
          'reason',
          NotRatedReason.excludedType,
        ),
      );
    });

    test(
      'the local search leaves them out (they have their own section)',
      () async {
        await repo.saveBasicFood(flatbread, languageCode: 'de');
        await insertOwnFood('Fladenbrot vom Bäcker');
        expect(
          [for (final f in await repo.searchLocal('fladenbrot')) f.name],
          ['Fladenbrot vom Bäcker'],
        );
      },
    );

    test('they are deleted with all other data', () async {
      await repo.saveBasicFood(flatbread, languageCode: 'de');
      await db.deleteAllData();
      expect(await db.select(db.foods).get(), isEmpty);
      // … and can be opened again afterwards.
      await repo.saveBasicFood(flatbread, languageCode: 'de');
      expect(await db.select(db.foods).get(), hasLength(1));
    });
  });

  group('simple foods', () {
    const banana = SimpleFood(
      key: 'banane',
      nameDe: 'Banane',
      nameEn: 'Banana',
      nutrients: Nutrients(kcal: 79, fat: 0.2, carbs: 18, protein: 1.2),
      portionGrams: 120,
      portionDe: '1 Banane',
      portionEn: '1 banana',
      blsCode: 'F503100',
    );
    const skyrVanilla = SimpleFood(
      key: 'skyr-vanille',
      nameDe: 'Skyr Vanille',
      nameEn: 'Skyr, vanilla',
      nutrients: Nutrients(kcal: 75, fat: 0.2, sugars: 9, protein: 9.2),
      portionGrams: 150,
      portionDe: '1 Portion',
      portionEn: '1 serving',
      offProductCount: 23,
    );

    test('one with BLS values is stored like that BLS food, with the short '
        'name and the typical portion', () async {
      final id = await repo.saveSimpleFood(banana, languageCode: 'de');

      final food = (await repo.getFood(id))!;
      expect(food.source, FoodSource.bls);
      expect(food.externalId, 'F503100');
      expect(food.name, 'Banane');
      expect(food.servingSize, 120);
      expect(food.servingLabel, '1 Banane');
      expect(food.nutrients, banana.nutrients);
      expect(rateFood(food), isA<Rated>());

      // The same row as the BLS food with that code (one row per BLS food).
      final blsId = await repo.saveBasicFood(
        const BasicFood(
          code: 'F503100',
          nameDe: 'Banane roh',
          nameEn: 'Banana raw',
          nutrients: Nutrients(kcal: 79, fat: 0.2, carbs: 18, protein: 1.2),
        ),
        languageCode: 'de',
      );
      expect(blsId, id);
      expect(await db.select(db.foods).get(), hasLength(1));
    });

    test('an Open Food Facts average gets its own kind and key', () async {
      final id = await repo.saveSimpleFood(skyrVanilla, languageCode: 'en');
      await repo.toggleFavourite(id);

      final food = (await repo.getFood(id))!;
      expect(food.source, FoodSource.offAverage);
      expect(food.externalId, 'skyr-vanille');
      expect(food.name, 'Skyr, vanilla');
      expect(food.servingLabel, '1 serving');
      // Rated like a basic food: food thresholds, no "unknown type".
      expect(
        rateFood(food),
        isA<Rated>().having((r) => r.basis, 'basis', RatingBasis.food),
      );

      // Opening it again updates the row and keeps the star.
      expect(await repo.saveSimpleFood(skyrVanilla, languageCode: 'de'), id);
      final again = (await repo.getFood(id))!;
      expect(again.name, 'Skyr Vanille');
      expect(again.isFavourite, isTrue);
      expect(await db.select(db.foods).get(), hasLength(1));
    });

    test(
      'the local search leaves them out (they have their own section)',
      () async {
        await repo.saveSimpleFood(skyrVanilla, languageCode: 'de');
        await insertOwnFood('Skyr mit Honig');
        expect(
          [for (final f in await repo.searchLocal('skyr')) f.name],
          ['Skyr mit Honig'],
        );
      },
    );
  });

  group('lists', () {
    test('recently used: newest first, at most 20', () async {
      final ids = <int>[];
      for (var i = 0; i < 22; i++) {
        ids.add(await insertOwnFood('Food $i'));
      }
      for (final id in ids) {
        now = now.add(const Duration(minutes: 1));
        await repo.markUsed(id);
      }
      final recent = await repo.watchRecentlyUsed().first;
      expect(recent, hasLength(20));
      expect(recent.first.name, 'Food 21');
      expect(recent.last.name, 'Food 2');

      // Using an old food again moves it to the top.
      now = now.add(const Duration(minutes: 1));
      await repo.markUsed(ids.first);
      expect((await repo.watchRecentlyUsed().first).first.name, 'Food 0');
    });

    test('recently viewed is a separate list', () async {
      final eaten = await insertOwnFood('Gegessen');
      final seen = await insertOwnFood('Angesehen');
      await repo.markUsed(eaten);
      now = now.add(const Duration(minutes: 1));
      await repo.markViewed(seen);

      final viewed = await repo.watchRecentlyViewed().first;
      expect([for (final f in viewed) f.name], ['Angesehen']);
      expect(viewed.single.lastViewedAt, now);
    });

    test('toggleFavourite switches on and off', () async {
      final id = await insertOwnFood('Banane');
      await repo.toggleFavourite(id);
      expect((await repo.watchFavourites().first).single.id, id);
      await repo.toggleFavourite(id);
      expect(await repo.watchFavourites().first, isEmpty);
    });

    test('own foods only, sorted by name ignoring case', () async {
      await repo.lookupBarcode(crispsCode);
      await insertOwnFood('banane');
      await insertOwnFood('Apfel');
      final own = await repo.watchOwnFoods().first;
      expect([for (final f in own) f.name], ['Apfel', 'banane']);
    });
  });

  group('own foods', () {
    test('create and update', () async {
      final id = await repo.saveOwnFood(
        name: '  Porridge ',
        brand: ' ',
        servingSize: 250,
        servingLabel: '1 Schüssel',
        nutrients: const Nutrients(kcal: 120, protein: 4),
      );
      var food = (await repo.getFood(id))!;
      expect(food.source, FoodSource.user);
      expect(food.name, 'Porridge');
      expect(food.brand, isNull);
      expect(food.servingSize, 250);
      expect(food.createdAt, testNow);
      expect(food.nutrients, const Nutrients(kcal: 120, protein: 4));

      await repo.saveOwnFood(
        id: id,
        name: 'Porridge mit Milch',
        isLiquid: false,
        nutrients: const Nutrients(kcal: 150),
      );
      food = (await repo.getFood(id))!;
      expect(food.name, 'Porridge mit Milch');
      expect(food.nutrients, const Nutrients(kcal: 150));
      expect(food.servingSize, isNull);
      expect(await db.select(db.foods).get(), hasLength(1));
    });

    test('a wrong barcode is refused', () async {
      await expectLater(
        repo.saveOwnFood(
          name: 'X',
          barcode: '123',
          nutrients: const Nutrients(kcal: 1),
        ),
        throwsA(isA<InvalidBarcode>()),
      );
    });

    test('completing an incomplete OFF product reuses its row', () async {
      respond = (_) async => jsonResponse(fixtureText('no_energy.json'));
      await expectLater(
        repo.lookupBarcode('4260426710013'),
        throwsA(isA<IncompleteProduct>()),
      );
      final cached = (await repo.getFoodByBarcode('4260426710013'))!;
      await repo.toggleFavourite(cached.id);

      final id = await repo.saveOwnFood(
        name: 'Naturjoghurt',
        barcode: '4260426710013',
        nutrients: const Nutrients(kcal: 67, fat: 3.5),
      );
      expect(id, cached.id);
      final food = (await repo.getFood(id))!;
      expect(food.source, FoodSource.user);
      expect(food.kcal, 67);
      expect(food.isFavourite, isTrue);
      expect(food.fetchedAt, isNull);
      expect(food.nutriScore, isNull);

      // Now the lookup answers with the own food.
      expect((await repo.lookupBarcode('4260426710013')).id, id);
      expect(requests, hasLength(1));
    });

    test('delete keeps the diary snapshot', () async {
      final id = await insertOwnFood('Pfannkuchen');
      final entryId = await db
          .into(db.diaryEntries)
          .insert(
            DiaryEntriesCompanion.insert(
              day: '2026-11-14',
              mealSlotId: 1,
              foodId: Value(id),
              name: 'Pfannkuchen',
              amount: 150,
              kcal: const Value(100),
              createdAt: testNow,
            ),
          );

      await repo.deleteOwnFood(id);

      expect(await repo.getFood(id), isNull);
      final entry = await (db.select(
        db.diaryEntries,
      )..where((e) => e.id.equals(entryId))).getSingle();
      expect(entry.foodId, isNull);
      expect(entry.name, 'Pfannkuchen');
      expect(entry.kcal, 100);
    });

    test('deleteOwnFood leaves cached OFF products alone', () async {
      final food = await repo.lookupBarcode(crispsCode);
      await repo.deleteOwnFood(food.id);
      expect(await repo.getFood(food.id), isNotNull);
    });

    test('watchFood emits null after delete', () async {
      final id = await insertOwnFood('Kurz');
      final emitted = expectLater(
        repo.watchFood(id),
        emitsInOrder([isA<Food>(), isNull]),
      );
      await pumpEventQueue();
      await repo.deleteOwnFood(id);
      await emitted;
    });
  });

  group('providers', () {
    test('lookup provider sends the app User-Agent', () async {
      final sent = <http.Request>[];
      final container = ProviderContainer.test(
        retry: (_, _) => null,
        overrides: testOverrides(
          db: db,
          client: MockClient((request) async {
            sent.add(request);
            return jsonResponse(fixtureText('crisps.json'));
          }),
        ),
      );

      final lookup = container.listen(
        barcodeLookupProvider((barcode: crispsCode, languageCode: 'en')).future,
        (_, _) {},
      );
      final food = await lookup.read();
      expect(food.name, 'Chipsfrisch ungarisch');
      expect(
        sent.single.headers['User-Agent'],
        'FoodTracker/0.1.0-test (https://github.com/mr-dzzs21/food-tracker)',
      );
    });

    test('list providers stream from the database', () async {
      final container = ProviderContainer.test(
        retry: (_, _) => null,
        overrides: testOverrides(db: db),
      );
      final repository = container.read(productRepositoryProvider);
      final id = await repository.saveOwnFood(
        name: 'Eigenes Brot',
        nutrients: const Nutrients(kcal: 240),
      );
      // Listening keeps the auto-dispose providers alive while we read.
      final own = container.listen(ownFoodsProvider.future, (_, _) {});
      final food = container.listen(foodProvider(id).future, (_, _) {});
      expect((await own.read()).single.name, 'Eigenes Brot');
      expect((await food.read())!.kcal, 240);
    });
  });
}
