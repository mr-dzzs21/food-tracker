import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/card_list.dart';
import '../../../core/widgets/icon_square.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../off_product_mapper.dart';

/// One food in a list (recents, favourites, own foods, search results):
/// name, brand and kcal per 100 g/ml – a [CardRow], so put several of them
/// into a `CardGroup`.
///
/// No product photos in lists: fewer downloads, and the list stays calm. A
/// small icon square says "food" or "drink" instead.
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
    this.trailing,
  });

  /// A food stored on the device.
  FoodTile.food(
    Food food, {
    Key? key,
    required VoidCallback onTap,
    Widget? trailing,
  }) : this(
         key: key,
         name: food.name,
         brand: food.brand,
         kcal: food.kcal,
         isLiquid: food.isLiquid,
         isFavourite: food.isFavourite,
         onTap: onTap,
         trailing: trailing,
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

  /// Replaces the chevron (or star), e.g. with a "more" menu button.
  final Widget? trailing;

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
    final colors = context.appColors;
    return CardRow(
      leading: IconSquare(
        icon: isLiquid ? Icons.local_drink_rounded : Icons.restaurant_rounded,
        background: colors.tonal,
        foreground: colors.onTonal,
      ),
      title: name.isEmpty ? l10n.productUnknownName : name,
      subtitle: brand == null ? details : '$brand\n$details',
      trailing:
          trailing ??
          (isFavourite
              ? Icon(
                  Icons.star_rounded,
                  semanticLabel: l10n.addFoodSegmentFavourites,
                  color: colors.brand,
                )
              : null),
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
