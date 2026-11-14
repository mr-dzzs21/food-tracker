import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../health_rating.dart';
import '../nutrient_format.dart';
import '../nutrients.dart';

/// The "Bewertung" part of the product page (brief R1–R7):
/// four rows (fat, saturates, sugars, salt) with icon + word + value, plus
/// points, the Nutri-Score as plain text, and notes when the product is not
/// rated or its values look wrong. There is no overall score on purpose.
class RatingSection extends StatelessWidget {
  const RatingSection({super.key, required this.food});

  final Food food;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rating = rateFood(food);
    final title = switch (rating) {
      Rated(basis: RatingBasis.food) => l10n.ratingTitleFood,
      Rated(basis: RatingBasis.drink) => l10n.ratingTitleDrink,
      NotRated() => l10n.ratingTitle,
    };
    final nutriScore = food.nutriScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...switch (rating) {
                Rated() => _ratedRows(rating, l10n),
                NotRated(reason: NotRatedReason.unknownType) => [
                  _Note(icon: Icons.info_outline, text: l10n.ratingNoCategory),
                ],
                NotRated(reason: NotRatedReason.excludedType) => [
                  _Note(icon: Icons.info_outline, text: l10n.ratingNotRated),
                ],
              },
              if (nutriScore != null && 'ABCDE'.contains(nutriScore)) ...[
                const SizedBox(height: Spacing.m),
                // Plain text in a neutral chip: no logo, no colour strip
                // (owner decision, Nutri-Score trademark rules).
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Chip(label: Text(l10n.productNutriScore(nutriScore))),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _ratedRows(Rated rating, AppLocalizations l10n) {
    return [
      for (final nutrient in RatedNutrient.values)
        _LevelRow(
          nutrient: nutrient,
          level: rating.levels[nutrient],
          value: food.nutrients[nutrient.nutrient],
        ),
      for (final point in rating.plusPoints) _PlusPointRow(point: point),
      if (rating.suspicious)
        _Note(icon: Icons.report_outlined, text: l10n.ratingSuspicious),
    ];
  }
}

/// One traffic-light row: icon + nutrient + word + value. Never colour only.
class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.nutrient,
    required this.level,
    required this.value,
  });

  final RatedNutrient nutrient;

  /// `null` = no (valid) value: "keine Angabe", never "niedrig".
  final Level? level;
  final double? value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final (icon, word, color) = switch (level) {
      Level.low => (
        Icons.arrow_downward,
        l10n.ratingLevelLow,
        colors.ratingLow,
      ),
      Level.medium => (
        Icons.remove,
        l10n.ratingLevelMedium,
        colors.ratingMedium,
      ),
      Level.high => (
        Icons.arrow_upward,
        l10n.ratingLevelHigh,
        colors.ratingHigh,
      ),
      null => (
        Icons.help_outline,
        l10n.ratingNoData,
        theme.colorScheme.onSurfaceVariant,
      ),
    };
    final value = this.value;
    // Without a level the value is missing or impossible: show none.
    final valueText = (level == null || value == null)
        ? ''
        : formatNutrientValue(nutrient.nutrient, value, l10n);
    final name = nutrientName(nutrient.nutrient, l10n);

    return Semantics(
      label: l10n.ratingRowSemantics(name, word, valueText),
      // Own node, so screen readers stop here separately.
      container: true,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: Spacing.m),
            Expanded(child: Text(name, style: theme.textTheme.bodyLarge)),
            const SizedBox(width: Spacing.s),
            Flexible(
              child: Text(
                valueText.isEmpty ? word : '$word · $valueText',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusPointRow extends StatelessWidget {
  const _PlusPointRow({required this.point});

  final PlusPoint point;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch ((point.nutrient, point.strength)) {
      (PlusPointNutrient.fibre, PlusPointStrength.source) =>
        l10n.plusFibreSource,
      (PlusPointNutrient.fibre, PlusPointStrength.high) => l10n.plusFibreHigh,
      (PlusPointNutrient.protein, PlusPointStrength.source) =>
        l10n.plusProteinSource,
      (PlusPointNutrient.protein, PlusPointStrength.high) =>
        l10n.plusProteinHigh,
    };
    final value = l10n.unitGrams(
      formatNutrientNumber(
        point.nutrient == PlusPointNutrient.fibre
            ? Nutrient.fibre
            : Nutrient.protein,
        point.value,
        l10n.localeName,
      ),
    );
    return _Note(
      icon: Icons.add_circle_outline,
      text: l10n.plusPointRow(label, value),
      color: context.appColors.ratingLow,
    );
  }
}

/// An icon with a sentence, used for plus points and hints.
class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: Spacing.m),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
