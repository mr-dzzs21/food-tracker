import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../goals/reference_intake.dart';
import '../../products/nutrient_format.dart';
import '../../products/nutrients.dart';
import '../total_text.dart';

/// Protein, carbohydrates and fat of the day: name, "45/120 g" and a
/// rounded bar in the macro's colour.
///
/// The bars fill relative to the macro goal; without one (no goal, or a goal
/// without that macro) relative to the EU reference intake
/// ([ReferenceIntake]). Above the target the bar is simply full – same
/// colour, no warning. The bars grow to new values (no animation with
/// reduced motion).
class MacroBars extends StatelessWidget {
  const MacroBars({super.key, required this.totals, required this.goal});

  final NutrientTotals totals;
  final UserGoalRow? goal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final goal = this.goal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, (nutrient, goalGrams, reference, color)) in [
          (
            Nutrient.protein,
            goal?.protein,
            ReferenceIntake.protein,
            colors.protein,
          ),
          (Nutrient.carbs, goal?.carbs, ReferenceIntake.carbs, colors.carbs),
          (Nutrient.fat, goal?.fat, ReferenceIntake.fat, colors.fat),
        ].indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          _MacroBar(
            nutrient: nutrient,
            totals: totals,
            goalGrams: (goalGrams != null && goalGrams > 0) ? goalGrams : null,
            referenceGrams: reference,
            color: color,
          ),
        ],
      ],
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.nutrient,
    required this.totals,
    required this.goalGrams,
    required this.referenceGrams,
    required this.color,
  });

  final Nutrient nutrient;
  final NutrientTotals totals;

  /// The user's goal for this macro, `null` when none is set.
  final double? goalGrams;

  /// Used when there is no goal.
  final double referenceGrams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final eatenText = totalText(totals, nutrient, l10n);
    final goal = goalGrams;
    final target = goal ?? referenceGrams;
    final targetText = formatGrams(target, l10n.localeName);
    final name = nutrientName(nutrient, l10n);
    final labelStyle = theme.textTheme.labelMedium!;

    return Semantics(
      label: l10n.nutrientWithValue(
        name,
        goal != null
            ? l10n.todayMacroOfGoal(eatenText, targetText)
            : l10n.todayMacroOfReference(eatenText, targetText),
      ),
      // Own node, so screen readers stop here separately.
      container: true,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wrap instead of Row: with large text the value moves to the
          // next line instead of overflowing.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: Spacing.s,
            children: [
              Text(name, style: labelStyle),
              Text(
                l10n.todayMacroCompact(eatenText, targetText),
                style: labelStyle.copyWith(
                  color: colors.inkMuted,
                  fontWeight: FontWeight.w600,
                  fontFeatures: tabularFigures,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          TweenAnimationBuilder<double>(
            // Grows from empty when it appears, later from the old value.
            tween: Tween(begin: 0, end: totals[nutrient].value / target),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : progressAnimationDuration,
            curve: Curves.easeOutCubic,
            builder: (context, fraction, _) => SizedBox(
              height: 8,
              child: CustomPaint(
                painter: MacroBarPainter(
                  fraction: fraction,
                  color: color,
                  trackColor: colors.track,
                ),
              ),
            ),
          ),
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
