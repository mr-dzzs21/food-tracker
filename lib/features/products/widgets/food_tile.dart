import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/card_list.dart';
import '../../../core/widgets/icon_square.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';

/// One stored food in a list (recents, favourites, own foods): name, brand
/// and kcal per 100 g/ml – a [CardRow], so put several of them into a
/// `CardGroup`. Search hits use the shorter `FoodResultRow`.
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

  /// Empty for products without a name ("Unbekanntes Produkt" is shown).
  final String name;
  final String? brand;

  /// kcal per 100 g (or 100 ml), `null` when unknown.
  final double? kcal;
  final bool isLiquid;

  final bool isFavourite;
  final VoidCallback onTap;

  /// Replaces the chevron (or star), e.g. with a "more" menu button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brand = this.brand;
    final details = kcalPer100Text(kcal, isLiquid: isLiquid, l10n: l10n);
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
                  color: colors.star,
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
