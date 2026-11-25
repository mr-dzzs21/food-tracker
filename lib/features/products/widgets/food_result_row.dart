import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/card_list.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../basic_foods.dart';
import '../nutrient_format.dart';
import '../nutrients.dart';
import '../off_product_mapper.dart';
import '../simple_foods.dart';

/// One hit of the food search, kept short so many fit on a screen: the
/// name, one small line below (a typical portion or the brand) and the kcal
/// per 100 g/ml on the right – "Skyr natur · 1 Portion (150 g) · 64 kcal".
///
/// A [CardRow], so put several of them into a `CardGroup`. No photos and no
/// icons: the owner wants the list simple.
class FoodResultRow extends StatelessWidget {
  const FoodResultRow({
    super.key,
    required this.name,
    required this.kcal,
    required this.isLiquid,
    required this.onTap,
    this.subtitle,
  });

  /// A simple food ("Skyr natur") with its typical portion, in the UI
  /// language.
  factory FoodResultRow.simpleFood(
    SimpleFood food, {
    Key? key,
    required AppLocalizations l10n,
    required VoidCallback onTap,
  }) {
    final language = l10n.localeName;
    final portion = food.portionFor(language);
    final grams = food.portionGrams;
    return FoodResultRow(
      key: key,
      name: food.nameFor(language),
      subtitle: (portion == null || grams == null)
          ? null
          : l10n.foodPortionLabel(
              portion,
              formatAmount(grams, isLiquid: food.isLiquid, locale: language),
            ),
      kcal: food.nutrients.kcal,
      isLiquid: food.isLiquid,
      onTap: onTap,
    );
  }

  /// A basic food from the BLS, named in the UI language.
  FoodResultRow.basicFood(
    BasicFood food, {
    Key? key,
    required String languageCode,
    required VoidCallback onTap,
  }) : this(
         key: key,
         name: food.nameFor(languageCode),
         kcal: food.nutrients.kcal,
         isLiquid: food.isLiquid,
         onTap: onTap,
       );

  /// A food stored on the device (own foods, products seen before).
  FoodResultRow.food(Food food, {Key? key, required VoidCallback onTap})
    : this(
        key: key,
        name: food.name,
        subtitle: food.brand,
        kcal: food.kcal,
        isLiquid: food.isLiquid,
        onTap: onTap,
      );

  /// A brand product found at Open Food Facts.
  FoodResultRow.offProduct(
    OffProduct product, {
    Key? key,
    required VoidCallback onTap,
  }) : this(
         key: key,
         name: product.name ?? '',
         subtitle: product.brand,
         kcal: product.nutrients.kcal,
         isLiquid: product.isLiquid,
         onTap: onTap,
       );

  /// Empty for products without a name ("Unbekanntes Produkt" is shown).
  final String name;

  /// The typical portion or the brand, if any.
  final String? subtitle;

  /// kcal per 100 g (or 100 ml), `null` when unknown.
  final double? kcal;
  final bool isLiquid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kcal = this.kcal;
    final details = [
      ?subtitle,
      // Without kcal the product cannot be logged before it is completed –
      // say so instead of showing a number.
      if (kcal == null) l10n.foodKcalUnknown,
    ].join(' · ');
    return CardRow(
      title: name.isEmpty ? l10n.productUnknownName : name,
      subtitle: details.isEmpty ? null : details,
      trailing: kcal == null
          ? null
          : _KcalPer100(kcal: kcal, isLiquid: isLiquid),
      onTap: onTap,
    );
  }
}

/// "64 kcal" with "pro 100 g" below, right-aligned.
class _KcalPer100 extends StatelessWidget {
  const _KcalPer100({required this.kcal, required this.isLiquid});

  final double kcal;
  final bool isLiquid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatNutrientValue(Nutrient.kcal, kcal, l10n),
          style: theme.textTheme.titleSmall?.copyWith(
            fontFeatures: tabularFigures,
          ),
        ),
        Text(
          isLiquid ? l10n.productPer100ml : l10n.productPer100g,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
