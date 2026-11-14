import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/status_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/gtin.dart';

/// Called with a checked, normalised barcode (ready for `Routes.product`).
///
/// The camera stays stopped until the returned future completes, so a page
/// that opens the product with `await context.push(...)` gets the camera
/// back automatically when the user returns.
typedef ScannedCodeCallback = Future<void> Function(String code);

/// Builds the camera area for a page.
typedef ScannerViewBuilder = Widget Function(ScannedCodeCallback onCode);

/// The camera area used by the Scan tab and the full-screen scanner.
///
/// Widget tests replace it (`scannerViewProvider.overrideWithValue(...)`),
/// because the real camera is a platform view that does not exist there.
final scannerViewProvider = Provider<ScannerViewBuilder>(
  (ref) =>
      (onCode) => BarcodeScannerView(onCode: onCode),
);

/// Checks a code the camera read: digits only, a correct check digit, and a
/// length of 8, 12, 13 or 14 (UPC-E is expanded).
///
/// Returns the normalised code, or `null` when it is not a valid barcode of
/// a product (for example a misread or an in-store code).
String? normaliseScannedCode(String rawValue) => lookupCodeFor(rawValue.trim());

/// Camera preview that reads product barcodes (EAN-13/8, UPC-A/E).
///
/// The camera runs only while the page is visible (not hidden behind another
/// tab or page) **and** the app is in the foreground, to save battery and
/// because the camera light would otherwise stay on. A torch button sits in
/// the corner. Without camera access, or on a device without a camera (the
/// simulator), a friendly explanation is shown instead.
class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key, required this.onCode});

  final ScannedCodeCallback onCode;

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView>
    with WidgetsBindingObserver {
  final _controller = MobileScannerController(
    autoStart: false, // we decide when the camera runs (see _shouldRun)
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 500, // at most about two detections per second
  );

  bool _visible = false;
  bool _appInForeground = true;

  /// True while [BarcodeScannerView.onCode] runs: further detections are
  /// ignored, otherwise one barcode would open the product several times.
  bool _handling = false;

  /// The last invalid code, so the same misread does not show a new SnackBar
  /// twice a second.
  String? _lastInvalidCode;

  bool get _shouldRun => _visible && _appInForeground && !_handling;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hidden tabs (StatefulShellRoute.indexedStack) and pages covered by
    // another page get TickerMode "disabled" – then the camera should stop.
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible != _visible) {
      _visible = visible;
      unawaited(_syncCamera());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The system's permission dialog also makes the app "inactive". Stopping
    // then would cancel the start that asked for the permission, so app
    // changes are ignored until the camera is allowed.
    if (!_controller.value.hasCameraPermission) return;
    _appInForeground = state == AppLifecycleState.resumed;
    unawaited(_syncCamera());
  }

  /// Starts or stops the camera so that it matches [_shouldRun].
  Future<void> _syncCamera() async {
    if (!mounted) return;
    try {
      if (_shouldRun) {
        await _controller.start();
        // The page may have been left while the camera was starting.
        if (mounted && !_shouldRun) await _controller.stop();
      } else {
        await _controller.stop();
      }
    } on MobileScannerException catch (error) {
      // A start is still running (for example after a quick tab switch).
      // That call checks _shouldRun again when it is done.
      if (error.errorCode != MobileScannerErrorCode.controllerInitializing) {
        rethrow;
      }
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || _handling) return;

    final code = normaliseScannedCode(raw);
    if (code == null) {
      // Keep scanning; the next try usually reads the code correctly.
      if (raw != _lastInvalidCode) {
        _lastInvalidCode = raw;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failureInvalidBarcode),
          ),
        );
      }
      return;
    }

    _handling = true;
    _lastInvalidCode = null;
    unawaited(HapticFeedback.selectionClick());
    await _syncCamera(); // stop while the product page is open
    try {
      await widget.onCode(code);
    } finally {
      _handling = false;
      await _syncCamera(); // back here: start again (if still visible)
    }
  }

  void _retry() => unawaited(_syncCamera());

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.scannerPreviewLabel,
      container: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            placeholderBuilder: (context) => const _CameraPlaceholder(),
            errorBuilder: (context, error) =>
                ScannerErrorView(errorCode: error.errorCode, onRetry: _retry),
          ),
          // Hint and torch only while the camera really runs.
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (!state.isRunning) return const SizedBox.shrink();
              return _CameraOverlay(
                torchState: state.torchState,
                onToggleTorch: () => unawaited(_controller.toggleTorch()),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Shown until the camera picture arrives.
class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ColoredBox(
      color: colors.camera,
      child: Center(
        child: Icon(
          Icons.photo_camera_rounded,
          size: 48,
          color: colors.onCamera.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// The viewfinder, the torch button at the top right and the hint at the
/// bottom.
class _CameraOverlay extends StatelessWidget {
  const _CameraOverlay({required this.torchState, required this.onToggleTorch});

  final TorchState torchState;
  final VoidCallback onToggleTorch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final torchOn = torchState == TorchState.on;
    return Stack(
      fit: StackFit.expand,
      children: [
        const ScannerViewfinder(),
        Padding(
          padding: const EdgeInsets.all(Spacing.m),
          child: Stack(
            children: [
              // Some devices (and the front camera) have no torch.
              if (torchState != TorchState.unavailable)
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: RoundIconButton(
                    tooltip: torchOn
                        ? l10n.scannerTorchOff
                        : l10n.scannerTorchOn,
                    icon: torchOn
                        ? Icons.flashlight_off_rounded
                        : Icons.flashlight_on_rounded,
                    background: colors.cameraScrim,
                    foreground: colors.onCamera,
                    onPressed: onToggleTorch,
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: colors.cameraScrim,
                    shape: const StadiumBorder(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.m,
                      vertical: 6,
                    ),
                    child: Text(
                      l10n.scannerHint,
                      style: Theme.of(context).textTheme.labelMedium!
                          .copyWith(color: colors.onCamera),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The dark frame over the camera picture with a clear, rounded window in
/// the middle and white rounded corner marks – "hold the barcode here".
///
/// Decoration only (no touch, no screen-reader node). Public so tests can
/// check where the window is.
class ScannerViewfinder extends StatelessWidget {
  const ScannerViewfinder({super.key});

  /// The clear window inside an area of [size]: 80 % of the width (at most
  /// 320 px), a barcode-like 16:10 shape, centred, never taller than half of
  /// the area.
  static Rect windowRect(Size size) {
    final width = math.min(size.width * 0.8, 320.0);
    final height = math.min(width * 0.625, size.height * 0.5);
    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IgnorePointer(
      child: CustomPaint(
        painter: _ViewfinderPainter(
          scrim: colors.cameraScrim,
          corners: colors.onCamera,
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter({required this.scrim, required this.corners});

  final Color scrim;
  final Color corners;

  static const double _radius = Radii.button;
  static const double _cornerLength = 26;
  static const double _stroke = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final window = RRect.fromRectAndRadius(
      ScannerViewfinder.windowRect(size),
      const Radius.circular(_radius),
    );
    // Everything dark except the window.
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Offset.zero & size)
        ..addRRect(window),
      Paint()..color = scrim,
    );

    // Four rounded corner marks on the window's edge.
    final paint = Paint()
      ..color = corners
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    final r = window.outerRect;
    const d = _radius * 2;
    const sweep = math.pi / 2;
    final arcs = [
      (Rect.fromLTWH(r.left, r.top, d, d), math.pi),
      (Rect.fromLTWH(r.right - d, r.top, d, d), -sweep),
      (Rect.fromLTWH(r.right - d, r.bottom - d, d, d), 0.0),
      (Rect.fromLTWH(r.left, r.bottom - d, d, d), sweep),
    ];
    for (final (box, start) in arcs) {
      canvas.drawArc(box, start, sweep, false, paint);
    }
    // Straight parts next to each arc.
    const l = _cornerLength;
    for (final (from, to) in [
      (Offset(r.left + _radius, r.top), Offset(r.left + _radius + l, r.top)),
      (Offset(r.left, r.top + _radius), Offset(r.left, r.top + _radius + l)),
      (Offset(r.right - _radius, r.top), Offset(r.right - _radius - l, r.top)),
      (Offset(r.right, r.top + _radius), Offset(r.right, r.top + _radius + l)),
      (
        Offset(r.right - _radius, r.bottom),
        Offset(r.right - _radius - l, r.bottom),
      ),
      (
        Offset(r.right, r.bottom - _radius),
        Offset(r.right, r.bottom - _radius - l),
      ),
      (
        Offset(r.left + _radius, r.bottom),
        Offset(r.left + _radius + l, r.bottom),
      ),
      (
        Offset(r.left, r.bottom - _radius),
        Offset(r.left, r.bottom - _radius - l),
      ),
    ]) {
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(_ViewfinderPainter oldDelegate) =>
      oldDelegate.scrim != scrim || oldDelegate.corners != corners;
}

/// The rounded camera area of the Scan tab and the scanner page: radius 28,
/// dark backdrop, soft shadow. [child] is the camera (or what tests show
/// instead).
class CameraArea extends StatelessWidget {
  const CameraArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.camera,
        borderRadius: BorderRadius.circular(Radii.camera),
        boxShadow: colors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.camera),
        child: child,
      ),
    );
  }
}

/// What the camera area shows when the camera cannot be used.
///
/// Public so tests can show it without a camera.
class ScannerErrorView extends StatelessWidget {
  const ScannerErrorView({super.key, required this.errorCode, this.onRetry});

  final MobileScannerErrorCode errorCode;

  /// Tries to start the camera again (offered only for unknown errors).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final view = switch (errorCode) {
      // We cannot ask again: iOS and Android show the dialog only once, so
      // we explain where the switch is (no extra permission package).
      MobileScannerErrorCode.permissionDenied => StatusView(
        icon: Icons.no_photography_rounded,
        title: l10n.scannerPermissionTitle,
        message: l10n.scannerPermissionText,
        compact: true,
      ),
      // No camera at all, for example on the iOS simulator.
      MobileScannerErrorCode.unsupported => StatusView(
        icon: Icons.no_photography_rounded,
        title: l10n.scannerUnsupported,
        compact: true,
      ),
      _ => StatusView(
        icon: Icons.error_outline_rounded,
        title: l10n.scannerError,
        actionLabel: l10n.actionRetry,
        onAction: onRetry,
        compact: true,
      ),
    };
    return ColoredBox(
      // A friendly light card inside the dark camera frame.
      color: context.appColors.surface,
      // Centred when it fits; scrollable when long texts at large font sizes
      // need more room than the camera area has.
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: view,
          ),
        ),
      ),
    );
  }
}
