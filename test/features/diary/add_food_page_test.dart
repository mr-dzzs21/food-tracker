import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/core/widgets/buttons.dart';
import 'package:food_tracker/core/widgets/pill_choices.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/add_food_page.dart';
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

const today = '2026-11-14';

/// Basic foods (BLS) for the search; the real file is not loaded in tests.
const basicFoods = [
  BasicFood(
    code: 'C133000',
    nameDe: 'Hafer Flocken',
    nameEn: 'Oat flakes',
    nutrients: Nutrients(kcal: 348, fat: 6.7),
  ),
  BasicFood(
    code: 'F110100',
    nameDe: 'Apfel roh',
    nameEn: 'Apple raw',
    nutrients: Nutrients(kcal: 58),
  ),
  BasicFood(
    code: 'M710100',
    nameDe: 'Skyr, Frischkäse < 10 % Fett i. Tr.',
    nameEn: 'Skyr, fresh cheese < 10 % fat in dry matter',
    nutrients: Nutrients(kcal: 64, protein: 10.4),
  ),
];

/// Simple foods for the search; the real files are not loaded in tests.
const simpleFoods = [
  SimpleFood(
    order: 1,
    key: 'skyr-natur',
    nameDe: 'Skyr natur',
    nameEn: 'Skyr, plain',
    synonymsDe: ['Skyr pur'],
    nutrients: Nutrients(kcal: 64, fat: 0.2, protein: 10.4),
    portionGrams: 150,
    portionDe: '1 Portion',
    portionEn: '1 serving',
    blsCode: 'M710100',
  ),
  SimpleFood(
    order: 2,
    key: 'skyr-vanille',
    nameDe: 'Skyr Vanille',
    nameEn: 'Skyr, vanilla',
    nutrients: Nutrients(kcal: 75, fat: 0.2, protein: 9.2),
    portionGrams: 150,
    portionDe: '1 Portion',
    portionEn: '1 serving',
    offProductCount: 23,
  ),
  SimpleFood(
    order: 3,
    key: 'reis-gekocht',
    nameDe: 'Reis gekocht',
    nameEn: 'Rice, cooked',
    nutrients: Nutrients(kcal: 117),
    blsCode: 'C352032',
  ),
];

const blsSource =
    'Daten: Bundeslebensmittelschlüssel 4.0, Max Rubner-Institut (CC BY 4.0)';

