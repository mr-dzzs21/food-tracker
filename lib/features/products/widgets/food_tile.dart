import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../off_product_mapper.dart';

/// One food in a list (recents, favourites, own foods, search results):
/// name, brand and kcal per 100 g/ml.
///
/// No product photos in lists: fewer downloads, and the list stays calm.
class FoodTile extends StatelessWidget {
  const FoodTile({
    super.key,
    required this.name,
    required this.brand,
    required this.kcal,
    required this.isLiquid,
    required this.onTap,
    this.nutriScore,
    this.isFavourite = false,
  });

  /// A food stored on the device.
  FoodTile.food(Food food, {Key? key, required VoidCallback onTap})
    : this(
        key: key,
        name: food.name,
        brand: food.brand,
        kcal: food.kcal,
        isLiquid: food.isLiquid,
        isFavourite: food.isFavourite,
        onTap: onTap,
      );

  /// A hit of the Open Food Facts search.
  FoodTile.offProduct(
    OffProduct product, {
    Key? key,
    required VoidCallback onTap,
  }) : this(
         key: key,
         name: product.name ?? '',
         brand: product.brand,
         kcal: product.nutrients.kcal,
         isLiquid: product.isLiquid,
         nutriScore: product.nutriScore,
         onTap: onTap,
       );

  /// Empty for products without a name ("Unbekanntes Produkt" is shown).
  final String name;
  final String? brand;

  /// kcal per 100 g (or 100 ml), `null` when unknown.
  final double? kcal;
  final bool isLiquid;

  /// "A" … "E" (only Open Food Facts products have one).
  final String? nutriScore;
  final bool isFavourite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brand = this.brand;
    final nutriScore = this.nutriScore;
    final details = [
      kcalPer100Text(kcal, isLiquid: isLiquid, l10n: l10n),
      // Plain text only – no logo, no colours (owner decision).
      if (nutriScore != null) l10n.searchNutriScore(nutriScore),
    ].join(' · ');
    return ListTile(
      title: Text(name.isEmpty ? l10n.productUnknownName : name),
      subtitle: Text(brand == null ? details : '$brand\n$details'),
      trailing: isFavourite
          ? Icon(
              Icons.star,
              semanticLabel: l10n.addFoodSegmentFavourites,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// "533 kcal pro 100 g", "42 kcal pro 100 ml" or "Kalorien unbekannt".
String kcalPer100Text(
  double? kcal, {
  required bool isLiquid,
  required AppLocalizations l10n,
}) {
  if (kcal == null) return l10n.foodKcalUnknown;
  final number = formatKcal(kcal, l10n.localeName);
  return isLiquid
      ? l10n.foodKcalPer100ml(number)
      : l10n.foodKcalPer100g(number);
}
