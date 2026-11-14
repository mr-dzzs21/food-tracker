import 'package:material_ui/material_ui.dart';

import '../../core/widgets/coming_soon.dart';

/// Full-screen scanner opened from the add-food flow; opens the product for [day] and [mealId].
class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key, required this.day, required this.mealId});

  /// Day key yyyy-MM-dd.
  final String day;

  /// Id of the MealSlot.
  final int mealId;

  @override
  Widget build(BuildContext context) => const ComingSoon(title: 'ScannerPage');
}
