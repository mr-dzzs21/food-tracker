import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../goals/reference_intake.dart';
import '../../products/nutrients.dart';
import '../total_text.dart';

/// The big green ring in the summary card of the "Heute" tab.
///
/// - With a goal: how many kcal are left ("1.240 kcal übrig, von 2.490").
/// - Without a goal: how many kcal were eaten; the ring fills relative to the
///   EU reference intake ([ReferenceIntake.kcal], "von 2.000 kcal
///   (Richtwert)").
/// - Above the goal or the reference: the ring is full **in the same green**
///   and the text stays neutral ("320 kcal über deinem Ziel") – no red, no
///   "failed".
///
/// When some entries have no kcal value, the numbers are only a bound:
/// eaten "mind. …", left "höchstens …".
///
/// The ring and the number move from the old to the new value (from 0 when
/// the ring appears), unless the system asks for reduced motion.
class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.totals,
    required this.goalKcal,
    this.size = 132,
  });

  final NutrientTotals totals;

  /// Daily goal, `null` when none is set.
  final int? goalKcal;

  /// Width and height of the ring.
  final double size;

  static const double strokeWidth = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = l10n.localeName;
    final eaten = totals[Nutrient.kcal].value;
    final eatenText = totalText(totals, Nutrient.kcal, l10n);
    final goal = goalKcal;
    final complete = totals.stateOf(Nutrient.kcal) == TotalState.complete;

    // The screen reader gets the final numbers at once (no counting).
    final String semantics;
    if (goal == null) {
      semantics = l10n.todayRingSemanticsEaten(
        eatenText,
        formatKcal(ReferenceIntake.kcal.toDouble(), locale),
      );
    } else if (eaten <= goal) {
      final left = formatKcal(goal - eaten, locale);
      semantics = l10n.todayRingSemanticsLeft(
        complete ? left : l10n.totalAtMost(left),
        formatKcal(goal.toDouble(), locale),
        eatenText,
      );
    } else {
      final over = formatKcal(eaten - goal, locale);
      semantics = l10n.todayRingSemanticsOver(
        complete ? over : l10n.totalAtLeast(over),
        formatKcal(goal.toDouble(), locale),
        eatenText,
      );
    }

    return Semantics(
      label: semantics,
      // Own node, so screen readers stop here separately.
      container: true,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        // Starts at 0 when the ring appears, later at the value shown.
        tween: Tween(begin: 0, end: eaten),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : progressAnimationDuration,
        curve: Curves.easeOutCubic,
        builder: (context, shown, _) =>
            _RingFace(totals: totals, eaten: shown, goalKcal: goal, size: size),
      ),
    );
  }
}

/// The ring and its centre text for an [eaten] value (animated).
class _RingFace extends StatelessWidget {
  const _RingFace({
    required this.totals,
    required this.eaten,
    required this.goalKcal,
    required this.size,
  });

  final NutrientTotals totals;
  final double eaten;
  final int? goalKcal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final locale = l10n.localeName;
    final state = totals.stateOf(Nutrient.kcal);
    final complete = state == TotalState.complete;
    final goal = goalKcal;

    final String number;
    final String label;
    final String? detail;
    final double target;
    if (goal == null) {
      number = boundedNumberText(Nutrient.kcal, eaten, state, l10n);
      label = l10n.todayRingEaten;
      detail = l10n.todayRingOfReference(
        formatKcal(ReferenceIntake.kcal.toDouble(), locale),
      );
      target = ReferenceIntake.kcal.toDouble();
    } else if (eaten <= goal) {
      final left = formatKcal(goal - eaten, locale);
      // Unknown values can only make the real "left" smaller.
      number = complete ? left : l10n.totalAtMost(left);
      label = l10n.todayRingLeft;
      detail = l10n.todayRingOfGoal(formatKcal(goal.toDouble(), locale));
      target = goal.toDouble();
    } else {
      final over = formatKcal(eaten - goal, locale);
      number = complete ? over : l10n.totalAtLeast(over);
      label = l10n.todayRingOver;
      detail = null;
      target = goal.toDouble();
    }
    final smallStyle = theme.textTheme.labelSmall!.copyWith(
      color: colors.inkMuted,
      fontWeight: FontWeight.w600,
    );
    // The free space inside the ring.
    final inner = size - 2 * (CalorieRing.strokeWidth + Spacing.xs);

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: CalorieRingPainter(
          progress: target <= 0 ? 1 : eaten / target,
          startColor: colors.ringStart,
          endColor: colors.ringEnd,
          trackColor: colors.track,
          strokeWidth: CalorieRing.strokeWidth,
        ),
        child: Center(
          // Large text sizes must not overflow the ring: shrink instead.
          // Screen readers get the full sentence from the ring's semantics.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: inner,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    number,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(label, textAlign: TextAlign.center, style: smallStyle),
                  if (detail != null)
                    Text(
                      detail,
                      textAlign: TextAlign.center,
                      style: smallStyle,
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
/// Public so tests can check the colours (never red above the goal).
class CalorieRingPainter extends CustomPainter {
  const CalorieRingPainter({
    required this.progress,
    required this.startColor,
    required this.endColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  /// 0.0 = empty, 1.0 (or more) = full circle.
  final double progress;

  /// The green gradient of the filled part (top left → bottom right).
  final Color startColor;
  final Color endColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint..color = trackColor);

    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    if (sweep <= 0) return;
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [startColor, endColor],
    ).createShader(rect);
    // Start at the top (12 o'clock) and go clockwise.
    canvas.drawArc(rect, -pi / 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(CalorieRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.startColor != startColor ||
      oldDelegate.endColor != endColor ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
