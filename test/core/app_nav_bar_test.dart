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

    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();
    expect(find.text('Diese Woche'), findsOneWidget);
    expect(
      tester.getSemantics(tab('Statistik')),
      isSemantics(isSelected: true),
    );
    expect(tester.getSemantics(tab('Heute')), isSemantics(isSelected: false));
    // The brand colour marks the open tab.
    final context = tester.element(find.byType(AppNavBar));
    final label = tester.widget<Text>(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.text('Statistik'),
      ),
    );
    expect(label.style?.color, context.appColors.brand);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Dein Tagesziel'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the raised scan button opens the Scan tab, also when tapped '
      'above the bar', (tester) async {
    await pumpApp(tester);
    final bar = tester.getRect(
      find
          .descendant(
            of: find.byType(AppNavBar),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final icon = tester.getRect(find.byIcon(Icons.qr_code_scanner_rounded));
    // The square sticks out above the white bar …
    expect(icon.top, lessThan(bar.top));

    // … and that part reacts to taps, too.
    await tester.tapAt(Offset(icon.center.dx, bar.top - 8));
    await tester.pumpAndSettle();
    expect(find.byKey(FakeScanner.boxKey), findsOneWidget);
  });

  testWidgets('the page stays tappable next to the raised button', (
    tester,
  ) async {
    await pumpApp(tester);
    final bar = tester.getRect(
      find
          .descendant(
            of: find.byType(AppNavBar),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    // Above the "Profil" tab, inside the strip the scan button sticks
    // into: nothing of the bar may catch the tap.
    final profile = tester.getCenter(find.text('Profil'));
    final hit = tester.hitTestOnBinding(Offset(profile.dx, bar.top - 8));
    final barElement = tester.element(find.byType(AppNavBar));
    final barRenderObject = barElement.renderObject;
    expect(
      hit.path.any((entry) => identical(entry.target, barRenderObject)),
      isFalse,
    );
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
    expect(find.text('Statistik'), findsOneWidget);
  });
}
