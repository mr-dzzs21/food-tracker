import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/card_list.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/database.dart';
import '../../../l10n/app_localizations.dart';
import '../basic_foods.dart';
import '../basic_foods_repository.dart';
import '../off_product_mapper.dart';
import '../product_repository.dart';
import '../simple_foods.dart';
import '../simple_foods_repository.dart';
import 'food_result_row.dart';
import 'online_search_results.dart';

/// The search results of the add-food page and the search page, in the
/// order the owner chose ("Skyr" should simply find Skyr):
///
/// 1. "Lebensmittel": simple everyday foods with average values and short
///    names ("Skyr natur", "Reis gekocht"). The long, technical list of the
///    BLS ("Reis poliert, roh") shows only when no simple food fits, or
///    behind the small "Weitere Lebensmittel (BLS)" button.
/// 2. "Auf deinem Gerät": own foods and products seen before, at most
///    [maxLocal].
/// 3. "Markenprodukte (Deutschland)": Open Food Facts results for
///    [onlineQuery], directly below.
///
/// Parts 1 and 2 search on the device and follow [query] at once; the page
/// decides when to search online ([onlineQuery], [onlinePending]). Each part
/// shows only when it has something. Shown inside a scrolling list, so it
/// is a plain [Column].
class FoodSearchResults extends ConsumerStatefulWidget {
  const FoodSearchResults({
    super.key,
    required this.query,
    required this.onlineQuery,
    required this.onOpenFood,
    required this.onOpenProduct,
    this.onlinePending = false,
  });

  /// Foods on the device: at most this many (the section stays compact; the
  /// "Eigene" and "Zuletzt" lists show all of them).
  static const maxLocal = 5;

  /// The text for the search on the device.
  final String query;

  /// The text for the online search, or `null` for none (yet).
  final String? onlineQuery;

  /// True while the page waits to search online (the user is still
  /// typing): the brand section shows a loading indicator.
  final bool onlinePending;

  /// Called with the id of a stored food. Simple and basic foods are saved
  /// on the device first, so the normal product page (`Routes.food`) can
  /// show them.
  final ValueChanged<int> onOpenFood;

  /// Called when the user taps an Open Food Facts result.
  final ValueChanged<OffProduct> onOpenProduct;

  @override
  ConsumerState<FoodSearchResults> createState() => _FoodSearchResultsState();
}

class _FoodSearchResultsState extends ConsumerState<FoodSearchResults> {
  /// Whether the user opened "Weitere Lebensmittel (BLS)".
  bool _showBasicFoods = false;

  @override
  void didUpdateWidget(FoodSearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new text: the technical list folds up again.
    if (oldWidget.query != widget.query) _showBasicFoods = false;
  }

  Future<void> _openSimple(SimpleFood food, String languageCode) async {
    final id = await ref
        .read(productRepositoryProvider)
        .saveSimpleFood(food, languageCode: languageCode);
    if (mounted) widget.onOpenFood(id);
  }

  Future<void> _openBasic(BasicFood food, String languageCode) async {
    final id = await ref
        .read(productRepositoryProvider)
        .saveBasicFood(food, languageCode: languageCode);
    if (mounted) widget.onOpenFood(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = l10n.localeName;
    final query = widget.query;
    final simpleFoods = ref.watch(
      simpleFoodSearchProvider((query: query, languageCode: language)),
    );
    final basicFoods = ref.watch(
      basicFoodSearchProvider((query: query, languageCode: language)),
    );
    final localFoods = [...?ref.watch(localFoodSearchProvider(query)).value]
        .take(FoodSearchResults.maxLocal)
        .toList();
    final onlineQuery = widget.onlineQuery;
    final showBasicFoods = simpleFoods.isEmpty || _showBasicFoods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (simpleFoods.isNotEmpty || basicFoods.isNotEmpty)
          SectionHeader(l10n.searchFoodsTitle),
        if (simpleFoods.isNotEmpty) ...[
          _Rows([
            for (final food in simpleFoods)
              FoodResultRow.simpleFood(
                food,
                l10n: l10n,
                onTap: () => unawaited(_openSimple(food, language)),
              ),
          ]),
          // The licences ask to name the sources (BLS: CC BY 4.0, Open
          // Food Facts: ODbL).
          _SourceLine(l10n.searchFoodsAttribution),
          if (basicFoods.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.s),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _showBasicFoods = !_showBasicFoods),
                  icon: Icon(
                    _showBasicFoods
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  label: Text(
                    _showBasicFoods
                        ? l10n.searchFewerFoods
                        : l10n.searchMoreFoods,
                  ),
                ),
              ),
            ),
        ],
        if (showBasicFoods && basicFoods.isNotEmpty) ...[
          _Rows([
            for (final food in basicFoods)
              FoodResultRow.basicFood(
                food,
                languageCode: language,
                onTap: () => unawaited(_openBasic(food, language)),
              ),
          ]),
          _SourceLine(l10n.blsAttribution),
        ],
        if (localFoods.isNotEmpty) ...[
          SectionHeader(l10n.searchLocalTitle),
          _Rows([
            for (final Food food in localFoods)
              FoodResultRow.food(food, onTap: () => widget.onOpenFood(food.id)),
          ]),
        ],
        if (onlineQuery != null) ...[
          SectionHeader(l10n.searchOnlineTitle),
          OnlineSearchResults(query: onlineQuery, onOpen: widget.onOpenProduct),
        ] else if (widget.onlinePending) ...[
          SectionHeader(l10n.searchOnlineTitle),
          const Padding(
            padding: EdgeInsets.all(Spacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ],
    );
  }
}

/// Result rows in a white card with the page's side padding.
class _Rows extends StatelessWidget {
  const _Rows(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
    child: CardGroup(children: children),
  );
}

/// A small muted line under a card, for example the data source.
class _SourceLine extends StatelessWidget {
  const _SourceLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Spacing.l + Spacing.xs,
      Spacing.s,
      Spacing.l,
      0,
    ),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}
