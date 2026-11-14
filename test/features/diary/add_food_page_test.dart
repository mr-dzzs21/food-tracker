import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/core/widgets/buttons.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/add_food_page.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/router.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/off_fixtures.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/scan_helpers.dart';

const today = '2026-11-14';

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

    // Nothing on the device: hint to the online search.
    await typeSearch(tester, 'Haferflocken');
    expect(
      find.text(
        'Auf deinem Gerät nichts gefunden. Tippe auf der Tastatur auf '
        '„Suchen“, um online zu suchen.',
      ),
      findsOneWidget,
    );
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

    expect(find.text('Online-Ergebnisse'), findsOneWidget);
    expect(find.text('Kernige Haferflocken'), findsOneWidget);
    expect(requests, hasLength(1));

    await tester.tap(find.text('Kernige Haferflocken'));
    await tester.pumpAndSettle();
    expect(
      router.state.uri.toString(),
      Routes.product('20283360', day: today, mealId: breakfastId),
    );
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
    await pumpFoodTrackerApp(tester, db: db);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(FoodTrackerApp)),
    ).read(routerProvider);
    unawaited(router.push(Routes.addFood(today, breakfastId)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(inPage('Favoriten'), findsOneWidget);
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
