import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../diary/add_food_page.dart';
import 'widgets/barcode_scanner_view.dart';

/// Full-screen scanner opened from the add-food flow; opens the product for [day] and [mealId].
///
/// The product page *replaces* this page, so "back" on the product page
/// returns to the add-food page instead of the camera.
class ScannerPage extends ConsumerWidget {
  const ScannerPage({super.key, required this.day, required this.mealId});

  /// Day key yyyy-MM-dd.
  final String day;

  /// Id of the MealSlot.
  final int mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(scannerViewProvider);
    return Scaffold(
      appBar: AppTopBar(title: AppLocalizations.of(context).scannerTitle),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          Spacing.l,
          Spacing.xs,
          Spacing.l,
          Spacing.l,
        ),
        // The same rounded camera frame as on the Scan tab, as big as the
        // page allows.
        child: CameraArea(
          child: scanner(
            (code) => replaceInAddFlow(
              context,
              Routes.product(code, day: day, mealId: mealId),
            ),
          ),
        ),
      ),
    );
  }
}
