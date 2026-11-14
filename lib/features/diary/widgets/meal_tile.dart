import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/icon_square.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/nutrients.dart';
import '../diary_repository.dart';
import '../meal_style.dart';
import '../total_text.dart';

/// A colourful tile of one meal on the Today tab: icon, name, number of
/// entries, kcal and a "+" button.
///
/// Tapping the tile opens the meal's entries ([onOpen], the meal sheet);
/// "+" goes straight to adding food ([onAdd]).
class MealTile extends StatelessWidget {
  const MealTile({
    super.key,
    required this.slot,
    required this.entryCount,
    required this.totals,
    required this.onOpen,
    required this.onAdd,
  });

  final MealSlot slot;
  final int entryCount;
  final NutrientTotals totals;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  /// Height of a tile with normal text size (bigger text makes it taller).
  static const double minHeight = 128;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final palette = mealPaletteOf(slot, colors);
    final name = mealSlotName(slot, l10n);
    final kcal = totalText(totals, Nutrient.kcal, l10n);
    final entries = l10n.todayMealEntries(entryCount);

    return Semantics(
      container: true,
      button: true,
      label: l10n.todayMealTileSemantics(name, entries, kcal),
      hint: l10n.todayMealTileHint,
      child: Material(
        color: palette.background,
        borderRadius: BorderRadius.circular(Radii.tile),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, Spacing.s, Spacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The texts are read from the tile's label above.
                  ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconSquare(
                          icon: mealIconOf(slot),
                          background: colors.surface.withValues(alpha: 0.55),
                          foreground: palette.icon,
                          size: 40,
                          iconSize: 24,
                        ),
                        const SizedBox(height: 10),
                        Text(name, style: theme.textTheme.titleSmall),
                        Text(entries, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: Spacing.s),
                  Row(
                    children: [
                      Expanded(
                        child: ExcludeSemantics(
                          child: Text(
                            l10n.unitKcal(kcal),
                            style: theme.textTheme.titleSmall!.copyWith(
                              fontFeatures: tabularFigures,
                            ),
                          ),
                        ),
                      ),
                      SquareIconButton(
                        icon: Icons.add_rounded,
                        tooltip: l10n.mealAddTooltip(name),
                        onPressed: onAdd,
                        size: 34,
                        iconSize: 20,
                        background: colors.cta,
                        foreground: colors.onCta,
                      ),
                    ],
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
