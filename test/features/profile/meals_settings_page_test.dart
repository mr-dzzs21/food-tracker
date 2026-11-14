import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/core/widgets/app_card.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  /// All meals, top to bottom. A plain query instead of
  /// `watchMealSlots().first`, which can hang inside testWidgets.
  Future<List<MealSlot>> mealsInOrder() => (db.select(
    db.mealSlots,
  )..orderBy([(s) => OrderingTerm.asc(s.position)])).get();

  Future<MealSlot> meal(String builtIn) async =>
      (await mealsInOrder()).firstWhere((s) => s.builtIn == builtIn);

  Future<void> openMeals(
    WidgetTester tester, {
    Locale locale = const Locale('de'),
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(tester, db: db, locale: locale);
    ProviderScope.containerOf(tester.element(find.byType(FoodTrackerApp)))
        .read(routerProvider)
        .go(Routes.meals);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// The "anzeigen" switch in the row of [name].
  Finder switchOf(String name) => find.descendant(
    of: find.widgetWithText(AppCard, name),
    matching: find.byType(Switch),
  );

  testWidgets('shows the four default meals with their start times', (
    tester,
  ) async {
    await openMeals(tester);
    expect(find.text('Frühstück'), findsOneWidget);
    expect(find.text('ab 04:00'), findsOneWidget);
    expect(find.text('Mittagessen'), findsOneWidget);
    expect(find.text('Abendessen'), findsOneWidget);
    expect(find.text('ab 17:30'), findsOneWidget);
    expect(find.text('Snacks'), findsOneWidget);
    // The meal icons of the Today tiles.
    expect(find.byIcon(Icons.free_breakfast_rounded), findsOneWidget);
    expect(find.byIcon(Icons.cookie_rounded), findsOneWidget);
  });

  testWidgets('rename and remove the start time; empty name = default', (
    tester,
  ) async {
    await openMeals(tester);
    await tapText(tester, 'Frühstück');
    expect(find.text('Mahlzeit bearbeiten'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Morgens');
    await tapText(tester, 'Keine Uhrzeit');
    await tapText(tester, 'Speichern');

    expect(find.text('Morgens'), findsOneWidget);
    expect(find.text('keine Uhrzeit'), findsOneWidget);
    var breakfast = await meal('breakfast');
    expect(breakfast.customName, 'Morgens');
    expect(breakfast.startMinute, isNull);

    // An empty name brings back "Frühstück".
    await tapText(tester, 'Morgens');
    await tester.enterText(find.byType(TextFormField), '   ');
    await tapText(tester, 'Speichern');
    expect(find.text('Frühstück'), findsOneWidget);
    breakfast = await meal('breakfast');
    expect(breakfast.customName, isNull);
  });

  testWidgets('hide a meal with the switch', (tester) async {
    await openMeals(tester);
    await tester.tap(switchOf('Snacks'));
    await tester.pumpAndSettle();
    expect((await meal('snacks')).isHidden, isTrue);
    expect(find.text('ab 15:00 · ausgeblendet'), findsOneWidget);

    await tester.tap(switchOf('Snacks'));
    await tester.pumpAndSettle();
    expect((await meal('snacks')).isHidden, isFalse);
  });

  testWidgets('the last visible meal cannot be hidden', (tester) async {
    await openMeals(tester);
    for (final name in ['Mittagessen', 'Abendessen', 'Snacks']) {
      await tester.tap(switchOf(name));
      await tester.pumpAndSettle();
    }
    await tester.tap(switchOf('Frühstück'));
    await tester.pumpAndSettle();

    expect(
      find.text('Mindestens eine Mahlzeit muss sichtbar bleiben.'),
      findsOneWidget,
    );
    expect((await meal('breakfast')).isHidden, isFalse);
    expect(tester.widget<Switch>(switchOf('Frühstück')).value, isTrue);
  });

  testWidgets('add a meal: the name is required', (tester) async {
    await openMeals(tester);
    await tapText(tester, 'Mahlzeit hinzufügen');
    expect(find.text('Neue Mahlzeit'), findsOneWidget);
    await tapText(tester, 'Speichern');
    expect(find.text('Bitte gib einen Namen ein.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Spätsnack');
    await tapText(tester, 'Speichern');
    expect(find.text('Spätsnack'), findsOneWidget);
    final all = await mealsInOrder();
    expect(all, hasLength(5));
    expect(all.last.customName, 'Spätsnack');
    expect(all.last.builtIn, isNull);
  });

  testWidgets('a meal without entries can be deleted', (tester) async {
    await openMeals(tester);
    await tapText(tester, 'Snacks');
    await tapText(tester, 'Löschen');
    expect(find.text('„Snacks“ löschen?'), findsOneWidget);
    await tapText(tester, 'Löschen');

    expect(find.text('„Snacks“ gelöscht'), findsOneWidget);
    expect(
      (await mealsInOrder()).map((s) => s.builtIn),
      isNot(contains('snacks')),
    );
  });

  testWidgets('a meal with entries cannot be deleted, only hidden', (
    tester,
  ) async {
    final food = await db
        .into(db.foods)
        .insertReturning(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: 'Apfel',
            createdAt: testNow,
          ),
        );
    await DiaryRepository(db, Clock.fixed(testNow)).addEntry(
      food: food,
      amount: 150,
      day: '2026-11-01',
      mealSlotId: (await meal('lunch')).id,
    );

    await openMeals(tester);
    await tapText(tester, 'Mittagessen');
    await tapText(tester, 'Löschen');

    expect(find.text('Diese Mahlzeit wird verwendet'), findsOneWidget);
    await tapText(tester, 'Ausblenden');

    final lunch = await meal('lunch');
    expect(lunch.isHidden, isTrue);
    expect(await db.select(db.diaryEntries).get(), hasLength(1));
  });

  testWidgets('dragging a meal stores the new order', (tester) async {
    await openMeals(tester);
    // Drag "Frühstück" (first row) below "Abendessen" (third row).
    final handle = find.descendant(
      of: find.widgetWithText(AppCard, 'Frühstück'),
      matching: find.byIcon(Icons.drag_indicator_rounded),
    );
    final rowHeight = tester
        .getSize(find.widgetWithText(AppCard, 'Mittagessen'))
        .height;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 100));
    // Two rows down, in small steps like a finger.
    for (var i = 0; i < 8; i++) {
      await gesture.moveBy(Offset(0, rowHeight * 0.25));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect((await mealsInOrder()).map((s) => s.builtIn), [
      'lunch',
      'dinner',
      'breakfast',
      'snacks',
    ]);
    // The list shows the stored order.
    expect(
      tester.getTopLeft(find.text('Abendessen')).dy,
      lessThan(tester.getTopLeft(find.text('Frühstück')).dy),
    );
  });

  testWidgets('text scale 2.0 on a phone: rows and the add button fit', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openMeals(tester);
    tester.view.physicalSize = const Size(360, 720);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Mahlzeit hinzufügen'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('English: names and start times', (tester) async {
    await openMeals(tester, locale: const Locale('en'));
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('from 4:00 AM'), findsOneWidget); // 12-hour clock
    expect(find.text('Add meal'), findsOneWidget);
    expect(find.bySemanticsLabel('Move Breakfast'), findsOneWidget);
  });
}
