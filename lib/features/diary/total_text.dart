import '../../l10n/app_localizations.dart';
import '../products/nutrient_format.dart';
import '../products/nutrients.dart';

/// The number of a summed nutrient, without unit (brief R16):
///
/// - every entry knew the value: `45`
/// - some entries did not: `mind. 45` / `at least 45`
/// - no entry knew it: `–`
String totalText(
  NutrientTotals totals,
  Nutrient nutrient,
  AppLocalizations l10n,
) {
  final number = formatNutrientNumber(
    nutrient,
    totals[nutrient].value,
    l10n.localeName,
  );
  return switch (totals.stateOf(nutrient)) {
    TotalState.complete => number,
    TotalState.partial => l10n.totalAtLeast(number),
    TotalState.unknown => '–',
  };
}
