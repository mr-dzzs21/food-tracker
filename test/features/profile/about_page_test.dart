import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/app.dart';
import 'package:food_tracker/data/database.dart';
import 'package:food_tracker/router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  /// Opens the about page on a tall screen, so the whole list is built.
  Future<void> openAbout(
    WidgetTester tester, {
    Locale locale = const Locale('de'),
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpFoodTrackerApp(tester, db: db, locale: locale);
    ProviderScope.containerOf(tester.element(find.byType(FoodTrackerApp)))
        .read(routerProvider)
        .go(Routes.about);
    await tester.pumpAndSettle();
  }

  testWidgets('version, licence, data source, privacy and help', (
    tester,
  ) async {
    await openAbout(tester);
    expect(find.text('Food Tracker'), findsOneWidget);
    expect(find.text('Version 0.1.0-test'), findsOneWidget);
    expect(find.text('Open Source (MIT)'), findsOneWidget);
    expect(find.text('Quellcode auf GitHub'), findsOneWidget);
    // The full attribution text of the brief (off-api.md R13).
    expect(
      find.text(
        'Produktdaten stammen von Open Food Facts (openfoodfacts.org) und '
        'stehen unter der Open Database License (ODbL); einzelne Inhalte '
        'unter der Database Contents License (DbCL), Produktfotos unter '
        'Creative Commons BY-SA. Die Daten werden von Freiwilligen gepflegt '
        'und können unvollständig oder fehlerhaft sein – prüf im Zweifel die '
        'Verpackung.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('keine medizinische Beratung'), findsOneWidget);
    expect(find.textContaining('Schätzungen für gesunde Erwachsene'), findsOne);
    expect(
      find.text(
        'Alle Daten bleiben auf deinem Gerät. Die App hat kein Konto, keine '
        'Werbung und kein Tracking. Nur Produktsuchen werden an Open Food '
        'Facts gesendet.',
      ),
      findsOneWidget,
    );
    expect(find.text('0221 892031 anrufen'), findsOneWidget);
    expect(find.text('Webseite: essstoerungen.bioeg.de'), findsOneWidget);
  });

  testWidgets('"Open-Source-Lizenzen" opens the licence page', (tester) async {
    await openAbout(tester);
    await tester.tap(find.text('Open-Source-Lizenzen'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('English: attribution and the German helpline', (tester) async {
    await openAbout(tester, locale: const Locale('en'));
    expect(find.text('About the app'), findsOneWidget);
    expect(
      find.textContaining('Product data comes from Open Food Facts'),
      findsOneWidget,
    );
    expect(find.textContaining('talk to someone you trust'), findsOneWidget);
    expect(find.text('Call 0221 892031'), findsOneWidget);
  });
}
