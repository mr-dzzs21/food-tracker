import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/icon_square.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/nutrients.dart';
import '../diary_repository.dart';
import '../meal_style.dart';
import '../total_text.dart';

/// A white card of one meal on the Today tab: tinted icon square, name, the
/// names of its entries ("Haferflocken, Milch" or "Noch nichts"), kcal and a
/// round green "+" button.
///
/// Tapping the card opens the meal's entries ([onOpen], the meal sheet);
/// "+" goes straight to adding food ([onAdd]).
class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.slot,
    required this.entryNames,
    required this.totals,
    required this.onOpen,
    required this.onAdd,
  });

  final MealSlot slot;

  /// The names of the meal's entries on this day, in diary order.
  final List<String> entryNames;
  final NutrientTotals totals;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final palette = mealPaletteOf(slot, colors);
    final name = mealSlotName(slot, l10n);
    final kcal = totalText(totals, Nutrient.kcal, l10n);
    final entries = l10n.todayMealEntries(entryNames.length);

    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, Spacing.xs, 10),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              button: true,
              label: l10n.todayMealTileSemantics(name, entries, kcal),
              hint: l10n.todayMealTileHint,
              onTap: onOpen,
              // The texts are read from the label above.
              excludeSemantics: true,
              // At least 48 px high, like every tap target (the content
              // alone is 44 px).
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Row(
                  children: [
                    IconSquare(
                      icon: mealIconOf(slot),
                      background: palette.background,
                      foreground: palette.icon,
                      size: 44,
                      iconSize: 24,
                      radius: Radii.input,
                    ),
                    const SizedBox(width: Spacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: theme.textTheme.titleSmall),
                          Text(
                            entryNames.isEmpty
                                ? entries
                                : entryNames.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium!.copyWith(
                              color: colors.inkMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Spacing.s),
                    Text(
                      l10n.unitKcal(kcal),
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w800,
                        fontFeatures: tabularFigures,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          RoundIconButton(
            icon: Icons.add_rounded,
            tooltip: l10n.mealAddTooltip(mealSlotTextKey(slot), name),
            onPressed: onAdd,
            size: 34,
            iconSize: 20,
            background: colors.cta,
            foreground: colors.onCta,
          ),
        ],
      ),
    );
  }
}
