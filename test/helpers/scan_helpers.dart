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
/// camera had read a barcode.
class FakeScanner {
  ScannedCodeCallback? _onCode;

  /// The key of the grey box shown instead of the camera.
  static const boxKey = Key('fake-scanner');

  Override get override => scannerViewProvider.overrideWithValue((onCode) {
    _onCode = onCode;
    return const ColoredBox(key: boxKey, color: Color(0xFF808080));
  });

  /// Like a detected (already checked) barcode. Do not await it: the real
  /// scanner waits until the product page is closed again.
  Future<void> scan(String code) {
    final onCode = _onCode;
    if (onCode == null) throw StateError('The scanner is not on screen.');
    return onCode(code);
  }
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
