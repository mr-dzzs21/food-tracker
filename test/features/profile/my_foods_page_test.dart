import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/core/widgets/buttons.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/products/food_form_page.dart';
import 'package:food_tracker/features/products/food_source.dart';
import 'package:food_tracker/features/products/product_page.dart';
import 'package:food_tracker/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  Future<Food> addFood(
    String name, {
    FoodSource source = FoodSource.user,
    String? barcode,
  }) => db
      .into(db.foods)
      .insertReturning(
        FoodsCompanion.insert(
          source: source,
          name: name,
          barcode: Value(barcode),
          kcal: const Value(80),
          createdAt: testNow,
        ),
      );

  Future<void> openMyFoods(
    WidgetTester tester, {
    Locale locale = const Locale('de'),
  }) async {
    await pumpFoodTrackerApp(tester, db: db, locale: locale);
    ProviderScope.containerOf(tester.element(find.byType(FoodTrackerApp)))
        .read(routerProvider)
        .go(Routes.myFoods);
    await tester.pumpAndSettle();
  }

  testWidgets('empty: explains own foods and opens the form', (tester) async {
    await openMyFoods(tester);
    expect(find.text('Noch keine eigenen Lebensmittel'), findsOneWidget);
    // Only one "create" button (no bottom button on the empty page).
    expect(find.byType(CtaButton), findsNothing);

    await tester.tap(find.text('Eigenes Lebensmittel anlegen'));
    await tester.pumpAndSettle();
    expect(find.byType(FoodFormPage), findsOneWidget);
    expect(find.text('Neues Lebensmittel'), findsOneWidget);
  });

  testWidgets('lists only own foods, sorted by name', (tester) async {
    await addFood('Linsensuppe');
    await addFood('apfelmus');
    await addFood('Cola', source: FoodSource.openFoodFacts, barcode: '1');
    await openMyFoods(tester);

    expect(find.text('Cola'), findsNothing);
    expect(find.text('Noch keine eigenen Lebensmittel'), findsNothing);
    expect(
      tester.getTopLeft(find.text('apfelmus')).dy,
      lessThan(tester.getTopLeft(find.text('Linsensuppe')).dy),
    );
    expect(find.byType(CtaButton), findsOneWidget);

    // Tap → product page of that food.
    await tester.tap(find.text('Linsensuppe'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductPage), findsOneWidget);
  });

  testWidgets('menu: "Bearbeiten" opens the form', (tester) async {
    final food = await addFood('Linsensuppe');
    await openMyFoods(tester);
    await tester.tap(find.byTooltip('Mehr zu Linsensuppe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bearbeiten'));
    await tester.pumpAndSettle();
    final form = tester.widget<FoodFormPage>(find.byType(FoodFormPage));
    expect(form.foodId, food.id);
  });

  testWidgets('menu: "Löschen" asks and removes the food', (tester) async {
    await addFood('Linsensuppe');
    await openMyFoods(tester);
    await tester.tap(find.byTooltip('Mehr zu Linsensuppe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();
    expect(find.text('„Linsensuppe“ löschen?'), findsOneWidget);
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    expect(find.text('„Linsensuppe“ gelöscht'), findsOneWidget);
    expect(find.text('Noch keine eigenen Lebensmittel'), findsOneWidget);
    expect(await db.select(db.foods).get(), isEmpty);
  });

  testWidgets('deleted from its product page (✎ → 🗑): the product page '
      'closes, back on the list', (tester) async {
    await addFood('Linsensuppe');
    await openMyFoods(tester);
    await tester.tap(find.text('Linsensuppe'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductPage), findsOneWidget);
    await tester.tap(find.byTooltip('Bearbeiten'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Löschen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    expect(find.text('Dieses Lebensmittel gibt es nicht mehr.'), findsNothing);
    expect(find.byType(ProductPage), findsNothing);
    expect(
      ProviderScope.containerOf(tester.element(find.byType(FoodTrackerApp)))
          .read(routerProvider)
          .state
          .uri
          .toString(),
      Routes.myFoods,
    );
    expect(find.text('„Linsensuppe“ gelöscht'), findsOneWidget);
    expect(find.text('Noch keine eigenen Lebensmittel'), findsOneWidget);
  });

  testWidgets('English: empty state', (tester) async {
    await openMyFoods(tester, locale: const Locale('en'));
    expect(find.text('My foods'), findsOneWidget);
    expect(find.text('No own foods yet'), findsOneWidget);
    expect(find.text('Create own food'), findsOneWidget);
  });
}
