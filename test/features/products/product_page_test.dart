import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/core/widgets/buttons.dart';
import 'package:food_tracker/core/widgets/pill_choices.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/features/products/product_repository.dart';
import 'package:food_tracker/features/products/widgets/rating_section.dart';
import 'package:food_tracker/router.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/off_fixtures.dart';
import '../../helpers/pump_app.dart';

// Barcodes of the recorded Open Food Facts responses in test/fixtures/off/.
const crisps = '4003586100313'; // rated food, Nutri-Score D, portion 30 g
const water = '42376095'; // not rated (water)
const sparse = '4260426710013'; // no categories → product type unknown
const unknown = '4099999999996'; // valid, but unknown at Open Food Facts

void main() {
  late AppDatabase db;
  late Future<http.Response> Function(http.Request) respond;
  late List<http.Request> requests;

  setUp(() {
    db = newTestDatabase();
    requests = [];
    respond = (request) async {
      final path = request.url.path;
      final fixture = switch (path) {
        _ when path.contains(crisps) => 'crisps.json',
        _ when path.contains(water) => 'water.json',
        _ when path.contains(sparse) => 'sparse_product.json',
        _ => 'not_found.json',
      };
      return jsonResponse(
        fixtureText(fixture),
        status: fixture == 'not_found.json' ? 404 : 200,
      );
    };
  });

  tearDown(() => db.close());

  http.Client client() => MockClient((request) {
    requests.add(request);
    return respond(request);
  });

  GoRouter routerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(FoodTrackerApp)))
          .read(routerProvider);

  /// Starts the app on a tall screen (everything visible without
  /// scrolling) and opens [location] on top of the Today tab.
  Future<GoRouter> open(
    WidgetTester tester,
    String location, {
    Locale locale = const Locale('de'),
    bool tall = true,
  }) async {
    if (tall) {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await pumpFoodTrackerApp(tester, db: db, client: client(), locale: locale);
    final router = routerOf(tester);
    unawaited(router.push(location));
    await tester.pumpAndSettle();
    return router;
  }

  /// Whether the pill with [label] is the selected one. Also checks that
  /// screen readers hear the same (a button, selected or not).
  bool isSelectedPill(WidgetTester tester, String label) {
    final pill = find.ancestor(
      of: find.text(label),
      matching: find.byType(Pill),
    );
    final selected = tester.widget<Pill>(pill).selected;
    expect(
      tester.getSemantics(pill),
      isSemantics(label: label, isButton: true, isSelected: selected),
    );
    return selected;
  }

  Future<MealSlot> slot(String builtIn) => (db.select(
    db.mealSlots,
  )..where((s) => s.builtIn.equals(builtIn))).getSingle();

  testWidgets('rated product: levels with icon, word and value; Nutri-Score '
      'as text', (tester) async {
    await open(tester, Routes.product(crisps));

    expect(find.text('chipsfrisch ungarisch'), findsOneWidget);
    expect(find.text('funny-frisch'), findsOneWidget);
    expect(find.text('Bewertung'), findsOneWidget);
    expect(find.text('pro 100 g'), findsNWidgets(2)); // info chip + table
    // Value and word of each level: fat high, saturates and salt medium,
    // sugars low.
    Finder inRating(String text) => find.descendant(
      of: find.byType(RatingSection),
      matching: find.text(text),
    );
    expect(inRating('33 g'), findsOneWidget);
    expect(inRating('hoch'), findsOneWidget);
    expect(inRating('mittel'), findsNWidgets(2));
    expect(inRating('niedrig'), findsOneWidget);
    expect(inRating('2,5 g'), findsOneWidget);
    expect(inRating('1,5 g'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.remove_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    expect(find.bySemanticsLabel('Fett: hoch, 33 g'), findsOneWidget);
    // A 2 × 2 grid: fat next to saturates, sugars below fat.
    final fat = tester.getRect(find.bySemanticsLabel('Fett: hoch, 33 g'));
    final sugars = tester.getRect(
      find.bySemanticsLabel('Zucker: niedrig, 2,5 g'),
    );
    final saturates = tester.getRect(
      find.bySemanticsLabel(RegExp('^gesättigte Fettsäuren: ')),
    );
    expect(saturates.top, fat.top);
    expect(saturates.left, greaterThan(fat.right));
    expect(sugars.left, fat.left);
    expect(sugars.top, greaterThan(fat.bottom));
    expect(find.bySemanticsLabel('Zucker: niedrig, 2,5 g'), findsOneWidget);
    expect(find.text('Ballaststoffquelle · 4,5 g'), findsOneWidget);
    expect(find.text('Nutri-Score: D (laut Open Food Facts)'), findsOneWidget);

    // Nutrition table per 100 g and per portion, attribution and link.
    expect(find.text('pro Portion (30 g)'), findsOneWidget);
    expect(find.text('533 kcal'), findsOneWidget);
    expect(find.text('Daten: Open Food Facts (ODbL)'), findsOneWidget);
    expect(find.text('Auf Open Food Facts ansehen'), findsOneWidget);

    // Opening the page counts as "Zuletzt angesehen".
    final food = (await db.select(db.foods).get()).single;
    expect(food.lastViewedAt, testNow);
    expect(requests, hasLength(1));
  });

  testWidgets('not rated: water shows the note instead of a traffic light', (
    tester,
  ) async {
    await open(tester, Routes.product(water));

    expect(find.text('Mineralwasser Still'), findsOneWidget);
    expect(find.text('Bewertung'), findsOneWidget);
    expect(
      find.textContaining('Für diese Produktart gibt es keine Ampel-Bewertung'),
      findsOneWidget,
    );
    expect(find.text('hoch'), findsNothing);
    expect(find.text('niedrig'), findsNothing);
  });

  testWidgets('not rated (English): unknown product type', (tester) async {
    await open(tester, Routes.product(sparse), locale: const Locale('en'));

    expect(find.text('Naturjoghurt'), findsOneWidget);
    expect(find.text('Rating'), findsOneWidget);
    expect(
      find.text(
        'The product type is unknown, so there is no traffic-light rating.',
      ),
      findsOneWidget,
    );
    expect(find.text('per 100 g'), findsNWidgets(2)); // info chip + table
    expect(find.text('Lunch'), findsOneWidget); // meal pill
    expect(
      find.textContaining(RegExp(r'^Add .+ g to Lunch · .+ kcal$')),
      findsOneWidget,
    );
  });

  testWidgets('not found: offers to create the food with this barcode', (
    tester,
  ) async {
    final router = await open(
      tester,
      Routes.product(unknown, day: '2026-11-14', mealId: 2),
    );

    expect(
      find.text(
        'Dieses Produkt kennen wir noch nicht. Du kannst es selbst eintragen.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Selbst eintragen'));
    await tester.pumpAndSettle();

    expect(
      router.state.uri.toString(),
      Routes.newFood(barcode: unknown, day: '2026-11-14', mealId: 2),
    );
    // The own-food form, with the scanned barcode filled in.
    expect(find.text('Neues Lebensmittel'), findsOneWidget);
    expect(find.text(unknown), findsOneWidget);
  });

  testWidgets('incomplete: no calories → "Werte ergänzen"', (tester) async {
    respond = (_) async => jsonResponse(fixtureText('no_energy.json'));
    final router = await open(tester, Routes.product(sparse));

    expect(
      find.text(
        'Für dieses Produkt fehlen Nährwerte. Du kannst sie selbst ergänzen.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Werte ergänzen'));
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), Routes.newFood(barcode: sparse));
  });

  testWidgets('offline: message and "Nochmal versuchen"', (tester) async {
    respond = (_) async => throw http.ClientException('offline');
    await open(tester, Routes.product(crisps));

    expect(find.textContaining('Du bist offline'), findsOneWidget);

    respond = (_) async => jsonResponse(fixtureText('crisps.json'));
    await tester.tap(find.text('Nochmal versuchen'));
    await tester.pumpAndSettle();
    expect(find.text('chipsfrisch ungarisch'), findsOneWidget);
  });

  testWidgets('add to diary: chosen amount and meal, back with a SnackBar', (
    tester,
  ) async {
    final dinner = await slot('dinner');
    await open(
      tester,
      Routes.product(crisps, day: '2026-11-13', mealId: dinner.id),
    );

    // Starts with one portion; the meal comes from the route.
    expect(find.widgetWithText(TextField, '30'), findsOneWidget);
    expect(find.text('160 kcal'), findsWidgets);
    expect(isSelectedPill(tester, 'Abendessen'), isTrue);
    expect(isSelectedPill(tester, 'Mittagessen'), isFalse);
    expect(find.text('Tag: Gestern, 13. Nov.'), findsOneWidget);
    // The sticky button says what will happen.
    expect(find.text('30 g zum Abendessen · 160 kcal'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '45,5');
    await tester.pumpAndSettle();
    // 533 kcal × 45.5 / 100 = 242.5 → 243
    expect(find.text('243 kcal'), findsOneWidget);

    await tester.tap(find.text('Snacks'));
    await tester.pumpAndSettle();
    expect(isSelectedPill(tester, 'Snacks'), isTrue);
    expect(find.text('45,5 g zu den Snacks · 243 kcal'), findsOneWidget);

    final haptics = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.tap(find.byType(CtaButton));
    await tester.pumpAndSettle();
    // A light tap in the hand confirms it.
    expect(haptics, ['HapticFeedbackType.lightImpact']);

    final entry = (await db.select(db.diaryEntries).get()).single;
    expect(entry.amount, 45.5);
    expect(entry.day, '2026-11-13');
    expect(entry.mealSlotId, (await slot('snacks')).id);
    expect(entry.name, 'chipsfrisch ungarisch');
    expect(entry.kcal, 533);
    final food = (await db.select(db.foods).get()).single;
    expect(food.lastUsedAt, testNow);

    // Back on the Today tab, with the confirmation.
    expect(find.text('chipsfrisch ungarisch'), findsNothing);
    expect(find.text('Zu Snacks hinzugefügt'), findsOneWidget);
  });

  testWidgets('without day and meal: today and the meal of the time of day; '
      'last amount as a chip', (tester) async {
    // 12:00 → lunch. The food was logged before with 80 g.
    final food = await db
        .into(db.foods)
        .insertReturning(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: 'Linsensuppe',
            kcal: const Value(90),
            protein: const Value(6),
            createdAt: testNow,
          ),
        );
    await DiaryRepository(db, Clock.fixed(testNow)).addEntry(
      food: food,
      amount: 80,
      day: '2026-11-10',
      mealSlotId: (await slot('dinner')).id,
    );
    await open(tester, Routes.food(food.id));

    expect(isSelectedPill(tester, 'Mittagessen'), isTrue);
    expect(find.text('Tag: Heute, 14. Nov.'), findsOneWidget);
    expect(find.widgetWithText(TextField, '100'), findsOneWidget);
    expect(isSelectedPill(tester, '100\u00A0g'), isTrue);
    await tester.tap(find.text('Zuletzt: 80\u00A0g'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '80'), findsOneWidget);
    expect(isSelectedPill(tester, 'Zuletzt: 80\u00A0g'), isTrue);
    expect(find.text('80 g zum Mittagessen · 72 kcal'), findsOneWidget);

    await tester.tap(find.byType(CtaButton));
    await tester.pumpAndSettle();
    final entries = await (db.select(
      db.diaryEntries,
    )..where((e) => e.day.equals('2026-11-14'))).get();
    expect(entries.single.amount, 80);
    expect(entries.single.mealSlotId, (await slot('lunch')).id);
  });

  testWidgets('own food: edit action, favourite toggle, no OFF footer', (
    tester,
  ) async {
    final container = ProviderContainer.test(overrides: testOverrides(db: db));
    final id = await container
        .read(productRepositoryProvider)
        .saveOwnFood(
          name: 'Omas Kuchen',
          nutrients: const Nutrients(kcal: 350),
        );
    await open(tester, Routes.food(id));

    expect(find.text('Omas Kuchen'), findsOneWidget);
    expect(find.byTooltip('Bearbeiten'), findsOneWidget);
    expect(find.text('Daten: Open Food Facts (ODbL)'), findsNothing);
    expect(
      find.text(
        'Die Bewertung ist eine Orientierung und keine medizinische Beratung.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Zu Favoriten hinzufügen'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Aus Favoriten entfernen'), findsOneWidget);
    expect((await db.select(db.foods).get()).single.isFavourite, isTrue);

    await tester.tap(find.byTooltip('Bearbeiten'));
    await tester.pumpAndSettle();
    expect(find.text('Lebensmittel bearbeiten'), findsOneWidget);
  });

  testWidgets('a deleted food shows a message', (tester) async {
    await open(tester, Routes.food(999));
    expect(
      find.text('Dieses Lebensmittel gibt es nicht mehr.'),
      findsOneWidget,
    );
  });

  testWidgets('invalid amount disables "Hinzufügen"', (tester) async {
    await open(tester, Routes.product(crisps));

    await tester.enterText(find.byType(TextField), '0');
    await tester.pumpAndSettle();
    expect(
      find.text('Bitte gib eine Menge zwischen 0 und 10.000 ein.'),
      findsOneWidget,
    );
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Hinzufügen'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('large text (2.0) does not overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester, Routes.product(crisps), tall: false);

    await tester.drag(find.byType(ListView), const Offset(0, -6000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Daten: Open Food Facts (ODbL)'), findsOneWidget);
  });
}
