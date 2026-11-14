import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/nutrient_format.dart';
import '../../products/nutrients.dart';
import '../total_text.dart';

/// Protein, carbohydrates and fat of the day.
///
/// With a macro goal each row shows "45 von 120 g" and a bar in the macro's
/// colour. Without a goal only the eaten grams are shown (no bar). Above the
/// goal the bar is simply full – same colour, no warning.
class MacroBars extends StatelessWidget {
  const MacroBars({super.key, required this.totals, required this.goal});

  final NutrientTotals totals;
  final UserGoalRow? goal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final goal = this.goal;
    return Column(
      children: [
        _MacroRow(
          nutrient: Nutrient.protein,
          totals: totals,
          goalGrams: goal?.protein,
          color: colors.protein,
        ),
        const SizedBox(height: Spacing.m),
        _MacroRow(
          nutrient: Nutrient.carbs,
          totals: totals,
          goalGrams: goal?.carbs,
          color: colors.carbs,
        ),
        const SizedBox(height: Spacing.m),
        _MacroRow(
          nutrient: Nutrient.fat,
          totals: totals,
          goalGrams: goal?.fat,
          color: colors.fat,
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.nutrient,
    required this.totals,
    required this.goalGrams,
    required this.color,
  });

  final Nutrient nutrient;
  final NutrientTotals totals;
  final double? goalGrams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final eatenText = totalText(totals, nutrient, l10n);
    final goal = goalGrams;
    final hasGoal = goal != null && goal > 0;
    final value = hasGoal
        ? l10n.todayMacroOfGoal(eatenText, formatGrams(goal, l10n.localeName))
        : l10n.unitGrams(eatenText);
    final name = nutrientName(nutrient, l10n);

    return Semantics(
      label: l10n.nutrientWithValue(name, value),
      // Own node, so screen readers stop here separately.
      container: true,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wrap instead of Row: with large text the value moves to the next
          // line instead of overflowing.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: Spacing.s,
            children: [
              Text(name, style: theme.textTheme.bodyMedium),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (hasGoal) ...[
            const SizedBox(height: Spacing.xs),
            SizedBox(
              height: 8,
              child: CustomPaint(
                painter: MacroBarPainter(
                  fraction: totals[nutrient].value / goal,
                  color: color,
                  trackColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ],
        ],
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
