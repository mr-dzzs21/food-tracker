import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/card_list.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_view.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../products/product_repository.dart';
import '../products/widgets/food_tile.dart';
import 'widgets/barcode_scanner_view.dart';

/// Tab "Scannen": camera, text search and recently viewed products.
///
/// A scanned barcode opens the product page. The camera stops while that
/// page is open and starts again when the user comes back (see
/// [BarcodeScannerView]).
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openProduct(String code) =>
      context.push<void>(Routes.product(code));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scanner = ref.watch(scannerViewProvider);
    final recent = ref.watch(recentlyViewedFoodsProvider);

    return Scaffold(
      appBar: PageHeader(title: l10n.tabScan, large: true),
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              child: SizedBox(
                // About half of the screen for the camera, the rest stays
                // for the search and the list.
                height: constraints.maxHeight * 0.45,
                child: CameraArea(child: scanner(_openProduct)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: Spacing.xl),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.l,
                      Spacing.l,
                      Spacing.l,
                      0,
                    ),
                    child: SearchField(
                      controller: _search,
                      hintText: l10n.searchFieldHint,
                      onSubmitted: (query) =>
                          context.push(Routes.search(query)),
                    ),
                  ),
                  SectionHeader(l10n.scanRecentlyViewedTitle),
                  switch (recent) {
                    AsyncData(value: final foods) when foods.isEmpty =>
                      StatusView(
                        icon: Icons.history_rounded,
                        title: l10n.scanRecentlyViewedEmpty,
                        compact: true,
                      ),
                    AsyncData(value: final foods) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.l,
                      ),
                      child: CardGroup(
                        children: [
                          for (final food in foods)
                            FoodTile.food(
                              food,
                              onTap: () => context.push(Routes.food(food.id)),
                            ),
                        ],
                      ),
                    ),
                    AsyncError() => StatusView(
                      icon: Icons.error_outline_rounded,
                      title: l10n.errorGeneric,
                      actionLabel: l10n.actionRetry,
                      onAction: () =>
                          ref.invalidate(recentlyViewedFoodsProvider),
                      compact: true,
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
