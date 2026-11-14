import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../products/nutrient_format.dart';
import '../../products/nutrients.dart';
import '../diary_repository.dart';
import '../total_text.dart';

/// One meal of the day: name, kcal sum, a "+" button and its entries.
///
/// Swiping an entry to the left deletes it; tapping it opens the entry sheet.
/// What happens is decided by the page ([onAdd], [onTapEntry], [onDelete]).
class MealSection extends StatelessWidget {
  const MealSection({
    super.key,
    required this.slot,
    required this.entries,
    required this.totals,
    required this.onAdd,
    required this.onTapEntry,
    required this.onDelete,
  });

  final MealSlot slot;
  final List<DiaryEntry> entries;
  final NutrientTotals totals;
  final VoidCallback onAdd;
  final ValueChanged<DiaryEntry> onTapEntry;
  final ValueChanged<DiaryEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = mealSlotName(slot, l10n);
    return Card(
      // Clips the swipe background to the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.l,
              Spacing.xs,
              Spacing.xs,
              Spacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(name, style: theme.textTheme.titleMedium),
                  ),
                ),
                if (entries.isNotEmpty)
                  Text(
                    l10n.unitKcal(totalText(totals, Nutrient.kcal, l10n)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: l10n.mealAddTooltip(name),
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
          for (final entry in entries)
            Dismissible(
              key: ValueKey(entry.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onDelete(entry),
              background: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              child: _EntryTile(entry: entry, onTap: () => onTapEntry(entry)),
            ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.onTap});

  final DiaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kcal = entry.nutrients.kcal;
    final amount = formatAmount(
      entry.amount,
      isLiquid: entry.isLiquid,
      locale: l10n.localeName,
    );
    final brand = entry.brand;
    return ListTile(
      onTap: onTap,
      title: Text(entry.name.isEmpty ? l10n.productUnknownName : entry.name),
      subtitle: Text(brand == null ? amount : '$amount · $brand'),
      trailing: Text(
        kcal == null ? '–' : formatNutrientValue(Nutrient.kcal, kcal, l10n),
      ),
    );
  }
}
