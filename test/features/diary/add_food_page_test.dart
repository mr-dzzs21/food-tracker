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
];

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

  Future<void> typeSearch(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    // The local filter waits a moment after the last key press.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

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

  testWidgets('typing filters the foods on the device (no online search)', (
    tester,
  ) async {
    await insertFood('Müsli Classic', usedAt: testNow);
    await insertFood('Apfel', usedAt: testNow);
    await openAddFood(tester);

    await typeSearch(tester, 'mü');

    expect(find.text('Auf deinem Gerät'), findsOneWidget);
    expect(find.text('Müsli Classic'), findsOneWidget);
    expect(find.text('Apfel'), findsNothing);
    expect(find.text('Zuletzt'), findsNothing); // segments are hidden
    expect(requests, isEmpty);

    // Nothing found: a hint, and the online search is one tap away.
    await typeSearch(tester, 'Haferflocken');
    expect(
      find.text(
        'Nichts bei den Grundnahrungsmitteln und auf deinem Gerät gefunden.',
      ),
      findsOneWidget,
    );
    expect(find.text('Auf deinem Gerät'), findsNothing);
    expect(inPage('Online suchen'), findsOneWidget);
    expect(requests, isEmpty);

    // Clearing the field brings the segments back.
    await typeSearch(tester, '');
    expect(find.text('Apfel'), findsOneWidget);
  });

  testWidgets('submitting searches online and shows the results inline', (
    tester,
  ) async {
    final router = await openAddFood(tester);

    await typeSearch(tester, 'Haferflocken');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Online (Deutschland)'), findsOneWidget);
    expect(find.text('Zarte Haferflocken'), findsOneWidget);
    expect(inPage('Online suchen'), findsNothing);
    expect(requests, hasLength(1));

    await tester.tap(find.text('Zarte Haferflocken'));
    await tester.pumpAndSettle();
    expect(
      router.state.uri.toString(),
      Routes.product('4260070610493', day: today, mealId: breakfastId),
    );
  });

  testWidgets('basic foods show while typing, first; "Online suchen" adds '
      'the online results last', (tester) async {
    await insertFood('Haferflocken Omas Art', source: FoodSource.user);
    await openAddFood(tester, basicFoods: basicFoods);

    await typeSearch(tester, 'haferflocken');

    double top(String text) => tester.getTopLeft(inPage(text)).dy;
    expect(inPage('Grundnahrungsmittel'), findsOneWidget);
    expect(inPage('Hafer Flocken'), findsOneWidget);
    expect(inPage('Apfel roh'), findsNothing);
    expect(top('Grundnahrungsmittel'), lessThan(top('Hafer Flocken')));
    expect(top('Hafer Flocken'), lessThan(top('Auf deinem Gerät')));
    expect(top('Auf deinem Gerät'), lessThan(top('Haferflocken Omas Art')));
    expect(requests, isEmpty); // still nothing sent while typing

    await tester.tap(inPage('Online suchen'));
    await tester.pumpAndSettle();

    expect(requests, hasLength(1));
    expect(top('Haferflocken Omas Art'), lessThan(top('Online (Deutschland)')));
    expect(top('Online (Deutschland)'), lessThan(top('Zarte Haferflocken')));
    expect(inPage('Grundnahrungsmittel'), findsOneWidget);
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
    await pumpFoodTrackerApp(tester, db: db, basicFoods: basicFoods);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(FoodTrackerApp)),
    ).read(routerProvider);
    unawaited(router.push(Routes.addFood(today, breakfastId)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(inPage('Favoriten'), findsOneWidget);

    // The search sections and "Online suchen" fit, too.
    await typeSearch(tester, 'haferflocken');
    expect(tester.takeException(), isNull);
    expect(inPage('Hafer Flocken'), findsOneWidget);
    await tester.scrollUntilVisible(
      inPage('Online suchen'),
      200,
      scrollable: find
          .ancestor(
            of: inPage('Hafer Flocken'),
            matching: find.byType(Scrollable),
          )
          .first,
    );
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
