import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/core/theme/app_theme.dart';
import 'package:food_tracker/core/widgets/buttons.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/diary/widgets/calorie_ring.dart';
import 'package:food_tracker/features/diary/widgets/macro_bars.dart';
import 'package:food_tracker/features/diary/widgets/meal_card.dart';
import 'package:food_tracker/features/diary/widgets/meal_sheet.dart';
import 'package:food_tracker/features/goals/goals_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/nutrients.dart';
import 'package:food_tracker/router.dart';
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

  /// Opens the entries of [meal] (taps its tile).
  Future<void> openMeal(WidgetTester tester, String meal) async {
    await tester.ensureVisible(find.text(meal));
    await tester.pumpAndSettle();
    await tester.tap(find.text(meal));
    await tester.pumpAndSettle();
    expect(find.byType(MealSheet), findsOneWidget);
  }

  /// [text] inside the open meal sheet (the meal card behind it names the
  /// entries, too).
  Finder inSheet(String text) =>
      find.descendant(of: find.byType(MealSheet), matching: find.text(text));

  /// How the calorie ring is painted (progress, colours).
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

  /// How the macro bar number [index] (0 = protein) is painted.
  MacroBarPainter macroPainter(WidgetTester tester, int index) =>
      tester
              .widgetList<CustomPaint>(
                find.descendant(
                  of: find.byType(MacroBars),
                  matching: find.byType(CustomPaint),
                ),
              )
              .elementAt(index)
              .painter!
          as MacroBarPainter;

  testWidgets('no goal: goal prompt, eaten kcal of the EU reference intake, '
      'prompt can be closed', (tester) async {
    await log(amount: 200); // 500 kcal, 20 g protein
    await pumpTall(tester);

    expect(find.text('SAMSTAG'), findsOneWidget);
    expect(find.text('14. November'), findsOneWidget);
    expect(find.text('Heute'), findsWidgets); // pill next to the date + tab
    expect(find.text('Leg dein Tagesziel fest'), findsOneWidget);
    expect(find.text('Ziel festlegen'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('kcal gegessen'), findsOneWidget);
    expect(find.text('von 2.000 kcal (Richtwert)'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        '500 kcal gegessen von 2.000 kcal Richtwert. '
        'Kein Tagesziel festgelegt.',
      ),
      findsOneWidget,
    );
    // The ring fills relative to 2,000 kcal, the bars relative to the
    // reference intakes (protein 50 g).
    expect(ringPainter(tester).progress, closeTo(0.25, 0.001));
    expect(find.text('20/50 g'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Eiweiß: 20 von 50 g (Richtwert)'),
      findsOneWidget,
    );
    expect(macroPainter(tester, 0).fraction, closeTo(0.4, 0.001));
    expect(
      find.text(
        'Ohne Ziel zeigen Ring und Balken die EU-Richtwerte für Erwachsene.',
      ),
      findsOneWidget,
    );
    // One card per meal; the breakfast card names its entries.
    expect(find.byType(MealCard), findsNWidgets(4));
    expect(find.text('Frühstück'), findsOneWidget);
    expect(find.text('Haferflocken'), findsOneWidget);
    expect(find.text('Noch nichts'), findsNWidgets(3));
    expect(find.text('500 kcal'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Frühstück: 1 Eintrag, 500 kcal'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Hinweis ausblenden'));
    await tester.pumpAndSettle();
    expect(find.text('Ziel festlegen'), findsNothing);
    expect(await SharedPreferencesAsync().getBool('goal_card_dismissed'), true);
  });

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(FoodTrackerApp)));

  String location(WidgetTester tester) =>
      containerOf(tester).read(routerProvider).state.uri.toString();

  testWidgets('"Ziel festlegen" opens the goal page; back and saving return '
      'to Heute', (tester) async {
    await pumpTall(tester);
    await tester.tap(find.text('Ziel festlegen'));
    await tester.pumpAndSettle();
    expect(find.text('Tagesziel'), findsOneWidget);
    expect(location(tester), Routes.todayGoal);

    await tester.tap(find.byTooltip('Zurück'));
    await tester.pumpAndSettle();
    expect(location(tester), Routes.today);

    await tester.tap(find.text('Ziel festlegen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selbst eingeben'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kalorien pro Tag'),
      '2000',
    );
    await tester.pump();
    await tester.ensureVisible(find.text('Speichern'));
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    expect(location(tester), Routes.today);
    expect(find.text('Gegessen 0 · Ziel 2.000 kcal'), findsOneWidget);
  });

  testWidgets('with goal: kcal left and macros of the goal', (tester) async {
    await goals.saveGoal(kcal: 2490, protein: 120, carbs: 300, fat: 80);
    await log(amount: 500); // 1250 kcal, 50 g protein
    await pumpTall(tester);

    expect(find.text('Leg dein Tagesziel fest'), findsNothing);
    expect(find.text('1.240'), findsOneWidget);
    expect(find.text('kcal übrig'), findsOneWidget);
    expect(find.text('von 2.490'), findsOneWidget);
    expect(find.text('Gegessen 1.250 · Ziel 2.490 kcal'), findsOneWidget);
    expect(find.text('50/120 g'), findsOneWidget);
    expect(ringPainter(tester).progress, closeTo(1250 / 2490, 0.001));
    expect(
      find.bySemanticsLabel(
        '1.240 kcal übrig von 2.490 kcal. Gegessen: 1.250 kcal.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Eiweiß: 50 von 120 g'), findsOneWidget);
  });

  testWidgets('over the goal: full green ring, neutral text', (tester) async {
    await goals.saveGoal(kcal: 2000);
    await log(kcal: 290, amount: 800); // 2320 kcal
    await pumpTall(tester);

    expect(find.text('320'), findsOneWidget);
    expect(find.text('kcal über deinem Ziel'), findsOneWidget);

    final context = tester.element(find.byType(CalorieRing));
    final theme = Theme.of(context);
    final painter = ringPainter(tester);
    expect(painter.progress, greaterThanOrEqualTo(1));
    // The same green as below the goal – never a warning colour.
    expect(painter.startColor, context.appColors.ringStart);
    expect(painter.endColor, context.appColors.ringEnd);
    final warningColours = {
      theme.colorScheme.error,
      context.appColors.ratingHigh,
      context.appColors.ratingHighBg,
    };
    expect(warningColours, isNot(contains(painter.startColor)));
    expect(warningColours, isNot(contains(painter.endColor)));
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(warningColours, isNot(contains(text.style?.color)));
    }
  });

  group('animations', () {
    /// Logs 500 more kcal while Today is open and waits until the day's
    /// entries have reached the page (the ring's label changes at once).
    Future<void> logMore(WidgetTester tester) async {
      await log(amount: 200, meal: 'lunch'); // + 500 kcal, + 20 g protein
      for (var i = 0; i < 10; i++) {
        await tester.pump();
        if (find
            .bySemanticsLabel(RegExp('^1.000 kcal'))
            .evaluate()
            .isNotEmpty) {
          return;
        }
      }
      fail('the new entry did not reach the page');
    }

    testWidgets('ring, number and bars move from the old to the new value', (
      tester,
    ) async {
      await goals.saveGoal(kcal: 2000, protein: 100);
      await log(amount: 200); // 500 kcal
      await pumpTall(tester);
      expect(ringPainter(tester).progress, closeTo(0.25, 0.001));
      expect(find.text('1.500'), findsOneWidget);

      await logMore(tester);
      await tester.pump(const Duration(milliseconds: 200));
      // On the way: between the old and the new value.
      final progress = ringPainter(tester).progress;
      expect(progress, greaterThan(0.25));
      expect(progress, lessThan(0.5));
      expect(find.text('1.500'), findsNothing);
      expect(find.text('1.000'), findsNothing); // still counting
      final bar = macroPainter(tester, 0).fraction;
      expect(bar, greaterThan(0.2));
      expect(bar, lessThan(0.4));

      await tester.pumpAndSettle();
      expect(ringPainter(tester).progress, closeTo(0.5, 0.001));
      expect(find.text('1.000'), findsOneWidget);
      expect(macroPainter(tester, 0).fraction, closeTo(0.4, 0.001));
    });

    testWidgets('the ring fills from 0 when it appears', (tester) async {
      final shown = ValueNotifier(false);
      addTearDown(shown.dispose);
      await pumpWidgetInApp(
        tester,
        db: db,
        Scaffold(
          body: ValueListenableBuilder(
            valueListenable: shown,
            builder: (context, isShown, _) => isShown
                ? CalorieRing(
                    totals: NutrientTotals.sum([const Nutrients(kcal: 500)]),
                    goalKcal: 2000,
                  )
                : const SizedBox(),
          ),
        ),
      );
      shown.value = true;
      await tester.pump();
      expect(ringPainter(tester).progress, 0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(ringPainter(tester).progress, inExclusiveRange(0, 0.25));
      await tester.pumpAndSettle();
      expect(ringPainter(tester).progress, closeTo(0.25, 0.001));
      expect(find.text('1.500'), findsOneWidget);
    });

    testWidgets('reduced motion: new values show at once', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await goals.saveGoal(kcal: 2000, protein: 100);
      await log(amount: 200);
      await pumpTall(tester);

      await logMore(tester);
      await tester.pump();
      expect(ringPainter(tester).progress, closeTo(0.5, 0.001));
      expect(find.text('1.000'), findsOneWidget);
      expect(macroPainter(tester, 0).fraction, closeTo(0.4, 0.001));
    });

    testWidgets('a pressed meal card shrinks a little', (tester) async {
      await pumpTall(tester);
      AnimatedScale scaleOf() => tester.widget<AnimatedScale>(
        find
            .descendant(
              of: find.byType(MealCard),
              matching: find.byType(AnimatedScale),
            )
            .first,
      );
      expect(scaleOf().scale, 1);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Frühstück')),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(scaleOf().scale, 0.98);
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(scaleOf().scale, 1);
    });
  });

  testWidgets('missing values: totals say "mind." and explain why', (
    tester,
  ) async {
    await log(amount: 200); // 500 kcal, 20 g protein
    await log(name: 'Selbstgemachte Suppe', kcal: null, protein: null);
    await pumpTall(tester);

    expect(find.text('mind. 500'), findsOneWidget); // ring
    expect(find.text('Für 1 Eintrag fehlen Angaben'), findsOneWidget);
    expect(find.text('mind. 20/50 g'), findsOneWidget); // protein bar
    expect(find.text('mind. 500 kcal'), findsOneWidget); // breakfast card

    await openMeal(tester, 'Frühstück');
    expect(find.text('mind. 500 kcal'), findsNWidgets(2)); // card + sheet
    expect(find.text('–'), findsOneWidget); // the soup's kcal
    // Screen readers hear "keine Angabe" instead of "–".
    expect(find.bySemanticsLabel(RegExp('keine Angabe')), findsOneWidget);
  });

  testWidgets('missing values with a goal: "höchstens" left', (tester) async {
    await goals.saveGoal(kcal: 2000);
    await log(amount: 200); // 500 kcal
    await log(name: 'Suppe', kcal: null);
    await pumpTall(tester);

    expect(find.text('höchstens 1.500'), findsOneWidget);
    expect(find.text('Gegessen mind. 500 · Ziel 2.000 kcal'), findsOneWidget);
  });

  testWidgets('a meal card opens its entries; empty meals say so', (
    tester,
  ) async {
    await log(amount: 200);
    await log(name: 'Milch', kcal: 50, amount: 250);
    await pumpTall(tester);

    expect(find.text('Haferflocken, Milch'), findsOneWidget);
    await openMeal(tester, 'Frühstück');
    expect(find.text('2 Einträge'), findsOneWidget); // sheet header
    expect(inSheet('Haferflocken'), findsOneWidget);
    expect(find.text('200 g'), findsOneWidget);
    expect(find.text('250 g'), findsOneWidget);
    expect(find.text('500 kcal'), findsOneWidget); // oats
    expect(find.text('125 kcal'), findsOneWidget); // milk
    expect(find.text('625 kcal'), findsNWidgets(2)); // card + sheet header

    // Close the sheet, open an empty meal.
    await tester.tapAt(const Offset(400, 20));
    await tester.pumpAndSettle();
    expect(find.byType(MealSheet), findsNothing);
    await openMeal(tester, 'Abendessen');
    expect(find.text('Hier ist noch nichts eingetragen.'), findsOneWidget);
  });

  testWidgets('"Hinzufügen" in the meal sheet opens the add page', (
    tester,
  ) async {
    await pumpTall(tester);
    await openMeal(tester, 'Abendessen');

    await tester.tap(
      find.descendant(
        of: find.byType(MealSheet),
        matching: find.text('Hinzufügen'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MealSheet), findsNothing);
    expect(find.text('Abendessen · Heute, 14. Nov.'), findsOneWidget);
  });

  testWidgets('swipe deletes an entry, "Rückgängig" brings it back', (
    tester,
  ) async {
    await log();
    await pumpTall(tester);
    await openMeal(tester, 'Frühstück');

    await tester.drag(inSheet('Haferflocken'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(inSheet('Haferflocken'), findsNothing);
    // Shown in the sheet (and behind it, on the tab).
    expect(find.text('Eintrag gelöscht'), findsWidgets);
    expect(await db.select(db.diaryEntries).get(), isEmpty);
    expect(find.text('Hier ist noch nichts eingetragen.'), findsOneWidget);

    await tester.tap(find.text('Rückgängig').last);
    await tester.pumpAndSettle();

    expect(inSheet('Haferflocken'), findsOneWidget);
    expect(await db.select(db.diaryEntries).get(), hasLength(1));
  });

  testWidgets('tapping an entry opens the sheet to change the amount', (
    tester,
  ) async {
    await log();
    await pumpTall(tester);
    await openMeal(tester, 'Frühstück');

    await tester.tap(inSheet('Haferflocken'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '150,5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    final entry = (await db.select(db.diaryEntries).get()).single;
    expect(entry.amount, 150.5);
    // The meal sheet is still open and shows the new amount.
    expect(find.text('150,5 g'), findsOneWidget);
  });

  testWidgets('"Löschen" in the entry sheet also offers "Rückgängig"', (
    tester,
  ) async {
    await log();
    await pumpTall(tester);
    await openMeal(tester, 'Frühstück');

    await tester.tap(inSheet('Haferflocken'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    expect(await db.select(db.diaryEntries).get(), isEmpty);
    expect(inSheet('Haferflocken'), findsNothing);
    await tester.tap(find.text('Rückgängig').last);
    await tester.pumpAndSettle();
    expect(inSheet('Haferflocken'), findsOneWidget);
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
    expect(find.text('Gestern gegessen'), findsNothing);
    await tester.tap(find.byTooltip('Vorheriger Tag'));
    await tester.pumpAndSettle();

    expect(find.text('FREITAG'), findsOneWidget);
    expect(find.text('13. November'), findsOneWidget);
    expect(find.text('Gestern gegessen'), findsOneWidget); // card subtitle
    await openMeal(tester, 'Frühstück');
    expect(inSheet('Gestern gegessen'), findsOneWidget);
    await tester.tapAt(const Offset(400, 20));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Heute'));
    await tester.pumpAndSettle();
    expect(find.text('14. November'), findsOneWidget);
    expect(find.text('Gestern gegessen'), findsNothing);
  });

  testWidgets('‹ › stop at the limits of the date picker, which then opens '
      'without an error', (tester) async {
    await pumpTall(tester);
    final notifier = containerOf(tester).read(selectedDayProvider.notifier);
    RoundIconButton arrow(IconData icon) =>
        tester.widget(find.widgetWithIcon(RoundIconButton, icon));

    notifier.set('2027-12-31'); // the last day: end of next year
    await tester.pumpAndSettle();
    expect(arrow(Icons.chevron_right_rounded).onPressed, isNull);
    await tester.tap(find.byTooltip('Nächster Tag'));
    await tester.pumpAndSettle();
    expect(find.text('31. Dezember'), findsOneWidget);
    await tester.tap(find.text('31. Dezember'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    notifier.set('2000-01-01'); // the first day
    await tester.pumpAndSettle();
    expect(arrow(Icons.chevron_left_rounded).onPressed, isNull);
    expect(arrow(Icons.chevron_right_rounded).onPressed, isNotNull);
  });

  testWidgets('switching the day keeps the old values until the new ones '
      'are there: no spinner, the ring moves from the old value', (
    tester,
  ) async {
    await goals.saveGoal(kcal: 2000);
    await log(amount: 200); // today: 500 kcal
    await log(name: 'Gestern', amount: 400, day: '2026-11-13'); // 1000 kcal
    await pumpTall(tester);
    expect(ringPainter(tester).progress, closeTo(0.25, 0.001));

    await tester.tap(find.byTooltip('Vorheriger Tag'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(CalorieRing), findsOneWidget);
    expect(find.text('13. November'), findsOneWidget);

    // Wait until the new day's entries are there (the label changes at
    // once), then look half-way through the animation.
    final newLine = find.text('Gegessen 1.000 · Ziel 2.000 kcal');
    for (var i = 0; i < 10 && newLine.evaluate().isEmpty; i++) {
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 200));
    final progress = ringPainter(tester).progress;
    expect(progress, greaterThan(0.25)); // from the old value, not from 0
    expect(progress, lessThan(0.5));
    await tester.pumpAndSettle();
    expect(ringPainter(tester).progress, closeTo(0.5, 0.001));
  });

  testWidgets('back in the foreground after midnight: "Heute" is the new '
      'day, a picked day stays', (tester) async {
    var now = DateTime(2026, 11, 14, 23, 50);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(tester, db: db, clock: Clock(() => now));
    expect(find.text('14. November'), findsOneWidget);

    Future<void> nextMorning() async {
      now = now.add(const Duration(hours: 8));
      // Into the background and back, step by step like on a phone.
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();
    }

    await nextMorning();
    expect(find.text('SONNTAG'), findsOneWidget);
    expect(find.text('15. November'), findsOneWidget);

    // A day the user picked is kept.
    await tester.tap(find.byTooltip('Vorheriger Tag'));
    await tester.pumpAndSettle();
    await nextMorning();
    expect(find.text('14. November'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Heute'), findsOneWidget);
  });

  testWidgets('Today meets the tap target guidelines (48 px on Android)', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await log();
    await pumpTall(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('hidden meals only show up when they have entries', (
    tester,
  ) async {
    await (db.update(db.mealSlots)..where((s) => s.builtIn.equals('snacks')))
        .write(const MealSlotsCompanion(isHidden: Value(true)));
    await pumpTall(tester);
    expect(find.text('Snacks'), findsNothing);
    expect(find.byType(MealCard), findsNWidgets(3));

    await log(name: 'Apfel', meal: 'snacks');
    await tester.pumpAndSettle();
    expect(find.text('Snacks'), findsOneWidget);
    await openMeal(tester, 'Snacks');
    expect(inSheet('Apfel'), findsOneWidget);
  });

  testWidgets('"+" opens the add page of that meal', (tester) async {
    await pumpTall(tester);

    await tester.tap(find.byTooltip('Zum Mittagessen hinzufügen'));
    await tester.pumpAndSettle();

    expect(find.text('Mittagessen · Heute, 14. Nov.'), findsOneWidget);
  });

  testWidgets('English', (tester) async {
    await goals.saveGoal(kcal: 2490, protein: 120);
    await log(amount: 500);
    await pumpTall(tester, locale: const Locale('en'));

    expect(find.text('SATURDAY'), findsOneWidget);
    expect(find.text('November 14'), findsOneWidget);
    expect(find.text('1,240'), findsOneWidget);
    expect(find.text('kcal left'), findsOneWidget);
    expect(find.text('of 2,490'), findsOneWidget);
    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Eaten 1,250 · goal 2,490 kcal'), findsOneWidget);
    expect(find.text('Nothing yet'), findsNWidgets(3));
    expect(find.text('50/120 g'), findsOneWidget);
    expect(find.byTooltip('Add to Lunch'), findsOneWidget);
  });

  testWidgets('dark mode renders with the dark tokens', (tester) async {
    await goals.saveGoal(kcal: 2000, protein: 100);
    await log(amount: 300);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(tester, db: db, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(MealCard).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(context.appColors.background, AppColors.dark.background);
    expect(ringPainter(tester).startColor, AppColors.dark.ringStart);
    expect(find.text('1.250'), findsOneWidget);
    await openMeal(tester, 'Frühstück');
    expect(inSheet('Haferflocken'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

      // The sheet with a long entry name, too.
      await openMeal(tester, 'Frühstück');
      expect(tester.takeException(), isNull);
    });
  }
}
