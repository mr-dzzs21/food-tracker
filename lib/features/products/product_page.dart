import 'package:material_ui/material_ui.dart';

import '../../core/widgets/coming_soon.dart';

/// Product details: health rating, nutrients, portion picker and
/// "Hinzufügen" to the diary.
///
/// Opened either with a [barcode] (looked up in the cache, then at
/// Open Food Facts) or with the [foodId] of a food already stored on the
/// device. [day] and [mealId] say where "Hinzufügen" puts the food; when they
/// are null, today and the meal that fits the time of day are used.
class ProductPage extends StatelessWidget {
  const ProductPage.barcode({
    super.key,
    required String this.barcode,
    this.day,
    this.mealId,
  }) : foodId = null;

  const ProductPage.food({
    super.key,
    required int this.foodId,
    this.day,
    this.mealId,
  }) : barcode = null;

  final String? barcode;
  final int? foodId;
  final String? day;
  final int? mealId;

  @override
  Widget build(BuildContext context) => const ComingSoon(title: 'ProductPage');
}
