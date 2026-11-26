// Runs the real app on a simulator or device with example data and takes a
// screenshot of every main screen. Used to check the layout on a real screen
// and for the README pictures.
//
// Run (iOS simulator or Android emulator must be running):
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/app_screenshots_test.dart
// The pictures land in screenshots/ (see test_driver/integration_test.dart).
//
// On the iOS simulator, allow the camera first, otherwise the permission
// dialog covers the app and the pictures stay white:
//   xcrun simctl privacy booted grant camera com.diyarkaymaz.foodTracker
//
// Everything is offline and repeatable: an in-memory database with example
// foods, a fixed "today" and no internet (Open Food Facts is never called).

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/diary/diary_repository.dart';
import 'package:food_tracker/features/goals/goal_enums.dart';
import 'package:food_tracker/features/goals/goals_repository.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/pump_app.dart';

/// Example foods: name, values per 100 g/ml, OFF data for the rating.
FoodsCompanion _food(
  String name, {
  String? brand,
  required double kcal,
  required double fat,
  required double saturatedFat,
  required double carbs,
  required double sugars,
  double? fibre,
  required double protein,
  required double salt,
  String? categories,
  String? nutriScore,
  bool isLiquid = false,
  String? quantityLabel,
  double? servingSize,
  String? servingLabel,
  bool isFavourite = false,
  FoodSource source = FoodSource.openFoodFacts,
}) {
  return FoodsCompanion.insert(
    source: source,
    name: name,
    brand: Value(brand),
    kcal: Value(kcal),
    fat: Value(fat),
    saturatedFat: Value(saturatedFat),
    carbs: Value(carbs),
    sugars: Value(sugars),
    fibre: Value(fibre),
    protein: Value(protein),
    salt: Value(salt),
    categories: Value(categories),
    nutriScore: Value(nutriScore),
    isLiquid: Value(isLiquid),
    quantityLabel: Value(quantityLabel),
    servingSize: Value(servingSize),
    servingLabel: Value(servingLabel),
    isFavourite: Value(isFavourite),
    fetchedAt: Value(testNow),
    createdAt: testNow,
  );
}

