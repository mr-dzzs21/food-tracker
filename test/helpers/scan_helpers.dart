import 'package:clock/clock.dart';
// `Override` (the type of provider overrides) lives in misc.dart in Riverpod 3.
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:food_tracker/features/products/off_client.dart';
import 'package:food_tracker/features/products/product_repository.dart';
import 'package:food_tracker/features/scan/widgets/barcode_scanner_view.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'pump_app.dart';

/// Stands in for the camera in widget tests (the real camera is a platform
/// view that does not exist there).
///
/// Add [override] to the test's overrides and call [scan] to act as if the
/// camera had read a barcode. It follows the same rules as the real scanner
/// ([ScanGate]): codes count only while the page is visible and no other
/// code is being handled.
class FakeScanner {
  _FakeScannerViewState? _view;

  /// The key of the grey box shown instead of the camera.
  static const boxKey = Key('fake-scanner');

  Override get override => scannerViewProvider.overrideWithValue(
    (onCode) => _FakeScannerView(scanner: this, onCode: onCode),
  );

  /// Whether the real camera would run now (page visible, no code being
  /// handled).
  bool get isRunning => _view?.isReady ?? false;

  /// Like a detected (already checked) barcode. Ignored while the camera
  /// would be stopped (see [isRunning]), like on a phone. Do not await it:
  /// the real scanner waits until the product page is closed again.
  Future<void> scan(String code) {
    final view = _view;
    if (view == null) throw StateError('The scanner is not on screen.');
    return view.handleCode(code, view.widget.onCode);
  }
}

class _FakeScannerView extends StatefulWidget {
  const _FakeScannerView({required this.scanner, required this.onCode});

  final FakeScanner scanner;
  final ScannedCodeCallback onCode;

  @override
  State<_FakeScannerView> createState() => _FakeScannerViewState();
}

class _FakeScannerViewState extends State<_FakeScannerView> with ScanGate {
  @override
  void initState() {
    super.initState();
    widget.scanner._view = this;
  }

  @override
  void dispose() {
    if (widget.scanner._view == this) widget.scanner._view = null;
    super.dispose();
  }

  /// No camera to start or stop.
  @override
  Future<void> syncScanner() async {}

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(key: FakeScanner.boxKey, color: Color(0xFF808080));
}

/// An Open Food Facts client that does not wait between searches or before
/// its one retry, so tests need no fake time for that.
Override offClientWithoutDelays(http.Client client) =>
    offClientProvider.overrideWithValue(
      OpenFoodFactsClient(
        client,
        userAgent: 'FoodTracker/0.1.0-test (test)',
        clock: Clock.fixed(testNow),
        delay: (_) async {},
      ),
    );
