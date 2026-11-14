import 'package:material_ui/material_ui.dart';

import '../../core/widgets/coming_soon.dart';

/// Form to create or edit an own food (name + nutrients per 100 g/ml).
///
/// - [foodId] set: edit that food.
/// - [barcode] set: create a food for a product Open Food Facts does not know.
/// - [day]/[mealId] set: after saving, continue to add the new food there.
class FoodFormPage extends StatelessWidget {
  const FoodFormPage({
    super.key,
    this.foodId,
    this.barcode,
    this.day,
    this.mealId,
  });

  final int? foodId;
  final String? barcode;
  final String? day;
  final int? mealId;

  @override
  Widget build(BuildContext context) => const ComingSoon(title: 'FoodFormPage');
}
