import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/clock.dart';
import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../diary/total_text.dart';
import '../../products/nutrients.dart';
import '../week_stats.dart';

/// Seven bars (kcal per day, Monday to Sunday) with the weekday below each
/// bar and, when a goal is set, a dashed goal line.
///
/// All bars have the same calm green – also above the goal (no red, no
/// warning). Today's bar has the green gradient of the calorie ring, the
/// others are a lighter green; the bars have round tops and sit on a thin
/// track.
class WeekBars extends StatelessWidget {
  const WeekBars({
    super.key,
    required this.stats,
    required this.goalKcal,
    required this.today,
  });

  final WeekStats stats;

  /// Daily goal, `null` when none is set (then there is no goal line).
  final int? goalKcal;

  /// Today's day key, to highlight its bar when it is in this week.
  final String today;

  /// Height of the drawing. Text is outside of it, so a fixed height is fine
  /// also with large text sizes.
  static const double chartHeight = 160;

  /// Opacity of the bars of the other days (today's bar is solid).
  static const double barAlpha = 0.35;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final todayIndex = stats.days.indexOf(today);
    final goal = goalKcal;

    return Semantics(
      label: _semanticsLabel(l10n),
      // Own node, so screen readers read the whole week in one go.
      container: true,
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            height: chartHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: WeekBarsPainter(
                values: [
                  for (final day in stats.dayTotals) day[Nutrient.kcal].value,
                ],
                goal: goal?.toDouble(),
                todayIndex: todayIndex < 0 ? null : todayIndex,
                barColor: colors.brand.withValues(alpha: barAlpha),
                todayColors: [colors.ringStart, colors.ringEnd],
                trackColor: colors.track,
                goalColor: colors.inkMuted,
              ),
            ),
          ),
          const SizedBox(height: Spacing.s),
          Row(
            children: [
              for (final (index, day) in stats.days.indexed)
                Expanded(
                  // Shrinks "Mo." instead of overflowing at large text sizes.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat.E(l10n.localeName).format(parseDayKey(day)),
                      style: theme.textTheme.labelMedium!.copyWith(
                        fontWeight: index == todayIndex
                            ? FontWeight.w800
                            : null,
                        color: index == todayIndex
                            ? colors.brand
                            : colors.inkMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// "Kalorien pro Tag: Montag 1.850 kcal, Dienstag keine Einträge, …."
  String _semanticsLabel(AppLocalizations l10n) {
    final dayTexts = [
      for (final (index, day) in stats.days.indexed)
        _daySemantics(
          DateFormat.EEEE(l10n.localeName).format(parseDayKey(day)),
          stats.dayTotals[index],
          l10n,
        ),
    ];
    final label = l10n.statsChartSemantics(dayTexts.join(', '));
    final goal = goalKcal;
    if (goal == null) return label;
    final goalText = formatKcal(goal.toDouble(), l10n.localeName);
    return '$label ${l10n.statsChartSemanticsGoal(goalText)}';
  }

  static String _daySemantics(
    String weekday,
    NutrientTotals totals,
    AppLocalizations l10n,
  ) {
    if (totals.entryCount == 0) return l10n.statsDayNoEntries(weekday);
    if (totals.stateOf(Nutrient.kcal) == TotalState.unknown) {
      return l10n.statsDayKcalUnknown(weekday);
    }
    return l10n.statsDayKcal(weekday, totalText(totals, Nutrient.kcal, l10n));
  }
}

/// Draws the bars of [WeekBars]. Public so tests can check the colours.
class WeekBarsPainter extends CustomPainter {
  const WeekBarsPainter({
    required this.values,
    required this.goal,
    required this.todayIndex,
    required this.barColor,
    required this.todayColors,
    required this.trackColor,
    required this.goalColor,
  });

  /// kcal per day, Monday first (0 for a day without entries).
  final List<double> values;

  /// Daily goal in kcal, or `null` (no goal line).
  final double? goal;

  /// Which bar is today (0 = Monday), `null` when today is not in the week.
  final int? todayIndex;

  final Color barColor;

  /// Today's bar: a gradient from the first colour (bottom) to the second
  /// (top).
  final List<Color> todayColors;

  /// The thin line at the bottom of each day, so empty days stay visible.
  final Color trackColor;
  final Color goalColor;

  /// Free space above the highest bar or the goal line, as a fraction.
  static const double _headroom = 0.1;
  static const double _trackHeight = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / values.length;
    final barWidth = math.min(slot * 0.6, 32.0);
    final top = [goal ?? 0, ...values].reduce(math.max) * (1 + _headroom);

    for (final (index, value) in values.indexed) {
      final left = index * slot + (slot - barWidth) / 2;
      final radius = Radius.circular(math.min(barWidth / 3, 8));
      // Track first: a day without entries shows only this line.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left,
            size.height - _trackHeight,
            barWidth,
            _trackHeight,
          ),
          const Radius.circular(_trackHeight / 2),
        ),
        Paint()..color = trackColor,
      );
      if (top <= 0 || value <= 0) continue;
      // At least the track's height, so tiny values are still visible.
      final height = math.max(size.height * value / top, _trackHeight);
      // Round tops only; the bottom stands on the track.
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, size.height - height, barWidth, height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: const Radius.circular(_trackHeight / 2),
          bottomRight: const Radius.circular(_trackHeight / 2),
        ),
        _barPaint(
          index == todayIndex,
          Rect.fromLTWH(left, size.height - height, barWidth, height),
        ),
      );
    }

    final goalKcal = goal;
    if (goalKcal != null && goalKcal > 0 && top > 0) {
      _drawDashedLine(canvas, size.width, size.height * (1 - goalKcal / top));
    }
  }

  Paint _barPaint(bool isToday, Rect bar) {
    if (!isToday) return Paint()..color = barColor;
    return Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: todayColors,
      ).createShader(bar);
  }

  void _drawDashedLine(Canvas canvas, double width, double y) {
    const dash = 6.0;
    const gap = 4.0;
    final paint = Paint()
      ..color = goalColor
      ..strokeWidth = 1.5;
    for (var x = 0.0; x < width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dash, width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WeekBarsPainter oldDelegate) =>
      !listEquals(oldDelegate.values, values) ||
      oldDelegate.goal != goal ||
      oldDelegate.todayIndex != todayIndex ||
      oldDelegate.barColor != barColor ||
      !listEquals(oldDelegate.todayColors, todayColors) ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.goalColor != goalColor;
}
