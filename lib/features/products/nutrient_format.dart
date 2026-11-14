import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import 'nutrients.dart';

// How nutrients are named and written on screen. Shared by the product page
// and the diary, so both show the same words and the same rounding.

/// The translated name of a [nutrient] ("Eiweiß", "Protein", …).
String nutrientName(Nutrient nutrient, AppLocalizations l10n) =>
    switch (nutrient) {
      Nutrient.kcal => l10n.nutrientKcal,
      Nutrient.fat => l10n.nutrientFat,
      Nutrient.saturatedFat => l10n.nutrientSaturatedFat,
      Nutrient.carbs => l10n.nutrientCarbs,
      Nutrient.sugars => l10n.nutrientSugars,
      Nutrient.fibre => l10n.nutrientFibre,
      Nutrient.protein => l10n.nutrientProtein,
      Nutrient.salt => l10n.nutrientSalt,
    };

/// A value without unit, rounded the way nutrition labels do it: kcal whole,
/// salt with two decimals below 1 g, other grams per `formatGrams`.
String formatNutrientNumber(Nutrient nutrient, double value, String locale) =>
    switch (nutrient) {
      Nutrient.kcal => formatKcal(value, locale),
      Nutrient.salt => formatSalt(value, locale),
      _ => formatGrams(value, locale),
    };

/// A value with unit: "533 kcal", "4,5 g", "0,11 g".
String formatNutrientValue(
  Nutrient nutrient,
  double value,
  AppLocalizations l10n,
) {
  final number = formatNutrientNumber(nutrient, value, l10n.localeName);
  return nutrient == Nutrient.kcal
      ? l10n.unitKcal(number)
      : l10n.unitGrams(number);
}