void main() {
  late AppDatabase db;
  late List<http.Request> requests;
  late int breakfastId;

  setUp(() async {
    db = newTestDatabase();
    requests = [];
    breakfastId = (await (db.select(
      db.mealSlots,
    )..where((s) => s.builtIn.equals('breakfast'))).getSingle()).id;
  });

  tearDown(() => db.close());

  Future<int> insertFood(
    String name, {
    FoodSource source = FoodSource.openFoodFacts,
    bool favourite = false,
    DateTime? usedAt,
  }) => db
      .into(db.foods)
      .insert(
        FoodsCompanion.insert(
          source: source,
          name: name,
          kcal: const Value(100),
          isFavourite: Value(favourite),
          lastUsedAt: Value(usedAt),
          createdAt: testNow,
        ),
      );

  /// Opens the add-food page for breakfast today, on top of "Heute".
  Future<GoRouter> openAddFood(
    WidgetTester tester, {
    Locale locale = const Locale('de'),
    List<BasicFood> basicFoods = const [],
    List<SimpleFood> simpleFoods = const [],
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final client = MockClient((request) async {
      requests.add(request);
      return jsonResponse(fixtureText('search_haferflocken.json'));
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
    unawaited(router.push(Routes.addFood(today, breakfastId)));
    await tester.pumpAndSettle();
    return router;
  }

  Finder inPage(String text) =>
      find.descendant(of: find.byType(AddFoodPage), matching: find.text(text));

  /// Types [text] and waits until everything is shown, the brand products
  /// too (they are loaded 700 ms after the last key press).
  Future<void> typeSearch(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
  }

  double top(WidgetTester tester, String text) =>
      tester.getTopLeft(inPage(text)).dy;

  testWidgets('title, segments and their lists', (tester) async {
    await insertFood('Apfel', usedAt: testNow);
    await insertFood('Müsli', favourite: true);
    await insertFood('Mein Brot', source: FoodSource.user);
    await openAddFood(tester);

    expect(find.text('Frühstück · Heute, 14. Nov.'), findsOneWidget);

    // "Zuletzt" is selected first: only foods that were logged before.
    expect(find.text('Apfel'), findsOneWidget);
    expect(find.text('Müsli'), findsNothing);
    expect(find.text('Mein Brot'), findsNothing);

    await tester.tap(find.text('Favoriten'));
    await tester.pumpAndSettle();
    expect(find.text('Müsli'), findsOneWidget);
    expect(find.text('Apfel'), findsNothing);

    await tester.tap(find.text('Eigene'));
    await tester.pumpAndSettle();
    expect(find.text('Mein Brot'), findsOneWidget);
    expect(find.text('Müsli'), findsNothing);
  });

  testWidgets('the segments are pills; the chosen one is selected', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openAddFood(tester);

    bool isSelected(String label) {
      final pill = find.ancestor(
        of: inPage(label),
        matching: find.byType(Pill),
      );
      expect(
        tester.getSemantics(pill),
        isSemantics(
          label: label,
          isButton: true,
          isSelected: tester.widget<Pill>(pill).selected,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      return tester.widget<Pill>(pill).selected;
    }

    expect(isSelected('Zuletzt'), isTrue);
    expect(isSelected('Favoriten'), isFalse);
    await tester.tap(inPage('Favoriten'));
    await tester.pumpAndSettle();
    expect(isSelected('Favoriten'), isTrue);
    expect(isSelected('Zuletzt'), isFalse);
    expect(isSelected('Eigene'), isFalse);
    // Scan and own food are the two big buttons at the top.
    expect(
      find.descendant(
        of: find.byType(CtaButton),
        matching: find.text('Scannen'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(TonalButton),
        matching: find.text('Eigenes Lebensmittel'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('empty lists explain what to do', (tester) async {
    await openAddFood(tester);

    expect(
      find.text(
        'Noch leer. Was du in dein Tagebuch einträgst, erscheint hier.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Favoriten'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Noch keine Favoriten. Tippe auf einer Produktseite auf den Stern.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Eigene'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Noch keine eigenen Lebensmittel. Leg eins mit „Eigenes Lebensmittel“ '
        'an.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tapping a food opens it for this meal; after "Hinzufügen" '
      'the user is back on Today', (tester) async {
    final id = await insertFood('Apfel', usedAt: testNow);
    final router = await openAddFood(tester);

    await tester.tap(find.text('Apfel'));
    await tester.pumpAndSettle();
    expect(
      router.state.uri.toString(),
      Routes.food(id, day: today, mealId: breakfastId),
    );

    // The sticky button on the product page.
    await tester.tap(find.byType(CtaButton));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), Routes.today);
    final entry = (await db.select(db.diaryEntries).get()).single;
    expect(entry.foodId, id);
    expect(entry.mealSlotId, breakfastId);
    expect(entry.day, today);
  });

  testWidgets('typing shows the matches on the device at once; the brand '
      'products follow when the user stops typing', (tester) async {
    await insertFood('Müsli Classic', usedAt: testNow);
    await insertFood('Apfel', usedAt: testNow);
    await openAddFood(tester);

    await tester.enterText(find.byType(TextField), 'mü');
    // The lists on the device wait only 250 ms.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Auf deinem Gerät'), findsOneWidget);
    expect(find.text('Müsli Classic'), findsOneWidget);
    expect(find.text('Apfel'), findsNothing);
    expect(find.text('Zuletzt'), findsNothing); // segments are hidden
    // The brand section is coming, but nothing was sent yet.
    expect(inPage('Markenprodukte (Deutschland)'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(requests, isEmpty);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(requests, hasLength(1));
    expect(
      requests.single.url.queryParameters['q'],
      'mü countries:"en:germany"',
    );
    expect(find.text('Zarte Haferflocken'), findsOneWidget);

    // Clearing the field brings the segments back.
    await typeSearch(tester, '');
    expect(find.text('Apfel'), findsOneWidget);
    expect(inPage('Markenprodukte (Deutschland)'), findsNothing);
    expect(requests, hasLength(1));
  });

  testWidgets('the online search runs once, 700 ms after the last key press', (
    tester,
  ) async {
    await openAddFood(tester);

    for (final text in ['s', 'sk', 'sky', 'skyr']) {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pump(const Duration(milliseconds: 499));
    expect(requests, isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(requests, hasLength(1));
    expect(
      requests.single.url.queryParameters['q'],
      'skyr countries:"en:germany"',
    );
    // One letter is not searched online.
    await typeSearch(tester, 's');
    expect(requests, hasLength(1));
    expect(inPage('Markenprodukte (Deutschland)'), findsNothing);
  });

  testWidgets('submitting searches online at once and shows the results '
      'inline', (tester) async {
    final router = await openAddFood(tester);

    await tester.enterText(find.byType(TextField), 'Haferflocken');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(inPage('Markenprodukte (Deutschland)'), findsOneWidget);
    expect(find.text('Zarte Haferflocken'), findsOneWidget);
    // The waiting search was dropped: one request, not two.
    expect(requests, hasLength(1));

    await tester.tap(find.text('Zarte Haferflocken'));
    await tester.pumpAndSettle();
    expect(
      router.state.uri.toString(),
      Routes.product('4260070610493', day: today, mealId: breakfastId),
    );
  });

  testWidgets('sections: foods, then the device, then brand products', (
    tester,
  ) async {
    await insertFood('Skyr mit Honig', source: FoodSource.user);
    await openAddFood(tester, simpleFoods: simpleFoods, basicFoods: basicFoods);

    await typeSearch(tester, 'skyr');

    expect(top(tester, 'Lebensmittel'), lessThan(top(tester, 'Skyr natur')));
    expect(top(tester, 'Skyr natur'), lessThan(top(tester, 'Skyr Vanille')));
    expect(
      top(tester, 'Skyr Vanille'),
      lessThan(top(tester, 'Auf deinem Gerät')),
    );
    expect(
      top(tester, 'Auf deinem Gerät'),
      lessThan(top(tester, 'Skyr mit Honig')),
    );
    expect(
      top(tester, 'Skyr mit Honig'),
      lessThan(top(tester, 'Markenprodukte (Deutschland)')),
    );
    expect(
      top(tester, 'Markenprodukte (Deutschland)'),
      lessThan(top(tester, 'Zarte Haferflocken')),
    );
    expect(inPage('Reis gekocht'), findsNothing); // does not match
    // Short rows: portion below the name, kcal per 100 g on the right.
    expect(inPage('1 Portion (150 g)'), findsNWidgets(2));
    expect(inPage('64 kcal'), findsOneWidget);
    expect(
      inPage(
        'Durchschnittswerte: Bundeslebensmittelschlüssel 4.0, Max '
        'Rubner-Institut (CC BY 4.0), und Open Food Facts (ODbL)',
      ),
      findsOneWidget,
    );
    // Brand products: brand below the name (from the fixture).
    expect(inPage('Spielberger Mühle'), findsOneWidget);
    expect(inPage('355 kcal'), findsOneWidget);
  });

  // Found on the iOS simulator: with semantics on (VoiceOver, integration
  // tests) typing a search crashed in Flutter's semantics update.
  testWidgets('typing a search works with the screen reader on', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openAddFood(tester, simpleFoods: simpleFoods, basicFoods: basicFoods);

    await typeSearch(tester, 'skyr');
    await typeSearch(tester, 'reis');
    await typeSearch(tester, 'skyr');

    expect(tester.takeException(), isNull);
    expect(inPage('Skyr natur'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the technical BLS list waits behind "Weitere Lebensmittel '
      '(BLS)"; without a simple food it shows at once', (tester) async {
    await openAddFood(tester, simpleFoods: simpleFoods, basicFoods: basicFoods);
    const blsSkyr = 'Skyr, Frischkäse < 10 % Fett i. Tr.';

    await typeSearch(tester, 'skyr');
    expect(inPage('Skyr natur'), findsOneWidget);
    expect(inPage(blsSkyr), findsNothing);
    expect(inPage(blsSource), findsNothing);

    await tester.tap(inPage('Weitere Lebensmittel (BLS)'));
    await tester.pumpAndSettle();
    expect(inPage(blsSkyr), findsOneWidget);
    expect(inPage(blsSource), findsOneWidget);
    expect(top(tester, 'Skyr Vanille'), lessThan(top(tester, blsSkyr)));

    await tester.tap(inPage('Weitere Lebensmittel ausblenden'));
    await tester.pumpAndSettle();
    expect(inPage(blsSkyr), findsNothing);

    // No simple food for "apfel": the BLS foods are the foods.
    await typeSearch(tester, 'apfel');
    expect(inPage('Lebensmittel'), findsOneWidget);
    expect(inPage('Apfel roh'), findsOneWidget);
    expect(inPage('Weitere Lebensmittel (BLS)'), findsNothing);
    expect(inPage(blsSource), findsOneWidget);
  });

  testWidgets('a simple food opens with its portion and is added like any '
      'other food', (tester) async {
    final router = await openAddFood(tester, simpleFoods: simpleFoods);

    await typeSearch(tester, 'skyr');
    await tester.tap(inPage('Skyr natur'));
    await tester.pumpAndSettle();

    final food = (await db.select(db.foods).get()).single;
    expect(food.source, FoodSource.bls);
    expect(food.externalId, 'M710100');
    expect(food.name, 'Skyr natur');
    expect(
      router.state.uri.toString(),
      Routes.food(food.id, day: today, mealId: breakfastId),
    );
    // The product page: averages, the typical portion chosen (a
    // non-breaking space keeps "150 g" together in the pill).
    expect(find.text('Durchschnittswerte'), findsOneWidget);
    expect(find.text('1 Portion (150\u00A0g)'), findsOneWidget);

    await tester.tap(find.byType(CtaButton));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), Routes.today);
    final entry = (await db.select(db.diaryEntries).get()).single;
    expect(entry.foodId, food.id);
    expect(entry.name, 'Skyr natur');
    expect(entry.amount, 150);
    expect(entry.kcal, 64);
  });

  testWidgets('an Open Food Facts average names how many products it comes '
      'from', (tester) async {
    await openAddFood(tester, simpleFoods: simpleFoods);

    await typeSearch(tester, 'skyr vanille');
    await tester.tap(inPage('Skyr Vanille'));
    await tester.pumpAndSettle();

    final food = (await db.select(db.foods).get()).single;
    expect(food.source, FoodSource.offAverage);
    expect(food.externalId, 'skyr-vanille');
    expect(find.text('Durchschnittswerte'), findsOneWidget);
    // The tall test screen shows the whole product page, footer included.
    expect(
      find.text(
        'Durchschnitt aus 23 Produkten von Open Food Facts. Einzelne '
        'Produkte können abweichen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Daten: Open Food Facts (ODbL)'), findsOneWidget);
  });

  testWidgets('a basic food is added like any other food', (tester) async {
    final router = await openAddFood(tester, basicFoods: basicFoods);

    await typeSearch(tester, 'apfel');
    await tester.tap(inPage('Apfel roh'));
    await tester.pumpAndSettle();

    final food = (await db.select(db.foods).get()).single;
    expect(food.source, FoodSource.bls);
    expect(food.externalId, 'F110100');
    expect(
      router.state.uri.toString(),
      Routes.food(food.id, day: today, mealId: breakfastId),
    );

    await tester.tap(find.byType(CtaButton));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), Routes.today);
    final entry = (await db.select(db.diaryEntries).get()).single;
    expect(entry.foodId, food.id);
    expect(entry.name, 'Apfel roh');
    expect(entry.kcal, 58);
    // It is a normal food now: "Zuletzt" lists it.
    expect((await db.select(db.foods).getSingle()).lastUsedAt, testNow);
  });

  testWidgets('"Eigenes Lebensmittel" opens the form for this meal', (
    tester,
  ) async {
    final router = await openAddFood(tester);

    await tester.tap(inPage('Eigenes Lebensmittel'));
    await tester.pumpAndSettle();

    expect(
      router.state.uri.toString(),
      Routes.newFood(day: today, mealId: breakfastId),
    );
    expect(find.text('Neues Lebensmittel'), findsOneWidget);
  });

  testWidgets('phone size at text scale 2.0: no overflow', (tester) async {
    await insertFood(
      'Haferflocken kernig mit einem langen Namen',
      usedAt: testNow,
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpFoodTrackerApp(
      tester,
      db: db,
      basicFoods: basicFoods,
      simpleFoods: simpleFoods,
      extraOverrides: [offClientWithoutDelays(offlineClient())],
    );
    final router = ProviderScope.containerOf(
      tester.element(find.byType(FoodTrackerApp)),
    ).read(routerProvider);
    unawaited(router.push(Routes.addFood(today, breakfastId)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(inPage('Favoriten'), findsOneWidget);

    // The search sections fit, too (offline: the brand part says so).
    await typeSearch(tester, 'skyr');
    expect(tester.takeException(), isNull);
    expect(inPage('Skyr natur'), findsOneWidget);
    await tester.scrollUntilVisible(
      inPage('Nochmal versuchen'),
      200,
      scrollable: find
          .ancestor(of: inPage('Skyr natur'), matching: find.byType(Scrollable))
          .first,
    );
    expect(inPage('Markenprodukte (Deutschland)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English texts', (tester) async {
    await openAddFood(tester, locale: const Locale('en'));

    expect(find.text('Breakfast · Today, Nov 14'), findsOneWidget);
    expect(find.text('Recent'), findsOneWidget);
    expect(find.text('Favourites'), findsOneWidget);
    expect(find.text('My foods'), findsOneWidget);
    expect(inPage('Scan'), findsOneWidget);
    expect(inPage('Own food'), findsOneWidget);
  });
}
