import 'package:material_ui/material_ui.dart';

import '../../core/widgets/coming_soon.dart';

/// Adds food to one meal of one day: search, recents, favourites, own foods.
class AddFoodPage extends StatelessWidget {
  const AddFoodPage({super.key, required this.day, required this.mealId});

  /// Day key yyyy-MM-dd.
  final String day;

  /// Id of the MealSlot.
  final int mealId;

  @override
  Widget build(BuildContext context) => const ComingSoon(title: 'AddFoodPage');
}
