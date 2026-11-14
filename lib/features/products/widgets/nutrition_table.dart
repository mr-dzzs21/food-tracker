import 'package:material_ui/material_ui.dart';

import '../../../core/format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../nutrient_format.dart';
import '../nutrients.dart';

/// The nutrition table of the product page, in a white card: values per
/// 100 g/ml and, when the portion size is known, per portion. Unknown values
/// show "–".
class NutritionTable extends StatelessWidget {
  const NutritionTable({super.key, required this.food});

  final Food food;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final per100 = food.nutrients;
    final servingSize = food.servingSize;
    final hasServing = servingSize != null && servingSize > 0;
    final perServing = hasServing ? per100.scaled(servingSize) : null;
    final headerStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final valueStyle = theme.textTheme.bodyMedium!.copyWith(
      fontFeatures: tabularFigures,
    );

    Widget cell(String text, {TextStyle? style, bool end = true}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s),
      child: Text(
        text,
        style: style,
        textAlign: end ? TextAlign.end : TextAlign.start,
      ),
    );

    Widget valueCell(Nutrient nutrient, double? value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s),
      child: Text(
        value == null ? '–' : formatNutrientValue(nutrient, value, l10n),
        // Screen readers would read "–" as "dash".
        semanticsLabel: value == null ? l10n.ratingNoData : null,
        textAlign: TextAlign.end,
        style: valueStyle,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.productNutritionTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.l,
              vertical: Spacing.s,
            ),
            child: Table(
              columnWidths: {
                0: const FlexColumnWidth(2),
                1: const FlexColumnWidth(),
                if (hasServing) 2: const FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    const SizedBox.shrink(),
                    cell(
                      food.isLiquid
                          ? l10n.productPer100ml
                          : l10n.productPer100g,
                      style: headerStyle,
                    ),
                    if (hasServing)
                      cell(
                        l10n.productPerServing(
                          formatAmount(
                            servingSize,
                            isLiquid: food.isLiquid,
                            locale: l10n.localeName,
                          ),
                        ),
                        style: headerStyle,
                      ),
                  ],
                ),
                for (final nutrient in Nutrient.values)
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        // "davon" rows (saturates, sugars) are indented.
                        padding: EdgeInsetsDirectional.only(
                          start:
                              (nutrient == Nutrient.saturatedFat ||
                                  nutrient == Nutrient.sugars)
                              ? Spacing.l
                              : 0,
                        ),
                        child: cell(nutrientName(nutrient, l10n), end: false),
                      ),
                      valueCell(nutrient, per100[nutrient]),
                      if (perServing != null)
                        valueCell(nutrient, perServing[nutrient]),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
