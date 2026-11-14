import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/theme/app_theme.dart';
import 'package:food_tracker/core/widgets/card_list.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/goals/goal_page.dart';
import 'package:food_tracker/features/goals/goals_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  /// Starts the app on a tall screen and opens the "Profil" tab.
  Future<void> openProfile(
    WidgetTester tester, {
    Locale locale = const Locale('de'),
  }) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(tester, db: db, locale: locale);
    await tester.tap(
      find.text(locale.languageCode == 'de' ? 'Profil' : 'Profile'),
    );
    await tester.pumpAndSettle();
  }

  Future<List<MealSlot>> mealSlotsInOrder() => (db.select(
    db.mealSlots,
  )..orderBy([(s) => OrderingTerm.asc(s.position)])).get();

  ThemeMode themeModeOf(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

  testWidgets('without a goal: "Noch kein Ziel" opens the goal page', (
    tester,
  ) async {
    await openProfile(tester);
    expect(find.text('Noch kein Ziel'), findsOneWidget);
    await tester.tap(find.text('Ziel festlegen'));
    await tester.pumpAndSettle();
    expect(find.byType(GoalPage), findsOneWidget);
  });

  testWidgets('with a goal: kcal and macros', (tester) async {
    await GoalsRepository(
      db,
      Clock.fixed(testNow),
    ).saveGoal(kcal: 2300, protein: 64, carbs: 338.4, fat: 76.6);
    await openProfile(tester);
    expect(find.text('2.300 kcal pro Tag'), findsOneWidget);
    expect(
      find.text('Eiweiß: 64 g · Kohlenhydrate: 338 g · Fett: 77 g'),
      findsOneWidget,
    );
    expect(find.text('Ziel ändern'), findsOneWidget);
  });

  testWidgets('"Darstellung" switches the theme and stores it', (tester) async {
    await openProfile(tester);
    expect(themeModeOf(tester), ThemeMode.system);
    // The language is set to German by the test helper, so only the theme
    // tile shows "Wie das System".
    expect(find.text('Wie das System'), findsOneWidget);

    await tester.tap(find.text('Darstellung'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dunkel'));
    await tester.pumpAndSettle();

    expect(themeModeOf(tester), ThemeMode.dark);
    expect(find.text('Dunkel'), findsOneWidget); // subtitle of the tile
    expect(await SharedPreferencesAsync().getString('theme_mode'), 'dark');
  });

  testWidgets('"Sprache" switches all texts at once', (tester) async {
    await openProfile(tester);
    await tester.tap(find.text('Sprache'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget); // bottom bar
    expect(find.text('Sprache'), findsNothing);
    expect(await SharedPreferencesAsync().getString('locale'), 'en');

    // And back to German.
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(find.text('Sprache'), findsOneWidget);
  });

  testWidgets('eating-disorder help opens with the helpline', (tester) async {
    await openProfile(tester);
    await tester.tap(find.text('Hilfe bei Essstörungen'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('0221 892031 anrufen'), findsOneWidget);
    expect(find.text('Mo–Do 10–22 Uhr, Fr–So 10–18 Uhr'), findsOneWidget);
    expect(find.text('Webseite: essstoerungen.bioeg.de'), findsOneWidget);
  });

  testWidgets('"Alle Daten löschen" clears entries and restores the meals', (
    tester,
  ) async {
    final clock = Clock.fixed(testNow);
    final diary = DiaryRepository(db, clock);
    // A diary entry, an own food, a goal, a renamed and an extra meal.
    final food = await db
        .into(db.foods)
        .insertReturning(
          FoodsCompanion.insert(
            source: FoodSource.user,
            name: 'Linsensuppe',
            kcal: const Value(80),
            createdAt: testNow,
          ),
        );
    // A plain query, not `watchMealSlots().first`: in the fake-async zone of
    // testWidgets, a cancelled drift watch stream made the next transaction
    // (addEntry) wait forever – the test hung.
    final slots = await mealSlotsInOrder();
    await diary.addEntry(
      food: food,
      amount: 300,
      day: '2026-11-14',
      mealSlotId: slots.first.id,
    );
    await diary.updateMealSlot(
      slots.first.id,
      customName: 'Morgens',
      startMinute: null,
    );
    await diary.addMealSlot(name: 'Spätsnack');
    await GoalsRepository(db, clock).saveGoal(kcal: 2000);

    await openProfile(tester);
    // After the start: the test helper replaces the preferences store.
    await SharedPreferencesAsync().setBool('goal_card_dismissed', true);
    await tester.tap(find.text('Alle Daten löschen'));
    await tester.pumpAndSettle();
    expect(find.text('Alle Daten löschen?'), findsOneWidget);
    await tester.tap(find.text('Alles löschen'));
    await tester.pumpAndSettle();

    expect(await db.select(db.diaryEntries).get(), isEmpty);
    expect(await db.select(db.foods).get(), isEmpty);
    expect(await db.select(db.userGoal).get(), isEmpty);
    final meals = await mealSlotsInOrder();
    expect(meals.map((s) => s.builtIn), [
      'breakfast',
      'lunch',
      'dinner',
      'snacks',
    ]);
    expect(meals.every((s) => s.customName == null), isTrue);
    expect(await SharedPreferencesAsync().getKeys(), isEmpty);

    // The goal card resets (the language follows the test device now).
    expect(find.text('No goal yet'), findsOneWidget);
    expect(find.text('Alle Daten wurden gelöscht.'), findsOneWidget);
  });

  testWidgets(
    'settings are card rows; "Alle Daten löschen" in rating colours',
    (tester) async {
      await openProfile(tester);
      for (final title in [
        'Mahlzeiten',
        'Eigene Lebensmittel',
        'Darstellung',
        'Sprache',
        'Hilfe bei Essstörungen',
        'Über die App & Lizenzen',
        'Alle Daten löschen',
      ]) {
        expect(
          find.ancestor(of: find.text(title), matching: find.byType(CardRow)),
          findsOneWidget,
          reason: title,
        );
      }
      final delete = tester.widget<Text>(find.text('Alle Daten löschen'));
      expect(delete.style!.color, AppColors.light.ratingHigh);
    },
  );

  testWidgets('dark mode and text scale 2.0 on a phone: no overflow', (
    tester,
  ) async {
    await GoalsRepository(
      db,
      Clock.fixed(testNow),
    ).saveGoal(kcal: 2300, protein: 64, carbs: 338, fat: 77);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(tester, db: db, themeMode: ThemeMode.dark);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('2.300 kcal pro Tag'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Alle Daten löschen'), findsOneWidget);
  });

  testWidgets('"Abbrechen" deletes nothing', (tester) async {
    await GoalsRepository(db, Clock.fixed(testNow)).saveGoal(kcal: 2000);
    await openProfile(tester);
    await tester.tap(find.text('Alle Daten löschen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(await db.select(db.userGoal).get(), hasLength(1));
  });
}
