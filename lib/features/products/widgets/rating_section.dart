import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_square.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../health_rating.dart';
import '../nutrient_format.dart';
import '../nutrients.dart';

/// The "Bewertung" part of the product page (brief R1–R7):
/// four cards (fat, saturates, sugars, salt) with icon + nutrient + value +
/// word, plus points, and notes when the product is not rated or its values
/// look wrong. There is no overall score on purpose. (The Nutri-Score is
/// shown as plain text in the page header.)
class RatingSection extends StatelessWidget {
  const RatingSection({super.key, required this.food});

  final Food food;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final rating = rateFood(food);
    final title = switch (rating) {
      Rated(basis: RatingBasis.food) => l10n.ratingTitleFood,
      Rated(basis: RatingBasis.drink) => l10n.ratingTitleDrink,
      NotRated() => l10n.ratingTitle,
    };
    final rows = switch (rating) {
      Rated() => _ratedRows(rating, l10n, colors),
      NotRated(reason: NotRatedReason.unknownType) => [
        _Note(icon: Icons.info_outline_rounded, text: l10n.ratingNoCategory),
      ],
      NotRated(reason: NotRatedReason.excludedType) => [
        _Note(icon: Icons.info_outline_rounded, text: l10n.ratingNotRated),
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0) const SizedBox(height: Spacing.s),
                row,
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _ratedRows(
    Rated rating,
    AppLocalizations l10n,
    AppColors colors,
  ) {
    return [
      for (final nutrient in RatedNutrient.values)
        _LevelRow(
          nutrient: nutrient,
          level: rating.levels[nutrient],
          value: food.nutrients[nutrient.nutrient],
        ),
      for (final point in rating.plusPoints) _PlusPointRow(point: point),
      if (rating.suspicious)
        _Note(
          icon: Icons.report_problem_rounded,
          text: l10n.ratingSuspicious,
          background: colors.ratingMediumBg,
          iconColor: colors.ratingMedium,
        ),
    ];
  }
}

/// One traffic-light card: icon square + nutrient + value + word pill.
/// Never colour only: the icon and the word say the same.
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
    final (icon, word, background, foreground) = switch (level) {
      Level.low => (
        Icons.arrow_downward_rounded,
        l10n.ratingLevelLow,
        colors.ratingLowBg,
        colors.ratingLow,
      ),
      Level.medium => (
        Icons.remove_rounded,
        l10n.ratingLevelMedium,
        colors.ratingMediumBg,
        colors.ratingMedium,
      ),
      Level.high => (
        Icons.arrow_upward_rounded,
        l10n.ratingLevelHigh,
        colors.ratingHighBg,
        colors.ratingHigh,
      ),
      null => (
        Icons.help_outline_rounded,
        l10n.ratingNoData,
        colors.surfaceAlt,
        colors.inkMuted,
      ),
    };
    final value = this.value;
    // Without a level the value is missing or impossible: show none.
    final valueText = (level == null || value == null)
        ? ''
        : formatNutrientValue(nutrient.nutrient, value, l10n);
    final name = nutrientName(nutrient.nutrient, l10n);
    final textStyle = theme.textTheme.bodyMedium!.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w800,
    );

    return Semantics(
      label: l10n.ratingRowSemantics(name, word, valueText),
      // Own node, so screen readers stop here separately.
      container: true,
      excludeSemantics: true,
      child: AppCard(
        radius: Radii.button,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: 10,
        ),
        child: Row(
          children: [
            IconSquare(
              icon: icon,
              background: background,
              foreground: foreground,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(name, style: textStyle)),
            const SizedBox(width: Spacing.s),
            // Value and word move below each other when the text is large.
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Spacing.s,
                runSpacing: Spacing.xs,
                children: [
                  if (valueText.isNotEmpty)
                    Text(
                      valueText,
                      style: textStyle.copyWith(fontFeatures: tabularFigures),
                    ),
                  _WordPill(
                    word: word,
                    background: background,
                    foreground: foreground,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "hoch" / "mittel" / "niedrig" in a small pill of the level's colours.
class _WordPill extends StatelessWidget {
  const _WordPill({
    required this.word,
    required this.background,
    required this.foreground,
  });

  final String word;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Text(
        word,
        style: Theme.of(context).textTheme.labelMedium!
            .copyWith(color: foreground),
      ),
    );
  }
}

/// "Ballaststoffquelle · 4,5 g" in the brand colour with a leaf.
class _PlusPointRow extends StatelessWidget {
  const _PlusPointRow({required this.point});

  final PlusPoint point;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          Icon(Icons.eco_rounded, color: colors.brand, size: 20),
          const SizedBox(width: Spacing.s),
          Expanded(
            child: Text(
              l10n.plusPointRow(label, value),
              style: Theme.of(context).textTheme.bodyMedium!
                  .copyWith(color: colors.brand, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tinted card with an icon and a sentence (not rated, odd values).
class _Note extends StatelessWidget {
  const _Note({
    required this.icon,
    required this.text,
    this.background,
    this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color? background;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppCard(
      radius: Radii.button,
      color: background ?? colors.surfaceAlt,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? colors.inkMuted),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
