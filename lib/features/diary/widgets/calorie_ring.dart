import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/nutrients.dart';
import '../total_text.dart';

/// The big ring on the "Heute" tab.
///
/// - With a goal: how many kcal are left ("1.240 kcal übrig, von 2.490").
/// - Without a goal: how many kcal were eaten.
/// - Above the goal: the ring is full **in the same colour** and the text
///   stays neutral ("320 kcal über deinem Ziel") – no red, no "failed".
///
/// When some entries have no kcal value, the numbers are only a bound:
/// eaten "mind. …", left "höchstens …".
class CalorieRing extends StatelessWidget {
  const CalorieRing({super.key, required this.totals, required this.goalKcal});

  final NutrientTotals totals;

  /// Daily goal, `null` when none is set.
  final int? goalKcal;

  static const double size = 200;
  static const double strokeWidth = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final eaten = totals[Nutrient.kcal].value;
    final complete = totals.stateOf(Nutrient.kcal) == TotalState.complete;
    final eatenText = totalText(totals, Nutrient.kcal, l10n);
    final goal = goalKcal;

    final String number;
    final String label;
    final String? detail;
    final String semantics;
    final double progress;
    if (goal == null) {
      number = eatenText;
      label = l10n.todayRingEaten;
      detail = null;
      semantics = l10n.todayRingSemanticsEaten(eatenText);
      progress = 0;
    } else if (eaten <= goal) {
      final left = formatKcal(goal - eaten, locale);
      // Unknown values can only make the real "left" smaller.
      number = complete ? left : l10n.totalAtMost(left);
      label = l10n.todayRingLeft;
      detail = l10n.todayRingOfGoal(formatKcal(goal.toDouble(), locale));
      semantics = l10n.todayRingSemanticsLeft(
        number,
        formatKcal(goal.toDouble(), locale),
        eatenText,
      );
      progress = goal == 0 ? 1 : eaten / goal;
    } else {
      final over = formatKcal(eaten - goal, locale);
      number = complete ? over : l10n.totalAtLeast(over);
      label = l10n.todayRingOver;
      detail = null;
      semantics = l10n.todayRingSemanticsOver(
        number,
        formatKcal(goal.toDouble(), locale),
        eatenText,
      );
      progress = 1;
    }

    return Semantics(
      label: semantics,
      // Own node, so screen readers stop here separately.
      container: true,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: CalorieRingPainter(
            progress: progress,
            color: theme.colorScheme.primary,
            trackColor: theme.colorScheme.surfaceContainerHighest,
            strokeWidth: strokeWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.all(strokeWidth + Spacing.l),
            // Large text sizes must not overflow the ring: shrink instead.
            // Screen readers get the full sentence from [Semantics] above.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    number,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(label, style: theme.textTheme.bodyMedium),
                  if (detail != null)
                    Text(
                      detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the track and the filled part of [CalorieRing].
///
/// Public so tests can check the colour (never red above the goal).
class CalorieRingPainter extends CustomPainter {
  const CalorieRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  /// 0.0 = empty, 1.0 (or more) = full circle.
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint..color = trackColor);

    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    if (sweep <= 0) return;
    // Start at the top (12 o'clock) and go clockwise.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(CalorieRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
