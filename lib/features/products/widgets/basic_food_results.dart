import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/card_list.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/app_localizations.dart';
import '../basic_foods.dart';
import '../basic_foods_repository.dart';
import '../product_repository.dart';
import 'food_tile.dart';

/// The first part of every search: "Grundnahrungsmittel" – basic foods with
/// average values from the BLS that match [query], with the source line the
/// licence asks for. Shows nothing at all when there is no match (or while
/// the foods load, which takes only a moment).
///
/// The search runs on the device, so it is fine to show this while the user
/// types. Used by the add-food page and the search results page.
class BasicFoodResults extends ConsumerWidget {
  const BasicFoodResults({
    super.key,
    required this.query,
    required this.onOpen,
  });

  final String query;

  /// Called with the id of the tapped food. The food is saved on the device
  /// first, so the normal product page (`Routes.food`) can show it.
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = l10n.localeName;
    final foods = ref.watch(
      basicFoodSearchProvider((query: query, languageCode: languageCode)),
    );
    if (foods.isEmpty) return const SizedBox.shrink();

    Future<void> open(BasicFood food) async {
      final id = await ref
          .read(productRepositoryProvider)
          .saveBasicFood(food, languageCode: languageCode);
      if (context.mounted) onOpen(id);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l10n.searchBasicFoodsTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: CardGroup(
            children: [
              for (final food in foods)
                FoodTile.basicFood(
                  food,
                  languageCode: languageCode,
                  onTap: () => unawaited(open(food)),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.l + Spacing.xs,
            Spacing.s,
            Spacing.l,
            0,
          ),
          child: Text(
            l10n.blsAttribution,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
