import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/add_food_page.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/router.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

const yoghurtCode = '4260426710013';

void main() {
  late AppDatabase db;

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  /// Starts the app on a tall screen (the whole form is visible) and opens
  /// [location].
  Future<GoRouter> open(
    WidgetTester tester,
    String location, {
    Locale locale = const Locale('de'),
  }) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(tester, db: db, locale: locale);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(FoodTrackerApp)),
    ).read(routerProvider);
    unawaited(router.push(location));
    await tester.pumpAndSettle();
    return router;
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> fill(WidgetTester tester, Map<String, String> values) async {
    for (final MapEntry(:key, :value) in values.entries) {
      await tester.enterText(field(key), value);
    }
    await tester.pump();
  }

  /// The form's list (text fields have their own inner scrollables).
  Finder formList() => find
      .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
      .first;

  Future<void> save(WidgetTester tester, {String label = 'Speichern'}) async {
    // On small screens the button is built only after scrolling down.
    await tester.scrollUntilVisible(
      find.text(label),
      300,
      scrollable: formList(),
    );
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  String textOf(WidgetTester tester, String label) => tester
      .widget<TextField>(
        find.descendant(of: field(label), matching: find.byType(TextField)),
      )
      .controller!
      .text;

  testWidgets('validation: required fields, ranges and "part of" rules', (
    tester,
  ) async {
    await open(tester, Routes.newFood());

    await save(tester);
    expect(find.text('Bitte gib einen Namen ein.'), findsOneWidget);
    expect(find.text('Bitte gib die Kalorien ein.'), findsOneWidget);

    await fill(tester, {
      'Name *': 'Test',
      'Energie *': '1000',
      'Fett': '5',
      'gesättigte Fettsäuren': '6',
      'Kohlenhydrate': '10',
      'Zucker': '12',
      'Eiweiß': '101',
      'Salz': 'viel',
      'Bezeichnung der Portion': '1 Scheibe',
    });

    expect(find.text('Bitte gib einen Namen ein.'), findsNothing);
    expect(find.text('Erlaubt: 0 bis 900'), findsOneWidget);
    expect(find.text('Erlaubt: 0 bis 100'), findsOneWidget);
    expect(find.text('Kann nicht mehr sein als Fett.'), findsOneWidget);
    expect(
      find.text('Kann nicht mehr sein als Kohlenhydrate.'),
      findsOneWidget,
    );
    expect(find.text('Bitte gib eine Zahl ein.'), findsOneWidget);
    expect(
      find.text('Gib dazu auch die Menge einer Portion an.'),
      findsOneWidget,
    );

    await save(tester);
    expect(await db.select(db.foods).get(), isEmpty);
  });

  testWidgets('saves a new own food (decimal comma) and opens it', (
    tester,
  ) async {
    final router = await open(tester, Routes.newFood());

    await fill(tester, {
      'Name *': ' Dinkelbrot ',
      'Marke (optional)': 'Bäckerei Korn',
      'Energie *': '245',
      'Fett': '1,5',
      'gesättigte Fettsäuren': '0,3',
      'Kohlenhydrate': '45.2',
      'Salz': '1,05',
      'Menge einer Portion': '50',
      'Bezeichnung der Portion': '1 Scheibe',
    });
    await save(tester);

    final food = (await db.select(db.foods).get()).single;
    expect(food.source, FoodSource.user);
    expect(food.name, 'Dinkelbrot');
    expect(food.brand, 'Bäckerei Korn');
    expect(food.kcal, 245);
    expect(food.fat, 1.5);
    expect(food.saturatedFat, 0.3);
    expect(food.carbs, 45.2);
    expect(food.sugars, isNull); // empty = unknown, not 0
    expect(food.salt, 1.05);
    expect(food.servingSize, 50);
    expect(food.servingLabel, '1 Scheibe');
    expect(food.isLiquid, isFalse);

    // The form was replaced by the new food's product page.
    expect(router.state.uri.toString(), Routes.food(food.id));
    expect(find.text('Dinkelbrot'), findsOneWidget);
  });

  testWidgets('drink switch stores values per 100 ml', (tester) async {
    await open(tester, Routes.newFood());

    expect(find.text('Nährwerte pro 100 g'), findsOneWidget);
    await tester.tap(find.text('Getränk (pro 100 ml)'));
    await tester.pumpAndSettle();
    expect(find.text('Nährwerte pro 100 ml'), findsOneWidget);

    await fill(tester, {'Name *': 'Hafermilch', 'Energie *': '46'});
    await save(tester);

    expect((await db.select(db.foods).get()).single.isLiquid, isTrue);
  });

  testWidgets('edit: prefilled with all decimals, saving updates the food', (
    tester,
  ) async {
    final id = await db
        .into(db.foods)
        .insert(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: 'Dinkelbrot',
            kcal: const Value(245),
            fat: const Value(1.5),
            salt: const Value(0.03),
            createdAt: testNow,
          ),
        );
    final router = await open(tester, Routes.food(id));
    await tester.tap(find.byTooltip('Bearbeiten'));
    await tester.pumpAndSettle();

    expect(find.text('Lebensmittel bearbeiten'), findsOneWidget);
    expect(textOf(tester, 'Name *'), 'Dinkelbrot');
    expect(textOf(tester, 'Fett'), '1,5');
    expect(textOf(tester, 'Salz'), '0,03'); // not rounded away

    await fill(tester, {'Energie *': '250'});
    await save(tester);

    final food = (await db.select(db.foods).get()).single;
    expect(food.kcal, 250);
    expect(food.salt, 0.03);
    // Back on the product page.
    expect(router.state.uri.toString(), Routes.food(id));
  });

  testWidgets('a barcode from the scan is prefilled from the cached product', (
    tester,
  ) async {
    // Open Food Facts knows the product, but without calories.
    await db
        .into(db.foods)
        .insert(
          FoodsCompanion.insert(
            source: FoodSource.openFoodFacts,
            barcode: const Value(yoghurtCode),
            name: 'Naturjoghurt',
            brand: const Value('Hofmolkerei'),
            fat: const Value(3.5),
            nutriScore: const Value('B'),
            createdAt: testNow,
          ),
        );
    await open(tester, Routes.newFood(barcode: yoghurtCode));

    expect(textOf(tester, 'Name *'), 'Naturjoghurt');
    expect(textOf(tester, 'Marke (optional)'), 'Hofmolkerei');
    expect(textOf(tester, 'Fett'), '3,5');
    expect(textOf(tester, 'Barcode'), yoghurtCode);
    final barcodeField = tester.widget<TextField>(
      find.descendant(of: field('Barcode'), matching: find.byType(TextField)),
    );
    expect(barcodeField.readOnly, isTrue);

    await fill(tester, {'Energie *': '67'});
    await save(tester);

    // The same row became the own food: no second product with this code.
    final food = (await db.select(db.foods).get()).single;
    expect(food.source, FoodSource.user);
    expect(food.barcode, yoghurtCode);
    expect(food.kcal, 67);
    expect(food.nutriScore, isNull); // OFF-only data does not fit any more
  });

  testWidgets('in the add-food flow: save, add, back on Today', (tester) async {
    final breakfast = await (db.select(
      db.mealSlots,
    )..where((s) => s.builtIn.equals('breakfast'))).getSingle();
    final router = await open(
      tester,
      Routes.addFood('2026-11-14', breakfast.id),
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AddFoodPage),
        matching: find.text('Eigenes Lebensmittel'),
      ),
    );
    await tester.pumpAndSettle();

    await fill(tester, {'Name *': 'Dinkelbrot', 'Energie *': '245'});
    await save(tester);
    final id = (await db.select(db.foods).get()).single.id;
    expect(
      router.state.uri.toString(),
      Routes.food(id, day: '2026-11-14', mealId: breakfast.id),
    );

    await tester.ensureVisible(find.text('Hinzufügen'));
    await tester.tap(find.text('Hinzufügen'));
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), Routes.today);
    expect((await db.select(db.diaryEntries).get()).single.foodId, id);
  });

  testWidgets('delete asks first and keeps diary entries', (tester) async {
    final id = await db
        .into(db.foods)
        .insert(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: 'Dinkelbrot',
            kcal: const Value(245),
            createdAt: testNow,
          ),
        );
    await open(tester, Routes.editFood(id));

    await tester.tap(find.byTooltip('Löschen'));
    await tester.pumpAndSettle();
    expect(find.text('„Dinkelbrot“ löschen?'), findsOneWidget);
    expect(
      find.text('Einträge in deinem Tagebuch bleiben erhalten.'),
      findsOneWidget,
    );

    // "Abbrechen" keeps the food.
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(await db.select(db.foods).get(), hasLength(1));

    await tester.tap(find.byTooltip('Löschen'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Löschen'));
    await tester.pumpAndSettle();

    expect(await db.select(db.foods).get(), isEmpty);
    expect(find.text('„Dinkelbrot“ gelöscht'), findsOneWidget);
    expect(find.text('Lebensmittel bearbeiten'), findsNothing);
  });

  testWidgets('phone size at text scale 2.0: all fields are checked and the '
      'first error is shown', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpFoodTrackerApp(tester, db: db);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(FoodTrackerApp)),
    ).read(routerProvider);
    unawaited(router.push(Routes.newFood(barcode: yoghurtCode)));
    await tester.pumpAndSettle();

    await save(tester);
    expect(tester.takeException(), isNull);
    // Saving was refused and the first error was scrolled into view.
    final error = tester.getRect(find.text('Bitte gib einen Namen ein.'));
    expect(error.top, greaterThanOrEqualTo(0));
    expect(error.bottom, lessThanOrEqualTo(844));
    expect(await db.select(db.foods).get(), isEmpty);
  });

  testWidgets('English texts', (tester) async {
    await open(tester, Routes.newFood(), locale: const Locale('en'));

    expect(find.text('New food'), findsOneWidget);
    await save(tester, label: 'Save');
    expect(find.text('Please enter a name.'), findsOneWidget);
    expect(find.text('Please enter the calories.'), findsOneWidget);

    await fill(tester, {'Fat': '2', 'Saturates': '3'});
    expect(find.text("Can't be more than fat."), findsOneWidget);
  });
}
