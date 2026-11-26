import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/products/basic_foods.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/features/products/simple_foods.dart';
import 'package:food_tracker/router.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/off_fixtures.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/scan_helpers.dart';

/// A second result page with one product (the last page).
final _page2 = jsonEncode({
  'hits': [
    {
      'code': '4099999999996',
      'product_name': 'Haferdrink',
      'brands': ['Oatly'],
      'nutriments': {'energy-kcal_100g': 46},
    },
  ],
  'count': 2,
  'page': 2,
  'page_count': 2,
});

/// Simple foods for the search; the real files are not loaded in tests.
const _simpleFoods = [
  SimpleFood(
    order: 1,
    key: 'haferflocken',
    nameDe: 'Haferflocken',
    nameEn: 'Oat flakes',
    nutrients: Nutrients(kcal: 348),
    portionGrams: 40,
    portionDe: '4 EL',
    portionEn: '4 tbsp',
    blsCode: 'C133000',
  ),
];

const _empty = '{"hits": [], "count": 0, "page": 1, "page_count": 0}';

/// Basic foods (BLS) for the search; the real file is not loaded in tests.
const _basicFoods = [
  BasicFood(
    code: 'C133000',
    nameDe: 'Hafer Flocken',
    nameEn: 'Oat flakes',
    nutrients: Nutrients(kcal: 348),
  ),
  BasicFood(
    code: 'B782100',
    nameDe: 'Weizenfladenbrot',
    nameEn: 'Wheat flatbread',
    nutrients: Nutrients(kcal: 248),
  ),
];

