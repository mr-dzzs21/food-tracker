import 'package:flutter_test/flutter_test.dart';
import 'package:food_tracker/features/scan/widgets/barcode_scanner_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('normaliseScannedCode', () {
    test('a valid EAN-13 is kept', () {
      expect(normaliseScannedCode('4003586100313'), '4003586100313');
    });

    test('UPC-A gets the leading zero that Open Food Facts uses', () {
      expect(normaliseScannedCode('036000291452'), '0036000291452');
    });

    test('UPC-E is expanded', () {
      expect(normaliseScannedCode('04252614'), '0042100005264');
    });

    test('spaces around the code are ignored', () {
      expect(normaliseScannedCode(' 42376095 '), '42376095');
    });

    test('wrong check digit, wrong length or letters: invalid', () {
      expect(normaliseScannedCode('4003586100314'), isNull); // check digit
      expect(normaliseScannedCode('1234567'), isNull); // too short
      expect(normaliseScannedCode('https://example.org'), isNull); // QR text
      expect(normaliseScannedCode(''), isNull);
    });
  });

  group('ScannerErrorView', () {
    Future<void> pumpError(
      WidgetTester tester,
      MobileScannerErrorCode code, {
      Locale locale = const Locale('de'),
      VoidCallback? onRetry,
    }) async {
      final db = newTestDatabase();
      addTearDown(db.close);
      await pumpWidgetInApp(
        tester,
        Scaffold(
          body: ScannerErrorView(errorCode: code, onRetry: onRetry),
        ),
        db: db,
        locale: locale,
      );
    }

    testWidgets('permission denied explains where to allow the camera', (
      tester,
    ) async {
      await pumpError(tester, MobileScannerErrorCode.permissionDenied);

      expect(find.text('Kein Zugriff auf die Kamera'), findsOneWidget);
      expect(
        find.textContaining('Einstellungen › Food Tracker › Kamera'),
        findsOneWidget,
      );
      // Asking again is not possible, so there is no button.
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('no camera (simulator) points to the search', (tester) async {
      await pumpError(tester, MobileScannerErrorCode.unsupported);

      expect(
        find.text('Hier gibt es keine Kamera. Nutze die Suche.'),
        findsOneWidget,
      );
    });

    testWidgets('other errors offer a retry', (tester) async {
      var retries = 0;
      await pumpError(
        tester,
        MobileScannerErrorCode.genericError,
        onRetry: () => retries++,
      );

      expect(
        find.text(
          'Die Kamera konnte nicht starten. Versuch es noch mal oder nutze '
          'die Suche.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Nochmal versuchen'));
      expect(retries, 1);
    });

    testWidgets('English texts', (tester) async {
      await pumpError(
        tester,
        MobileScannerErrorCode.unsupported,
        locale: const Locale('en'),
      );
      expect(
        find.text('There is no camera here. Use the search.'),
        findsOneWidget,
      );
    });

    testWidgets('long text at text scale 2.0 does not overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 300);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpError(tester, MobileScannerErrorCode.permissionDenied);

      expect(tester.takeException(), isNull);
      expect(find.text('Kein Zugriff auf die Kamera'), findsOneWidget);
    });
  });
}
