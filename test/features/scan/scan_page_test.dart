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
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/off_fixtures.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/scan_helpers.dart';

const crisps = '4003586100313'; // recorded product: chipsfrisch ungarisch

void main() {
  late AppDatabase db;
  late FakeScanner scanner;

  setUp(() {
    db = newTestDatabase();
    scanner = FakeScanner();
  });

  tearDown(() => db.close());

  /// Open Food Facts answers with the crisps for every product and with
  /// the recorded search page for every search.
  final client = MockClient((request) async {
    if (request.url.host == 'search.openfoodfacts.org') {
      return jsonResponse(fixtureText('search_haferflocken.json'));
    }
    return jsonResponse(fixtureText('crisps.json'));
  });

  Future<GoRouter> startApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(
      tester,
      db: db,
      client: client,
      extraOverrides: [scanner.override, offClientWithoutDelays(client)],
    );
    return ProviderScope.containerOf(
      tester.element(find.byType(FoodTrackerApp)),
    ).read(routerProvider);
  }

  String location(GoRouter router) => router.state.uri.toString();

  Future<int> food(String name, {DateTime? viewedAt}) => db
      .into(db.foods)
      .insert(
        FoodsCompanion.insert(
          source: FoodSource.user,
          name: name,
          kcal: const Value(100),
          lastViewedAt: Value(viewedAt),
          createdAt: testNow,
        ),
      );

  Future<void> openScanTab(WidgetTester tester) async {
    await tester.tap(find.text('Scannen'));
    await tester.pumpAndSettle();
  }

  group('ScanPage', () {
    testWidgets('shows the camera area and "Zuletzt angesehen", newest first', (
      tester,
    ) async {
      await food('Apfel', viewedAt: testNow.subtract(const Duration(days: 1)));
      await food('Banane', viewedAt: testNow);
      await food('Nie angesehen');
      await startApp(tester);
      await openScanTab(tester);

      expect(find.byKey(FakeScanner.boxKey), findsOneWidget);
      expect(find.text('Zuletzt angesehen'), findsOneWidget);
      expect(find.text('Nie angesehen'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Banane')).dy,
        lessThan(tester.getTopLeft(find.text('Apfel')).dy),
      );
    });

    testWidgets('empty list shows a hint', (tester) async {
      await startApp(tester);
      await openScanTab(tester);

      expect(
        find.text(
          'Hier erscheinen Produkte, die du gescannt oder gesucht hast.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping a recent product opens it', (tester) async {
      final id = await food('Banane', viewedAt: testNow);
      final router = await startApp(tester);
      await openScanTab(tester);

      await tester.tap(find.text('Banane'));
      await tester.pumpAndSettle();

      expect(location(router), Routes.food(id));
    });

    testWidgets('submitting the search field opens the results', (
      tester,
    ) async {
      final router = await startApp(tester);
      await openScanTab(tester);

      await tester.enterText(find.byType(TextField), '  Haferflocken ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(location(router), Routes.search('Haferflocken'));
      expect(find.text('Suche: Haferflocken'), findsOneWidget);
    });

    testWidgets('an empty search does nothing', (tester) async {
      final router = await startApp(tester);
      await openScanTab(tester);

      await tester.tap(find.byTooltip('Suchen'));
      await tester.pumpAndSettle();

      expect(location(router), Routes.scan);
    });

    testWidgets('a scanned barcode opens the product; back returns', (
      tester,
    ) async {
      final router = await startApp(tester);
      await openScanTab(tester);

      unawaited(scanner.scan(crisps));
      await tester.pumpAndSettle();
      expect(location(router), Routes.product(crisps));
      expect(find.text('chipsfrisch ungarisch'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(location(router), Routes.scan);
      // The product page counted as "viewed".
      expect(find.text('chipsfrisch ungarisch'), findsOneWidget);
    });
  });

  testWidgets('ScanPage at text scale 2.0 on a phone: no overflow', (
    tester,
  ) async {
    await food('Banane', viewedAt: testNow);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpFoodTrackerApp(
      tester,
      db: db,
      client: client,
      extraOverrides: [scanner.override],
    );
    await openScanTab(tester);

    expect(tester.takeException(), isNull);
    expect(find.byKey(FakeScanner.boxKey), findsOneWidget);
  });

  group('ScannerPage (add-food flow)', () {
    Future<int> breakfastId() async => (await (db.select(
      db.mealSlots,
    )..where((s) => s.builtIn.equals('breakfast'))).getSingle()).id;

    /// The "Scannen" button of the add-food page (the tab bar has one too).
    Future<void> tapScanButton(WidgetTester tester) async {
      await tester.tap(
        find.descendant(
          of: find.byType(AddFoodPage),
          matching: find.text('Scannen'),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the product replaces the scanner: back goes to the add page', (
      tester,
    ) async {
      final mealId = await breakfastId();
      final router = await startApp(tester);
      unawaited(router.push(Routes.addFood('2026-11-14', mealId)));
      await tester.pumpAndSettle();
      await tapScanButton(tester);
      expect(find.text('Barcode scannen'), findsOneWidget);

      unawaited(scanner.scan(crisps));
      await tester.pumpAndSettle();
      expect(
        location(router),
        Routes.product(crisps, day: '2026-11-14', mealId: mealId),
      );

      router.pop();
      await tester.pumpAndSettle();
      expect(location(router), Routes.addFood('2026-11-14', mealId));
    });

    testWidgets('after "Hinzufügen" the user is back on Today', (tester) async {
      final mealId = await breakfastId();
      final router = await startApp(tester);
      unawaited(router.push(Routes.addFood('2026-11-14', mealId)));
      await tester.pumpAndSettle();
      await tapScanButton(tester);

      unawaited(scanner.scan(crisps));
      await tester.pumpAndSettle();
      // The sticky button on the product page.
      await tester.tap(find.byType(CtaButton));
      await tester.pumpAndSettle();

      expect(location(router), Routes.today);
      final entry = (await db.select(db.diaryEntries).get()).single;
      expect(entry.name, 'chipsfrisch ungarisch');
      expect(entry.mealSlotId, mealId);
    });
  });
}
