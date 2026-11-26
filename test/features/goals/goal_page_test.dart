import 'dart:ui' show Tristate;

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/core/widgets/buttons.dart';
import 'package:food_tracker/core/widgets/pill_choices.dart';
import 'package:food_tracker/core/widgets/selectable_card.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/features/goals/goal_enums.dart';
import 'package:food_tracker/features/goals/goal_page.dart';
import 'package:food_tracker/features/goals/goals_repository.dart';
import 'package:food_tracker/features/profile/profile_page.dart';
import 'package:food_tracker/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late GoalsRepository goals;

  setUp(() {
    db = newTestDatabase();
    goals = GoalsRepository(db, Clock.fixed(testNow));
  });

  tearDown(() => db.close());

  /// Starts the app and opens the goal page of the Profil tab (with `go`,
  /// so the profile page is below it).
  Future<void> openGoalPage(
    WidgetTester tester, {
    Locale locale = const Locale('de'),
    Size size = const Size(800, 3200),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(tester, db: db, locale: locale);
    ProviderScope.containerOf(tester.element(find.byType(FoodTrackerApp)))
        .read(routerProvider)
        .go(Routes.goal);
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> enter(WidgetTester tester, String label, String text) async {
    await tester.enterText(field(label), text);
    await tester.pump();
  }

  /// The N1 person of the brief: male, 30 y, 180 cm, 80 kg.
  Future<void> fillMale80(WidgetTester tester) async {
    await tester.tap(find.text('männlich'));
    await enter(tester, 'Alter', '30');
    await enter(tester, 'Größe', '180');
    await enter(tester, 'Gewicht', '80');
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the live result of the calculator (brief N5)', (
    tester,
  ) async {
    await openGoalPage(tester);
    expect(
      find.text(
        'Fülle Alter, Größe und Gewicht aus, dann siehst du hier dein '
        'Ergebnis.',
      ),
      findsOneWidget,
    );
    // Saving is not possible without a result.
    expect(
      tester
          .widget<CtaButton>(find.widgetWithText(CtaButton, 'Ziel übernehmen'))
          .onPressed,
      isNull,
    );

    await fillMale80(tester);
    await tapText(tester, 'Etwas aktiv');
    await tapText(tester, 'Abnehmen (0,5 kg/Woche)');

    expect(find.text('ca. 1.780 kcal'), findsOneWidget); // basal rate
    expect(find.text('ca. 2.850 kcal'), findsOneWidget); // 2848 → "ca."
    expect(find.text('2.298 kcal'), findsOneWidget); // daily goal
    expect(find.text('mind. 64 g'), findsOneWidget); // protein
    expect(find.text('338 g'), findsOneWidget); // carbohydrates
    expect(find.text('77 g'), findsOneWidget); // fat
    expect(find.text('mind. 30 g'), findsOneWidget); // fibre
    expect(find.textContaining('Wir schlagen nicht weniger'), findsNothing);
    expect(find.text('Hinweis für unter 18-Jährige'), findsNothing);
    // Always visible: disclaimer and eating-disorder help.
    expect(find.textContaining('Schätzungen für gesunde Erwachsene'), findsOne);
    expect(find.text('0221 892031 anrufen'), findsOneWidget);
  });

  testWidgets('a goal below the floor is raised and explained (brief N8)', (
    tester,
  ) async {
    await openGoalPage(tester);
    await tester.tap(find.text('weiblich'));
    await enter(tester, 'Alter', '60');
    await enter(tester, 'Größe', '155');
    await enter(tester, 'Gewicht', '50');
    await tapText(tester, 'Abnehmen (0,5 kg/Woche)');

    expect(find.text('1.200 kcal'), findsOneWidget);
    expect(
      find.text('Wir schlagen nicht weniger als 1.200 kcal pro Tag vor.'),
      findsOneWidget,
    );
  });

  testWidgets('under 18: the result plus an extra hint card', (tester) async {
    await openGoalPage(tester);
    await enter(tester, 'Alter', '16');
    expect(find.text('Hinweis für unter 18-Jährige'), findsOneWidget);

    await enter(tester, 'Größe', '165');
    await enter(tester, 'Gewicht', '55');
    // Owner's decision: no age limit, the result is still shown.
    expect(find.text('Dein Ergebnis'), findsOneWidget);
    expect(find.textContaining('ca. '), findsNWidgets(2));
    expect(find.text('Hinweis für unter 18-Jährige'), findsOneWidget);

    await enter(tester, 'Alter', '18');
    expect(find.text('Hinweis für unter 18-Jährige'), findsNothing);
  });

  testWidgets('invalid numbers show an error and no result', (tester) async {
    await openGoalPage(tester);
    await enter(tester, 'Alter', '130');
    await enter(tester, 'Größe', '180');
    await enter(tester, 'Gewicht', '80');
    expect(
      find.text('Bitte gib ein Alter von 1 bis 120 Jahren ein.'),
      findsOneWidget,
    );
    expect(find.textContaining('ca. '), findsNothing);
  });

  testWidgets('"Ziel übernehmen" saves the goal and goes back to Profil', (
    tester,
  ) async {
    await openGoalPage(tester);
    await fillMale80(tester);
    await tapText(tester, 'Etwas aktiv');
    await tapText(tester, 'Abnehmen (0,5 kg/Woche)');
    await tapText(tester, 'Ziel übernehmen');

    final goal = await goals.getGoal();
    expect(goal, isNotNull);
    expect(goal!.kcal, 2298);
    expect(goal.protein, closeTo(64, 1e-9));
    expect(goal.fat, closeTo(2298 * 0.3 / 9, 1e-9));
    expect(goal.sex, Sex.male);
    expect(goal.age, 30);
    expect(goal.heightCm, 180);
    expect(goal.weightKg, 80);
    expect(goal.activity, ActivityLevel.light);
    expect(goal.goalType, GoalType.lose);

    expect(find.byType(GoalPage), findsNothing);
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Dein Tagesziel ist gespeichert.'), findsOneWidget);
    expect(find.text('2.298 kcal pro Tag'), findsOneWidget);
  });

  testWidgets('the saved calculator goal fills the form again', (tester) async {
    await goals.saveGoal(
      kcal: 2298,
      sex: Sex.male,
      age: 30,
      heightCm: 180,
      weightKg: 80,
      activity: ActivityLevel.light,
      goalType: GoalType.lose,
    );
    await openGoalPage(tester);
    String text(String label) => tester
        .widget<EditableText>(
          find.descendant(
            of: field(label),
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;
    expect(text('Alter'), '30');
    expect(text('Größe'), '180');
    expect(text('Gewicht'), '80');
    expect(find.text('2.298 kcal'), findsOneWidget);
  });

  group('manual goal', () {
    Future<void> openManual(WidgetTester tester) async {
      await openGoalPage(tester);
      await tester.tap(find.text('Selbst eingeben'));
      await tester.pumpAndSettle();
    }

    testWidgets('above the floor: saved with default macros, no dialog', (
      tester,
    ) async {
      await openManual(tester);
      await enter(tester, 'Kalorien pro Tag', '2000');
      await tapText(tester, 'Speichern');

      expect(find.byType(AlertDialog), findsNothing);
      final goal = (await goals.getGoal())!;
      expect(goal.kcal, 2000);
      expect(goal.protein, closeTo(75, 1e-9)); // 15 % of the energy
      expect(goal.fat, closeTo(2000 * 0.3 / 9, 1e-9)); // 30 %
      expect(goal.carbs, closeTo(275, 1e-9)); // the rest
      expect(goal.sex, isNull); // no calculator inputs
    });

    testWidgets('below 1200 kcal asks once, gently', (tester) async {
      await openManual(tester);
      await enter(tester, 'Kalorien pro Tag', '1000');
      await enter(tester, 'Eiweiß', '90');
      await tapText(tester, 'Speichern');

      expect(find.text('Weniger als 1.200 kcal?'), findsOneWidget);
      await tester.tap(find.text('Ändern'));
      await tester.pumpAndSettle();
      expect(await goals.getGoal(), isNull);
      expect(find.byType(GoalPage), findsOneWidget);

      await tapText(tester, 'Speichern');
      await tester.tap(find.text('Trotzdem speichern'));
      await tester.pumpAndSettle();
      final goal = (await goals.getGoal())!;
      expect(goal.kcal, 1000);
      expect(goal.protein, 90);
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('the floor uses the basal rate from the calculator fields', (
      tester,
    ) async {
      await openGoalPage(tester);
      await fillMale80(tester); // basal rate 1780 kcal
      await tester.tap(find.text('Selbst eingeben'));
      await tester.pumpAndSettle();
      await enter(tester, 'Kalorien pro Tag', '1500');
      await tapText(tester, 'Speichern');
      expect(find.text('Weniger als 1.780 kcal?'), findsOneWidget);
    });

    testWidgets('"2.000" with the German thousands dot is 2000 kcal, never 2', (
      tester,
    ) async {
      await openManual(tester);
      await enter(tester, 'Kalorien pro Tag', '2.000');
      await tapText(tester, 'Speichern');

      // No "below the floor" dialog: it is 2000 kcal.
      expect(find.byType(AlertDialog), findsNothing);
      expect((await goals.getGoal())!.kcal, 2000);
    });

    testWidgets('a decimal is no calorie goal', (tester) async {
      await openManual(tester);
      await enter(tester, 'Kalorien pro Tag', '2,5');
      await tapText(tester, 'Speichern');
      expect(
        find.text('Bitte gib einen Wert von 1 bis 10.000 kcal ein.'),
        findsOneWidget,
      );
      expect(await goals.getGoal(), isNull);
    });

    testWidgets('kcal is required', (tester) async {
      await openManual(tester);
      await tapText(tester, 'Speichern');
      expect(
        find.text('Bitte gib einen Wert von 1 bis 10.000 kcal ein.'),
        findsOneWidget,
      );
      expect(await goals.getGoal(), isNull);
    });
  });

  testWidgets('pills and activity cards select their values', (tester) async {
    final semantics = tester.ensureSemantics();
    await openGoalPage(tester);

    bool selected(String label, Type type) {
      final widget = find.ancestor(
        of: find.text(label),
        matching: find.byType(type),
      );
      final data = tester.getSemantics(widget).getSemanticsData();
      return data.flagsCollection.isSelected == Tristate.isTrue;
    }

    // The defaults: calculator, "keine Angabe", "Wenig aktiv", "halten".
    expect(selected('Berechnen', Pill), isTrue);
    expect(selected('keine Angabe', Pill), isTrue);
    expect(selected('Wenig aktiv', SelectableCard), isTrue);
    expect(selected('Gewicht halten', Pill), isTrue);

    await tapText(tester, 'weiblich');
    await tapText(tester, 'Aktiv');
    await tapText(tester, 'Langsam zunehmen (0,25 kg/Woche)');
    expect(selected('weiblich', Pill), isTrue);
    expect(selected('keine Angabe', Pill), isFalse);
    expect(selected('Aktiv', SelectableCard), isTrue);
    expect(selected('Wenig aktiv', SelectableCard), isFalse);
    expect(selected('Langsam zunehmen (0,25 kg/Woche)', Pill), isTrue);
    expect(selected('Gewicht halten', Pill), isFalse);

    // The choices are saved with the goal.
    await enter(tester, 'Alter', '30');
    await enter(tester, 'Größe', '170');
    await enter(tester, 'Gewicht', '60');
    await tapText(tester, 'Ziel übernehmen');
    final goal = (await goals.getGoal())!;
    expect(goal.sex, Sex.female);
    expect(goal.activity, ActivityLevel.active);
    expect(goal.goalType, GoalType.gainSlow);
    semantics.dispose();
  });

  testWidgets('English: result and help text', (tester) async {
    await openGoalPage(tester, locale: const Locale('en'));
    await tester.tap(find.text('male'));
    await enter(tester, 'Age', '30');
    await enter(tester, 'Height', '180');
    await enter(tester, 'Weight', '80');
    expect(find.text('approx. 1,780 kcal'), findsOneWidget);
    expect(find.text('Call 0221 892031'), findsOneWidget);
    expect(find.textContaining('talk to someone you trust'), findsOneWidget);
  });

  testWidgets('English: "2,000" kcal is 2000, "2.000" is not a whole number', (
    tester,
  ) async {
    await openGoalPage(tester, locale: const Locale('en'));
    await tester.tap(find.text('Enter myself'));
    await tester.pumpAndSettle();
    await enter(tester, 'Calories per day', '2.000');
    await tapText(tester, 'Save');
    expect(find.textContaining('Please enter'), findsOneWidget);
    expect(await goals.getGoal(), isNull);

    await enter(tester, 'Calories per day', '2,000');
    await tapText(tester, 'Save');
    expect(find.byType(AlertDialog), findsNothing);
    expect((await goals.getGoal())!.kcal, 2000);
  });

  testWidgets('survives text scale 2.0 on a small phone', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openGoalPage(tester, size: const Size(360, 720));
    await fillMale80(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
