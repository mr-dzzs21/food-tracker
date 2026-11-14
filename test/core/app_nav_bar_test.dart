import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/core/theme/app_theme.dart';
import 'package:food_tracker/core/widgets/app_nav_bar.dart';
import 'package:food_tracker/data/database.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';
import '../helpers/scan_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  /// The screen-reader node of the tab called [label].
  Finder tab(String label) => find.descendant(
    of: find.byType(AppNavBar),
    matching: find.bySemanticsLabel(label),
  );

  Future<void> pumpApp(WidgetTester tester, {ThemeMode? themeMode}) =>
      pumpFoodTrackerApp(
        tester,
        db: db,
        themeMode: themeMode,
        // The Scan tab needs the fake camera.
        extraOverrides: [FakeScanner().override],
      );

  testWidgets('four tabs as buttons; the open one is selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);

    for (final label in ['Heute', 'Scannen', 'Statistik', 'Profil']) {
      expect(
        tester.getSemantics(tab(label)),
        isSemantics(
          label: label,
          isButton: true,
          isSelected: label == 'Heute',
          hasTapAction: true,
        ),
        reason: label,
      );
      // At least 48 × 48 to touch.
      final size = tester.getSize(tab(label));
      expect(size.width, greaterThanOrEqualTo(48), reason: label);
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
    }
    semantics.dispose();
  });

  testWidgets('tapping a tab opens it and marks it selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);

    await tester.tap(tab('Statistik'));
    await tester.pumpAndSettle();
    expect(find.text('Diese Woche'), findsOneWidget);
    expect(
      tester.getSemantics(tab('Statistik')),
      isSemantics(isSelected: true),
    );
    expect(tester.getSemantics(tab('Heute')), isSemantics(isSelected: false));
    // The open tab is a mint pill with icon and label; the others show
    // only their icon (the tooltip names them).
    final context = tester.element(find.byType(AppNavBar));
    final label = tester.widget<Text>(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.text('Statistik'),
      ),
    );
    expect(label.style?.color, context.appColors.onNavActive);
    expect(
      find.descendant(of: find.byType(AppNavBar), matching: find.text('Heute')),
      findsNothing,
    );
    // (The tooltip is not in the semantics tree – the tab's own node names
    // it – so find.byTooltip does not see it.)
    expect(
      find.byWidgetPredicate((w) => w is Tooltip && w.message == 'Heute'),
      findsOneWidget,
    );

    await tester.tap(tab('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Dein Tagesziel'), findsOneWidget);
    semantics.dispose();
  });

  /// The width of the tab called [label] (the open one is wider).
  double pillWidth(WidgetTester tester, String label) =>
      tester.getSize(tab(label)).width;

  testWidgets('the open tab grows smoothly, the old one shrinks', (
    tester,
  ) async {
    await pumpApp(tester);
    final todayWide = pillWidth(tester, 'Heute');
    final statsNarrow = pillWidth(tester, 'Statistik');
    expect(todayWide, greaterThan(statsNarrow));

    await tester.tap(tab('Statistik'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Half-way: the new tab is wider than before, not yet full width.
    final halfway = pillWidth(tester, 'Statistik');
    expect(halfway, greaterThan(statsNarrow));
    expect(halfway, lessThan(todayWide));

    await tester.pumpAndSettle();
    expect(pillWidth(tester, 'Statistik'), todayWide);
    expect(pillWidth(tester, 'Heute'), statsNarrow);
  });

  testWidgets('reduced motion: the pill moves at once', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    final wide = pillWidth(tester, 'Heute');

    await tester.tap(tab('Profil'));
    await tester.pump();
    await tester.pump();
    expect(pillWidth(tester, 'Profil'), wide);
  });

  testWidgets('a new screen width applies at once (no overflow)', (
    tester,
  ) async {
    await pumpApp(tester);
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pump();
    expect(tester.takeException(), isNull);
    // 360 − 2 × 18 px margin − 2 × 8 px padding = 308 px for the tabs.
    expect(
      pillWidth(tester, 'Heute'),
      closeTo(308 * AppNavBar.selectedShare, 0.01),
    );
  });

  testWidgets('the floating bar covers no page content', (tester) async {
    await pumpApp(tester);
    final bar = tester.getRect(
      find
          .descendant(
            of: find.byType(AppNavBar),
            matching: find.byType(Container),
          )
          .first,
    );
    // 18 px from the sides of the 800 px wide test screen.
    expect(bar.left, AppNavBar.margin);
    expect(bar.height, AppNavBar.height);
    // The page (its scroll view) ends above the bar.
    final page = tester.getRect(find.byType(Scrollable).first);
    expect(page.bottom, lessThanOrEqualTo(bar.top));
  });

  testWidgets('dark mode and large text render without overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpApp(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(AppNavBar));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
    // Only the open tab shows its label.
    expect(
      find.descendant(of: find.byType(AppNavBar), matching: find.text('Heute')),
      findsOneWidget,
    );
  });
}