void main() {
  late AppDatabase db;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) respond;

  setUp(() {
    db = newTestDatabase();
    requests = [];
    respond = (request) async {
      final page = request.url.queryParameters['page'];
      return jsonResponse(
        page == '2' ? _page2 : fixtureText('search_haferflocken.json'),
      );
    };
  });

  tearDown(() => db.close());

  List<http.Request> searches() =>
      requests.where((r) => r.url.host == 'search.openfoodfacts.org').toList();

  /// Starts the app on a tall screen and opens the results for [query].
  Future<GoRouter> openSearch(
    WidgetTester tester,
    String query, {
    Locale locale = const Locale('de'),
    List<BasicFood> basicFoods = const [],
    List<SimpleFood> simpleFoods = const [],
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final client = MockClient((request) {
      requests.add(request);
      return respond(request);
    });
    await pumpFoodTrackerApp(
      tester,
      db: db,
      client: client,
      locale: locale,
      basicFoods: basicFoods,
      simpleFoods: simpleFoods,
      extraOverrides: [offClientWithoutDelays(client)],
    );
    final router = ProviderScope.containerOf(
      tester.element(find.byType(FoodTrackerApp)),
    ).read(routerProvider);
    unawaited(router.push(Routes.search(query)));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('shows brand products with brand and kcal', (tester) async {
    await openSearch(tester, 'Haferflocken');

    expect(find.text('Suche: Haferflocken'), findsOneWidget);
    expect(find.text('Markenprodukte (Deutschland)'), findsOneWidget);
    expect(find.text('Zarte Haferflocken'), findsOneWidget);
    // Brand without "xx:" below the name; kcal from the Nutri-Score data
    // (1486.4 kJ) on the right. No Nutri-Score in the short rows.
    expect(find.text('Spielberger Mühle'), findsOneWidget);
    expect(find.text('355 kcal'), findsOneWidget);
    expect(find.textContaining('Nutri-Score'), findsNothing);
    expect(find.text('Daten: Open Food Facts (ODbL)'), findsOneWidget);
    expect(find.text('Mehr laden'), findsOneWidget); // page 1 of 132
    // No simple or basic foods given: no empty "Lebensmittel" section.
    expect(find.text('Lebensmittel'), findsNothing);

    // One request, sent with our User-Agent, for the submitted text only,
    // limited to products sold in Germany.
    expect(searches(), hasLength(1));
    final request = searches().single;
    expect(
      request.url.queryParameters['q'],
      'Haferflocken countries:"en:germany"',
    );
    expect(request.url.queryParameters['page'], '1');
    expect(request.headers['User-Agent'], startsWith('FoodTracker/'));
  });

  testWidgets('foods on the device come first', (tester) async {
    await db
        .into(db.foods)
        .insert(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: 'Haferflocken mit Nüssen',
            kcal: const Value(400),
            createdAt: testNow,
          ),
        );
    await openSearch(tester, 'haferflocken');

    expect(find.text('Auf deinem Gerät'), findsOneWidget);
    expect(find.text('Haferflocken mit Nüssen'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Haferflocken mit Nüssen')).dy,
      lessThan(tester.getTopLeft(find.text('Markenprodukte (Deutschland)')).dy),
    );
  });

  testWidgets('without a simple food, the BLS foods are the foods: then the '
      'device, then the brand products', (tester) async {
    await db
        .into(db.foods)
        .insert(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: 'Haferflocken Omas Art',
            kcal: const Value(380),
            createdAt: testNow,
          ),
        );
    await openSearch(tester, 'haferflocken', basicFoods: _basicFoods);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(find.text('Hafer Flocken'), findsOneWidget);
    expect(find.text('348 kcal'), findsOneWidget);
    expect(find.text('Weizenfladenbrot'), findsNothing); // does not match
    expect(find.text('Weitere Lebensmittel (BLS)'), findsNothing);
    expect(top('Lebensmittel'), lessThan(top('Hafer Flocken')));
    expect(top('Hafer Flocken'), lessThan(top('Auf deinem Gerät')));
    expect(
      top('Auf deinem Gerät'),
      lessThan(top('Markenprodukte (Deutschland)')),
    );
    // The source line the BLS licence asks for.
    expect(
      find.text(
        'Daten: Bundeslebensmittelschlüssel 4.0, Max Rubner-Institut '
        '(CC BY 4.0)',
      ),
      findsOneWidget,
    );
  });

  testWidgets('simple foods come first; tapping one opens it with its '
      'portion', (tester) async {
    final router = await openSearch(
      tester,
      'haferflocken',
      simpleFoods: _simpleFoods,
      basicFoods: _basicFoods,
    );

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('Lebensmittel'), lessThan(top('Haferflocken')));
    expect(top('Haferflocken'), lessThan(top('Markenprodukte (Deutschland)')));
    expect(find.text('4 EL (40 g)'), findsOneWidget);
    // The technical BLS name waits behind the button.
    expect(find.text('Hafer Flocken'), findsNothing);
    expect(find.text('Weitere Lebensmittel (BLS)'), findsOneWidget);

    await tester.tap(find.text('Haferflocken'));
    await tester.pumpAndSettle();

    final food = (await db.select(db.foods).get()).single;
    expect(food.source, FoodSource.simpleBls);
    expect(food.externalId, 'haferflocken');
    expect(food.name, 'Haferflocken');
    expect(food.servingSize, 40);
    expect(food.servingLabel, '4 EL');
    expect(router.state.uri.toString(), Routes.food(food.id));
    expect(find.text('4 EL (40\u00A0g)'), findsOneWidget);
  });

  testWidgets('tapping a basic food stores it and opens its product page', (
    tester,
  ) async {
    final router = await openSearch(
      tester,
      'Fladenbrot',
      basicFoods: _basicFoods,
    );

    await tester.tap(find.text('Weizenfladenbrot'));
    await tester.pumpAndSettle();

    final food = (await db.select(db.foods).get()).single;
    expect(food.source, FoodSource.bls);
    expect(food.externalId, 'B782100');
    expect(router.state.uri.toString(), Routes.food(food.id));
    expect(find.text('Durchschnittswerte'), findsOneWidget);
  });

  testWidgets('tapping a hit opens its product page', (tester) async {
    final router = await openSearch(tester, 'Haferflocken');

    await tester.tap(find.text('Zarte Haferflocken'));
    await tester.pumpAndSettle();

    expect(
      router.state.uri.toString(),
      Routes.product('4260070610493', fromSearch: true),
    );
  });

  testWidgets('a hit whose code the scanner would refuse still opens', (
    tester,
  ) async {
    // Open Food Facts lists products under a code with a wrong check digit
    // and under 8-digit codes that are not UPC-E codes to expand.
    respond = (request) async {
      if (request.url.host == 'search.openfoodfacts.org') {
        return jsonResponse(
          jsonEncode({
            'hits': [
              {'code': '4003586100314', 'product_name': 'Chips mit Tippfehler'},
              {'code': '04252614', 'product_name': 'Kurzer Code'},
            ],
            'count': 2,
            'page': 1,
            'page_count': 1,
          }),
        );
      }
      final json = fixtureJson('crisps.json');
      final product = json['product']! as Map<String, Object?>;
      final code = request.url.pathSegments.last;
      product['code'] = code;
      product['product_name_de'] = code == '04252614'
          ? 'Kurzer Code'
          : 'Chips mit Tippfehler';
      return jsonResponse(jsonEncode(json));
    };
    final router = await openSearch(tester, 'Chips');

    for (final (name, code) in [
      ('Chips mit Tippfehler', '4003586100314'),
      ('Kurzer Code', '04252614'),
    ]) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.textContaining('Barcode sieht ungültig aus'), findsNothing);
      // The product page with its name and the "add" button.
      expect(find.text(name), findsOneWidget);
      expect(requests.last.url.path, '/api/v3.4/product/$code');
      router.pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('no results: friendly empty state', (tester) async {
    respond = (_) async => jsonResponse(_empty);
    await openSearch(tester, 'xyzxyz');

    expect(find.text('Keine Treffer bei Open Food Facts.'), findsOneWidget);
    expect(
      find.text('Prüf die Schreibweise oder trag das Lebensmittel selbst ein.'),
      findsOneWidget,
    );
    expect(find.text('Mehr laden'), findsNothing);
  });

  testWidgets('offline: message and "Nochmal versuchen" loads the results', (
    tester,
  ) async {
    var online = false;
    respond = (_) async {
      if (!online) throw http.ClientException('offline');
      return jsonResponse(fixtureText('search_haferflocken.json'));
    };
    await openSearch(tester, 'Haferflocken');

    expect(find.textContaining('Du bist offline.'), findsOneWidget);
    expect(find.text('Zarte Haferflocken'), findsNothing);

    online = true;
    await tester.tap(find.text('Nochmal versuchen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Du bist offline.'), findsNothing);
    expect(find.text('Zarte Haferflocken'), findsOneWidget);
  });

  testWidgets('"Mehr laden" adds the next page and keeps the first', (
    tester,
  ) async {
    await openSearch(tester, 'Haferflocken');

    await tester.tap(find.text('Mehr laden'));
    await tester.pumpAndSettle();

    expect(find.text('Zarte Haferflocken'), findsOneWidget);
    expect(find.text('Haferdrink'), findsOneWidget);
    // Page 2 of 2: nothing more to load.
    expect(find.text('Mehr laden'), findsNothing);
    expect(searches().map((r) => r.url.queryParameters['page']), ['1', '2']);
  });

  testWidgets('hits with known kcal come first, in the server order; hits '
      'without kcal stay at the end', (tester) async {
    Map<String, Object?> hit(String code, String name, {num? kcal}) => {
      'code': code,
      'product_name': name,
      'nutriments': {'energy-kcal_100g': ?kcal},
    };
    respond = (_) async => jsonResponse(
      jsonEncode({
        'hits': [
          hit('4000000000001', 'Ohne Kalorien A'),
          hit('4000000000002', 'Mit Kalorien B', kcal: 100),
          hit('4000000000003', 'Ohne Kalorien C'),
          hit('4000000000004', 'Mit Kalorien D', kcal: 200),
        ],
        'count': 4,
        'page': 1,
        'page_count': 1,
      }),
    );
    await openSearch(tester, 'Kalorien');

    double top(String name) => tester.getTopLeft(find.text(name)).dy;
    expect(top('Mit Kalorien B'), lessThan(top('Mit Kalorien D')));
    expect(top('Mit Kalorien D'), lessThan(top('Ohne Kalorien A')));
    expect(top('Ohne Kalorien A'), lessThan(top('Ohne Kalorien C')));
    expect(find.text('Kalorien unbekannt'), findsNWidgets(2));
  });

  testWidgets('English texts', (tester) async {
    await openSearch(tester, 'Haferflocken', locale: const Locale('en'));

    expect(find.text('Search: Haferflocken'), findsOneWidget);
    expect(find.text('Brand products (Germany)'), findsOneWidget);
    expect(find.text('Spielberger Mühle'), findsOneWidget);
    expect(find.text('355 kcal'), findsOneWidget);
    expect(find.text('per 100 g'), findsWidgets);
    expect(find.text('Load more'), findsOneWidget);
  });
}
