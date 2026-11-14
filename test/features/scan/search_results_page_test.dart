import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/products/food_source.dart';
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

const _empty = '{"hits": [], "count": 0, "page": 1, "page_count": 0}';

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
      extraOverrides: [offClientWithoutDelays(client)],
    );
    final router = ProviderScope.containerOf(
      tester.element(find.byType(FoodTrackerApp)),
    ).read(routerProvider);
    unawaited(router.push(Routes.search(query)));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('shows online results with brand, kcal and Nutri-Score text', (
    tester,
  ) async {
    await openSearch(tester, 'Haferflocken');

    expect(find.text('Suche: Haferflocken'), findsOneWidget);
    expect(find.text('Online-Ergebnisse'), findsOneWidget);
    expect(find.text('Haferflocken'), findsOneWidget);
    expect(find.text('Kernige Haferflocken'), findsOneWidget);
    expect(
      find.text('Crownfield\n372 kcal pro 100 g · Nutri-Score: A'),
      findsOneWidget,
    );
    expect(find.text('Daten: Open Food Facts (ODbL)'), findsOneWidget);
    expect(find.text('Mehr laden'), findsOneWidget); // page 1 of 139

    // One request, sent with our User-Agent, for the submitted text only.
    expect(searches(), hasLength(1));
    final request = searches().single;
    expect(request.url.queryParameters['q'], 'Haferflocken');
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
      lessThan(tester.getTopLeft(find.text('Online-Ergebnisse')).dy),
    );
  });

  testWidgets('tapping a hit opens its product page', (tester) async {
    final router = await openSearch(tester, 'Haferflocken');

    await tester.tap(find.text('Kernige Haferflocken'));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), Routes.product('20283360'));
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
    expect(find.text('Kernige Haferflocken'), findsNothing);

    online = true;
    await tester.tap(find.text('Nochmal versuchen'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Du bist offline.'), findsNothing);
    expect(find.text('Kernige Haferflocken'), findsOneWidget);
  });

  testWidgets('"Mehr laden" adds the next page and keeps the first', (
    tester,
  ) async {
    await openSearch(tester, 'Haferflocken');

    await tester.tap(find.text('Mehr laden'));
    await tester.pumpAndSettle();

    expect(find.text('Kernige Haferflocken'), findsOneWidget);
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
    expect(find.text('Online results'), findsOneWidget);
    expect(
      find.text('Crownfield\n372 kcal per 100 g · Nutri-Score: A'),
      findsOneWidget,
    );
    expect(find.text('Load more'), findsOneWidget);
  });
}
