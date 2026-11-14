import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/theme/app_theme.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/diary/widgets/calorie_ring.dart';
import 'package:food_tracker/features/goals/goals_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late DiaryRepository diary;
  late GoalsRepository goals;

  setUp(() {
    db = newTestDatabase();
    diary = DiaryRepository(db, Clock.fixed(testNow));
    goals = GoalsRepository(db, Clock.fixed(testNow));
  });

  tearDown(() => db.close());

  Future<int> slotId(String builtIn) async => (await (db.select(
    db.mealSlots,
  )..where((s) => s.builtIn.equals(builtIn))).getSingle()).id;

  /// Stores an own food and logs [amount] g of it.
  Future<void> log({
    String name = 'Haferflocken',
    double? kcal = 250,
    double? protein = 10,
    double amount = 100,
    String meal = 'breakfast',
    String day = '2026-11-14',
  }) async {
    final food = await db
        .into(db.foods)
        .insertReturning(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: name,
            kcal: Value(kcal),
            protein: Value(protein),
            carbs: const Value(50),
            fat: const Value(5),
            createdAt: testNow,
          ),
        );
    await diary.addEntry(
      food: food,
      amount: amount,
      day: day,
      mealSlotId: await slotId(meal),
    );
  }

  /// Starts the app on a tall screen, so the whole day fits without
  /// scrolling (a ListView only builds what is visible).
  Future<void> pumpTall(
    WidgetTester tester, {
    Locale locale = const Locale('de'),
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(tester, db: db, locale: locale);
  }

  /// The colour the calorie ring is painted with.
  CalorieRingPainter ringPainter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(CalorieRing),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter!
          as CalorieRingPainter;

  testWidgets('no goal: goal card, eaten kcal, card can be closed', (
    tester,
  ) async {
    await log(amount: 200); // 500 kcal
    await pumpTall(tester);

    expect(find.text('Heute, 14. Nov.'), findsOneWidget);
    // Title and button of the card.
    expect(find.text('Ziel festlegen'), findsNWidgets(2));
    expect(find.text('500'), findsOneWidget);
    expect(find.text('kcal gegessen'), findsOneWidget);
    expect(
      find.bySemanticsLabel('500 kcal gegessen. Kein Tagesziel festgelegt.'),
      findsOneWidget,
    );
    expect(find.text('Frühstück'), findsOneWidget);
    expect(find.text('Haferflocken'), findsOneWidget);
    expect(find.text('200 g'), findsOneWidget);
    expect(find.text('500 kcal'), findsWidgets); // entry row + meal sum

    await tester.tap(find.byTooltip('Hinweis ausblenden'));
    await tester.pumpAndSettle();
    expect(find.text('Ziel festlegen'), findsNothing);
    expect(await SharedPreferencesAsync().getBool('goal_card_dismissed'), true);
  });

  testWidgets('with goal: kcal left and macros of the goal', (tester) async {
    await goals.saveGoal(kcal: 2490, protein: 120, carbs: 300, fat: 80);
    await log(amount: 500); // 1250 kcal, 50 g protein
    await pumpTall(tester);

    expect(find.text('Ziel festlegen'), findsNothing);
    expect(find.text('1.240'), findsOneWidget);
    expect(find.text('kcal übrig'), findsOneWidget);
    expect(find.text('von 2.490'), findsOneWidget);
    expect(find.text('Gegessen: 1.250 kcal'), findsOneWidget);
    expect(find.text('50 von 120 g'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        '1.240 kcal übrig von 2.490 kcal. Gegessen: 1.250 kcal.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Eiweiß: 50 von 120 g'), findsOneWidget);
  });

  testWidgets('over the goal: full ring in the normal colour, neutral text', (
    tester,
  ) async {
    await goals.saveGoal(kcal: 2000);
    await log(kcal: 290, amount: 800); // 2320 kcal
    await pumpTall(tester);

    expect(find.text('320'), findsOneWidget);
    expect(find.text('kcal über deinem Ziel'), findsOneWidget);

    final context = tester.element(find.byType(CalorieRing));
    final theme = Theme.of(context);
    final painter = ringPainter(tester);
    expect(painter.progress, greaterThanOrEqualTo(1));
    expect(painter.color, theme.colorScheme.primary);
    // Nothing on the screen is painted in a warning colour.
    final warningColours = {
      theme.colorScheme.error,
      context.appColors.ratingHigh,
    };
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(warningColours, isNot(contains(text.style?.color)));
    }
  });

  testWidgets('missing values: totals say "mind." and explain why', (
    tester,
  ) async {
    await log(amount: 200); // 500 kcal, 20 g protein
    await log(name: 'Selbstgemachte Suppe', kcal: null, protein: null);
    await pumpTall(tester);

    expect(find.text('mind. 500'), findsOneWidget); // ring
    expect(find.text('Für 1 Eintrag fehlen Angaben'), findsOneWidget);
    expect(find.text('mind. 20 g'), findsOneWidget); // protein bar
    expect(find.text('mind. 500 kcal'), findsOneWidget); // breakfast sum
    expect(find.text('–'), findsOneWidget); // the soup's kcal
  });

  testWidgets('missing values with a goal: "höchstens" left', (tester) async {
    await goals.saveGoal(kcal: 2000);
    await log(amount: 200); // 500 kcal
    await log(name: 'Suppe', kcal: null);
    await pumpTall(tester);

    expect(find.text('höchstens 1.500'), findsOneWidget);
    expect(find.text('Gegessen: mind. 500 kcal'), findsOneWidget);
  });

  testWidgets('swipe deletes an entry, "Rückgängig" brings it back', (
    tester,
  ) async {
    await log();
    await pumpTall(tester);

    await tester.drag(find.text('Haferflocken'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Haferflocken'), findsNothing);
    expect(find.text('Eintrag gelöscht'), findsOneWidget);
    expect(await db.select(db.diaryEntries).get(), isEmpty);

    await tester.tap(find.text('Rückgängig'));
    await tester.pumpAndSettle();

    expect(find.text('Haferflocken'), findsOneWidget);
    expect(await db.select(db.diaryEntries).get(), hasLength(1));
  });

  testWidgets('tapping an entry opens the sheet to change the amount', (
    tester,
  ) async {
    await log();
    await pumpTall(tester);

    await tester.tap(find.text('Haferflocken'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '150,5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    final entry = (await db.select(db.diaryEntries).get()).single;
    expect(entry.amount, 150.5);
    expect(find.text('150,5 g'), findsOneWidget);
  });

  testWidgets('date switcher: previous day, back to today', (tester) async {
    await log(name: 'Gestern gegessen', day: '2026-11-13');
    await pumpTall(tester);

    expect(
      find.text(
        'Noch nichts eingetragen. Tippe bei einer Mahlzeit auf +, '
        'um etwas hinzuzufügen.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Vorheriger Tag'));
    await tester.pumpAndSettle();

    expect(find.text('Gestern, 13. Nov.'), findsOneWidget);
    expect(find.text('Gestern gegessen'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Heute'));
    await tester.pumpAndSettle();
    expect(find.text('Heute, 14. Nov.'), findsOneWidget);
    expect(find.text('Gestern gegessen'), findsNothing);
  });

  testWidgets('hidden meals only show up when they have entries', (
    tester,
  ) async {
    await (db.update(db.mealSlots)..where((s) => s.builtIn.equals('snacks')))
        .write(const MealSlotsCompanion(isHidden: Value(true)));
    await pumpTall(tester);
    expect(find.text('Snacks'), findsNothing);

    await log(name: 'Apfel', meal: 'snacks');
    await tester.pumpAndSettle();
    expect(find.text('Snacks'), findsOneWidget);
    expect(find.text('Apfel'), findsOneWidget);
  });

  testWidgets('"+" opens the add page of that meal', (tester) async {
    await pumpTall(tester);

    await tester.tap(find.byTooltip('Zu Mittagessen hinzufügen'));
    await tester.pumpAndSettle();

    // AddFoodPage is still a placeholder (next work package).
    expect(find.text('AddFoodPage'), findsOneWidget);
  });

  testWidgets('English', (tester) async {
    await goals.saveGoal(kcal: 2490, protein: 120);
    await log(amount: 500);
    await pumpTall(tester, locale: const Locale('en'));

    expect(find.text('Today, Nov 14'), findsOneWidget);
    expect(find.text('1,240'), findsOneWidget);
    expect(find.text('kcal left'), findsOneWidget);
    expect(find.text('of 2,490'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('50 of 120 g'), findsOneWidget);
    expect(find.byTooltip('Add to Lunch'), findsOneWidget);
  });

  for (final withGoal in [true, false]) {
    testWidgets('large text (2.0) does not overflow (goal: $withGoal)', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      if (withGoal) {
        await goals.saveGoal(kcal: 2490, protein: 120, carbs: 300, fat: 80);
      }
      await log(name: 'Sehr lange Produktbezeichnung mit vielen Wörtern');
      await log(name: 'Suppe', kcal: null, meal: 'dinner');
      await pumpFoodTrackerApp(tester, db: db);

      expect(find.byType(CalorieRing), findsOneWidget);
      // Overflow errors would fail the test. Scroll through the whole list
      // so every part is laid out once.
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Snacks'), findsOneWidget);
    });
  }
}
