import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/status_view.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../products/widgets/food_search_results.dart';

/// Search results for [query] (submitted on the Scan tab), best first:
/// simple foods with average values, foods already on the device, then
/// brand products from Open Food Facts (Germany) with "Mehr laden" – see
/// FoodSearchResults.
class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key, required this.query});

  /// What the user typed.
  final String query;

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: PageHeader(title: l10n.searchResultsTitle(query)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          FoodSearchResults(
            query: query,
            // Submitted on purpose: search online at once.
            onlineQuery: query,
            onOpenFood: (id) => context.push(Routes.food(id)),
            onOpenProduct: (product) =>
                context.push(Routes.product(product.barcode)),
          ),
        ],
      ),
    );
  }
}
