import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/nutrient_format.dart';
import '../../products/nutrients.dart';
import '../total_text.dart';

/// Protein, carbohydrates and fat of the day as three translucent pills on
/// the green hero.
///
/// With a macro goal each pill shows "45/120 g" and a thin white bar.
/// Without a goal only the eaten grams are shown (no bar). Above the goal the
/// bar is simply full – same colour, no warning.
class MacroBars extends StatelessWidget {
  const MacroBars({super.key, required this.totals, required this.goal});

  final NutrientTotals totals;
  final UserGoalRow? goal;

  @override
  Widget build(BuildContext context) {
    final goal = this.goal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MacroPill(
          nutrient: Nutrient.protein,
          totals: totals,
          goalGrams: goal?.protein,
        ),
        const SizedBox(height: Spacing.s),
        _MacroPill(
          nutrient: Nutrient.carbs,
          totals: totals,
          goalGrams: goal?.carbs,
        ),
        const SizedBox(height: Spacing.s),
        _MacroPill(
          nutrient: Nutrient.fat,
          totals: totals,
          goalGrams: goal?.fat,
        ),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.nutrient,
    required this.totals,
    required this.goalGrams,
  });

  final Nutrient nutrient;
  final NutrientTotals totals;
  final double? goalGrams;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final eatenText = totalText(totals, nutrient, l10n);
    final goal = goalGrams;
    final hasGoal = goal != null && goal > 0;
    final goalText = hasGoal ? formatGrams(goal, l10n.localeName) : '';
    final name = nutrientName(nutrient, l10n);
    final style = theme.textTheme.bodySmall!.copyWith(
      color: colors.onHero,
      fontWeight: FontWeight.w800,
    );

    return Semantics(
      label: l10n.nutrientWithValue(
        name,
        hasGoal
            ? l10n.todayMacroOfGoal(eatenText, goalText)
            : l10n.unitGrams(eatenText),
      ),
      // Own node, so screen readers stop here separately.
      container: true,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.s,
        ),
        decoration: BoxDecoration(
          color: colors.heroGlass,
          borderRadius: BorderRadius.circular(Radii.input),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wrap instead of Row: with large text the value moves to the
            // next line instead of overflowing.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: Spacing.s,
              children: [
                Text(name, style: style),
                Text(
                  hasGoal
                      ? l10n.todayMacroCompact(eatenText, goalText)
                      : l10n.unitGrams(eatenText),
                  style: style.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ],
            ),
            if (hasGoal) ...[
              const SizedBox(height: 6),
              SizedBox(
                height: 4,
                child: CustomPaint(
                  painter: MacroBarPainter(
                    fraction: totals[nutrient].value / goal,
                    color: colors.onHero,
                    trackColor: colors.onHero.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A rounded horizontal bar, filled to [fraction] (capped at full).
class MacroBarPainter extends CustomPainter {
  const MacroBarPainter({
    required this.fraction,
    required this.color,
    required this.trackColor,
  });

  final double fraction;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = trackColor,
    );
    final width = size.width * fraction.clamp(0.0, 1.0);
    if (width <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, width, size.height), radius),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(MacroBarPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}
