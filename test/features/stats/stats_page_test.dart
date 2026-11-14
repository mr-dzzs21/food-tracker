import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/theme/app_theme.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/goals/goals_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/stats/stats_page.dart';
import 'package:food_tracker/features/stats/widgets/week_bars.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late DiaryRepository diary;

  setUp(() {
    db = newTestDatabase();
    diary = DiaryRepository(db, Clock.fixed(testNow));
  });

  tearDown(() => db.close());

  /// Logs [amount] g of a food with 500 kcal, 20 g protein, 60 g carbs and
  /// 10 g fat per 100 g on [day].
  Future<void> log(
    String day, {
    double amount = 100,
    double? kcal = 500,
  }) async {
    final food = await db
        .into(db.foods)
        .insertReturning(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: 'Testessen',
            kcal: Value(kcal),
            protein: const Value(20),
            carbs: const Value(60),
            fat: const Value(10),
            createdAt: testNow,
          ),
        );
    final slotId = (await db.select(db.mealSlots).get()).first.id;
    await diary.addEntry(
      food: food,
      amount: amount,
      day: day,
      mealSlotId: slotId,
    );
  }

  /// Shows the statistics page on a tall screen (everything fits).
  Future<void> pumpStats(
    WidgetTester tester, {
    Locale locale = const Locale('de'),
  }) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpWidgetInApp(tester, const StatsPage(), db: db, locale: locale);
  }

  WeekBarsPainter painter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(WeekBars),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter!
          as WeekBarsPainter;

  IconButton button(WidgetTester tester, String tooltip) => tester.widget(
    find.ancestor(
      of: find.byTooltip(tooltip),
      matching: find.byType(IconButton),
    ),
  );

  testWidgets('a week with data: bars, goal line and averages', (tester) async {
    await GoalsRepository(db, Clock.fixed(testNow)).saveGoal(kcal: 2000);
    await log('2026-11-09', amount: 400); // Monday: 2000 kcal
    await log('2026-11-11', amount: 200); // Wednesday: 1000 kcal
    await log('2026-11-02'); // last week: not counted
    await pumpStats(tester);

    expect(find.text('Diese Woche'), findsOneWidget);
    expect(find.byType(WeekBars), findsOneWidget);
    expect(find.text('Linie: dein Tagesziel (2.000 kcal)'), findsOneWidget);
    // 3000 kcal over the 2 days with entries.
    expect(find.text('1.500'), findsOneWidget);
    expect(find.text('2 von 7'), findsOneWidget);
    expect(find.text('60 g'), findsOneWidget); // protein
    expect(find.text('180 g'), findsOneWidget); // carbs
    expect(find.text('30 g'), findsOneWidget); // fat

    final bars = painter(tester);
    expect(bars.values, [2000, 0, 1000, 0, 0, 0, 0]);
    expect(bars.goal, 2000);
    expect(bars.todayIndex, 5); // Saturday, 14 Nov
    // Above or below the goal: the same green, never red.
    final scheme = buildTheme(Brightness.light).colorScheme;
    expect(bars.todayColor, scheme.primary);
    expect(bars.barColor, scheme.primary.withValues(alpha: 0.6));

    expect(
      find.bySemanticsLabel(
        'Kalorien pro Tag: Montag 2.000 kcal, Dienstag keine Einträge, '
        'Mittwoch 1.000 kcal, Donnerstag keine Einträge, '
        'Freitag keine Einträge, Samstag keine Einträge, '
        'Sonntag keine Einträge. Tagesziel: 2.000 kcal.',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Durchschnitt: 1.500 kcal pro Tag'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Durchschnitt Eiweiß: 60 g pro Tag'),
      findsOneWidget,
    );
  });

  testWidgets('without a goal there is no goal line', (tester) async {
    await log('2026-11-14');
    await pumpStats(tester);

    expect(painter(tester).goal, isNull);
    expect(find.textContaining('Linie'), findsNothing);
    expect(find.text('1 von 7'), findsOneWidget);
  });

  testWidgets('missing kcal values: the average is "mind."', (tester) async {
    await log('2026-11-09', amount: 200); // 1000 kcal
    await log('2026-11-09', kcal: null);
    await pumpStats(tester);

    expect(find.text('mind. 1.000'), findsOneWidget);
  });

  testWidgets('an empty week shows a friendly hint', (tester) async {
    await pumpStats(tester);

    expect(find.text('Keine Einträge in dieser Woche'), findsOneWidget);
    expect(find.byType(WeekBars), findsNothing);
  });

  testWidgets('back and forward; no "next" in the current week', (
    tester,
  ) async {
    await log('2026-11-03', amount: 300); // last week, Tuesday: 1500 kcal
    await pumpStats(tester);

    expect(button(tester, 'Nächste Woche').onPressed, isNull);
    expect(find.text('Keine Einträge in dieser Woche'), findsOneWidget);

    await tester.tap(find.byTooltip('Vorherige Woche'));
    await tester.pumpAndSettle();
    expect(find.text('KW 45 · 2.–8. Nov.'), findsOneWidget);
    expect(find.text('1.500'), findsOneWidget);
    expect(find.text('1 von 7'), findsOneWidget);
    // Today is not in that week: no bar is highlighted.
    expect(painter(tester).todayIndex, isNull);
    expect(button(tester, 'Nächste Woche').onPressed, isNotNull);

    await tester.tap(find.byTooltip('Nächste Woche'));
    await tester.pumpAndSettle();
    expect(find.text('Diese Woche'), findsOneWidget);
    expect(button(tester, 'Nächste Woche').onPressed, isNull);
  });

  testWidgets('English', (tester) async {
    await log('2026-11-02', amount: 400);
    await pumpStats(tester, locale: const Locale('en'));

    expect(find.text('This week'), findsOneWidget);
    expect(find.text('No entries this week'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous week'));
    await tester.pumpAndSettle();
    expect(find.text('Week 45 · Nov 2–8'), findsOneWidget);
    expect(find.text('Ø kcal per day'), findsOneWidget);
    expect(find.text('2,000'), findsOneWidget);
    expect(find.text('1 of 7'), findsOneWidget);
    expect(find.text('Calories per day'), findsOneWidget);
  });

  testWidgets('large text (2.0) on a small phone does not overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.physicalSize = const Size(360, 690);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await GoalsRepository(db, Clock.fixed(testNow)).saveGoal(kcal: 2000);
    await log('2026-11-12', amount: 450);
    await pumpWidgetInApp(tester, const StatsPage(), db: db);

    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.text('Durchschnitte zählen nur die Tage mit Einträgen.'),
      findsOneWidget,
    );
  });

  testWidgets('the "Statistik" tab shows the statistics page', (tester) async {
    await pumpFoodTrackerApp(tester, db: db);
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();

    expect(find.byType(StatsPage), findsOneWidget);
    expect(find.text('Diese Woche'), findsOneWidget);
  });
}