/// Fills [db] with a realistic week and returns the id of the crisps.
Future<int> _seed(AppDatabase db) async {
  Future<Food> add(FoodsCompanion food) async {
    final id = await db.into(db.foods).insert(food);
    return (db.select(db.foods)..where((f) => f.id.equals(id))).getSingle();
  }

  final oats = await add(
    _food(
      'Haferflocken, zart',
      kcal: 372,
      fat: 7,
      saturatedFat: 1.3,
      carbs: 58.7,
      sugars: 0.7,
      fibre: 10,
      protein: 13.5,
      salt: 0.02,
      categories: 'en:cereals-and-potatoes,en:breakfast-cereals',
      nutriScore: 'A',
      isFavourite: true,
    ),
  );
  final milk = await add(
    _food(
      'Fettarme Milch 1,5 %',
      kcal: 47,
      fat: 1.5,
      saturatedFat: 1.0,
      carbs: 4.9,
      sugars: 4.9,
      protein: 3.4,
      salt: 0.13,
      categories: 'en:beverages,en:dairies,en:milks',
      nutriScore: 'A',
      isLiquid: true,
    ),
  );
  final banana = await add(
    _food(
      'Banane',
      kcal: 93,
      fat: 0.2,
      saturatedFat: 0.1,
      carbs: 20,
      sugars: 17,
      fibre: 1.7,
      protein: 1.1,
      salt: 0,
      source: FoodSource.user,
      servingSize: 120,
      servingLabel: '1 Stück (120 g)',
    ),
  );
  final pasta = await add(
    _food(
      'Vollkorn-Spaghetti',
      kcal: 352,
      fat: 2.5,
      saturatedFat: 0.5,
      carbs: 64,
      sugars: 3.5,
      fibre: 8,
      protein: 13,
      salt: 0.01,
      categories: 'en:pastas',
      nutriScore: 'A',
    ),
  );
  final sauce = await add(
    _food(
      'Tomatensoße Basilikum',
      kcal: 45,
      fat: 1.2,
      saturatedFat: 0.2,
      carbs: 6.5,
      sugars: 5.6,
      fibre: 1.5,
      protein: 1.6,
      salt: 0.9,
      categories: 'en:sauces,en:tomato-sauces',
      nutriScore: 'B',
    ),
  );
  final crisps = await add(
    _food(
      'Kartoffelchips Paprika',
      brand: 'Beispielmarke',
      kcal: 536,
      fat: 32,
      saturatedFat: 3.1,
      carbs: 53,
      sugars: 2.5,
      fibre: 4.4,
      protein: 6.3,
      salt: 1.6,
      categories: 'en:snacks,en:salty-snacks,en:crisps',
      nutriScore: 'D',
      quantityLabel: '175 g',
      servingSize: 30,
      servingLabel: '1 Handvoll (30 g)',
      isFavourite: true,
    ),
  );

  final diary = DiaryRepository(db, Clock.fixed(testNow));
  // Default meals: 1 breakfast, 2 lunch, 3 dinner, 4 snacks.
  Future<void> eat(Food food, double amount, String day, int meal) =>
      diary.addEntry(food: food, amount: amount, day: day, mealSlotId: meal);

  const today = '2026-11-14';
  await eat(oats, 60, today, 1);
  await eat(milk, 200, today, 1);
  await eat(banana, 120, today, 1);
  await eat(pasta, 125, today, 2);
  await eat(sauce, 150, today, 2);
  await eat(crisps, 30, today, 4);

  // Monday to Friday of this week.
  const week = [
    ('2026-11-09', 1.0),
    ('2026-11-10', 1.25),
    ('2026-11-11', 0.9),
    ('2026-11-12', 1.4),
    ('2026-11-13', 1.1),
  ];
  for (final (day, factor) in week) {
    await eat(oats, 70 * factor, day, 1);
    await eat(milk, 250, day, 1);
    await eat(pasta, 140 * factor, day, 2);
    await eat(sauce, 180, day, 2);
    await eat(pasta, 100 * factor, day, 3);
    await eat(crisps, 40 * factor, day, 4);
  }

  await GoalsRepository(db, Clock.fixed(testNow)).saveGoal(
    kcal: 2300,
    protein: 75,
    carbs: 300,
    fat: 77,
    sex: Sex.male,
    age: 24,
    heightCm: 178,
    weightKg: 75,
    activity: ActivityLevel.light,
    goalType: GoalType.maintain,
  );
  return crisps.id;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(WidgetTester tester, String name) async {
    // Shows in the log which screen was reached (helps when a step fails).
    debugPrint('screenshot: $name');
    await tester.pumpAndSettle();
    // On a real device the database answers asynchronously and tab changes
    // animate: wait a moment so the picture shows the finished screen.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  Future<GoRouterLike> startApp(
    WidgetTester tester, {
    required AppDatabase db,
    String locale = 'de',
    String theme = 'light',
  }) async {
    final overrides = testOverrides(
      db: db,
      now: testNow,
      // Load the real bundled food lists, so the search shows real results.
      realFoodLists: true,
    );
    final prefs = SharedPreferencesAsync();
    await prefs.setString('locale', locale);
    await prefs.setString('theme_mode', theme);
    await prefs.setBool('goal_card_dismissed', true);
    // Remove a previous app first, so its settings are read again.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: overrides,
        child: const FoodTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FoodTrackerApp)),
    );
    return GoRouterLike(container);
  }

  Future<void> scrollDown(WidgetTester tester, double by) async {
    await tester.drag(find.byType(Scrollable).first, Offset(0, -by));
    await tester.pumpAndSettle();
  }

  testWidgets('screenshots, German, light', (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final crispsId = await _seed(db);
    final app = await startApp(tester, db: db);

    await shot(tester, '01-today');
    await scrollDown(tester, 500);
    await shot(tester, '02-today-meals');

    // Tapping a meal tile opens its entries in a sheet.
    await tester.ensureVisible(find.text('Frühstück'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Frühstück'));
    await shot(tester, '02b-today-meal-sheet');
    await tester.tapAt(const Offset(20, 60)); // outside the sheet: close it
    await tester.pumpAndSettle();

    app.go(Routes.food(crispsId));
    await shot(tester, '03-product');
    await scrollDown(tester, 600);
    await shot(tester, '04-product-portion');

    app.go(Routes.addFood('2026-11-14', 3));
    await shot(tester, '05-add-food');
    // The simple food list while typing (offline: no brand products here).
    await tester.enterText(find.byType(TextField).first, 'skyr');
    await tester.pump(const Duration(seconds: 2));
    await shot(tester, '05b-search-skyr');
    await tester.enterText(find.byType(TextField).first, 'reis');
    await tester.pump(const Duration(seconds: 2));
    await shot(tester, '05c-search-reis');
    // Close the keyboard again: a text field that is still focused when the
    // test tears the app down crashes Flutter's semantics update on iOS.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    app.go(Routes.scan);
    // Give the camera time to start (or to report that there is none).
    await tester.pump(const Duration(seconds: 3));
    await shot(tester, '06-scan');

    app.go(Routes.stats);
    await shot(tester, '07-stats');

    app.go(Routes.profile);
    await shot(tester, '08-profile');

    app.go(Routes.goal);
    await shot(tester, '09-goal');

    app.go(Routes.meals);
    await shot(tester, '10-meals');
  });

  testWidgets('screenshots, dark and English', (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final crispsId = await _seed(db);
    final app = await startApp(tester, db: db, theme: 'dark');

    await shot(tester, '11-today-dark');
    app.go(Routes.food(crispsId));
    await shot(tester, '12-product-dark');
    app.go(Routes.stats);
    await shot(tester, '13-stats-dark');

    final appEn = await startApp(tester, db: db, locale: 'en');
    appEn.go(Routes.today);
    await shot(tester, '14-today-english');
  });
}

/// Small wrapper so the test can navigate like a user who knows the address.
class GoRouterLike {
  GoRouterLike(this._container);
  final ProviderContainer _container;

  void go(String location) => _container.read(routerProvider).go(location);
}
