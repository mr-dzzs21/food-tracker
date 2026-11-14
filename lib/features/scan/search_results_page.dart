import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/card_list.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_view.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../products/product_repository.dart';
import '../products/widgets/food_tile.dart';
import '../products/widgets/online_search_results.dart';

/// Open Food Facts text search results for [query].
///
/// Foods already on the device come first (they work offline and include
/// own foods), then the online results with "Mehr laden".
class SearchResultsPage extends ConsumerWidget {
  const SearchResultsPage({super.key, required this.query});

  /// What the user typed.
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = this.query.trim();
    if (query.isEmpty) {
      return Scaffold(
        appBar: const PageHeader(),
        body: StatusView(
          icon: Icons.search_rounded,
          title: l10n.searchEmptyQuery,
        ),
      );
    }

    final local = ref.watch(localFoodSearchProvider(query)).value ?? const [];
    return Scaffold(
      appBar: PageHeader(title: l10n.searchResultsTitle(query)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          // Shown only when there is something, the online part below has
          // its own empty and error states.
          if (local.isNotEmpty) ...[
            SectionHeader(l10n.searchLocalTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              child: CardGroup(
                children: [
                  for (final food in local)
                    FoodTile.food(
                      food,
                      onTap: () => context.push(Routes.food(food.id)),
                    ),
                ],
              ),
            ),
          ],
          SectionHeader(l10n.searchOnlineTitle),
          OnlineSearchResults(
            query: query,
            onOpen: (product) => context.push(Routes.product(product.barcode)),
          ),
        ],
      ),
    );
  }
}
