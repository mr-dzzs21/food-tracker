import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_view.dart';
import '../../../l10n/app_localizations.dart';
import '../off_product_mapper.dart';
import '../product_repository.dart';
import 'food_tile.dart';

/// Open Food Facts search results for [query], page by page.
///
/// Loads the first page when shown and one more page per tap on
/// "Mehr laden" – never while the user types (OFF allows only a few searches
/// per minute; the client also spaces requests out). Shown inside a
/// scrolling list, so it is a plain [Column].
class OnlineSearchResults extends ConsumerStatefulWidget {
  const OnlineSearchResults({
    super.key,
    required this.query,
    required this.onOpen,
  });

  final String query;

  /// Called when the user taps a result.
  final ValueChanged<OffProduct> onOpen;

  @override
  ConsumerState<OnlineSearchResults> createState() =>
      _OnlineSearchResultsState();
}

class _OnlineSearchResultsState extends ConsumerState<OnlineSearchResults> {
  /// How many pages the user asked for so far.
  int _pageCount = 1;

  @override
  void didUpdateWidget(OnlineSearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _pageCount = 1;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final keys = [
      for (var page = 1; page <= _pageCount; page++)
        (query: widget.query, page: page, languageCode: l10n.localeName),
    ];
    // Watching every page keeps the loaded pages; only new pages load.
    final pages = [
      for (final key in keys) ref.watch(productSearchProvider(key)),
    ];

    final first = pages.first;
    if (first case AsyncError(:final error) when !first.isLoading) {
      return _ErrorView(
        error: error,
        onRetry: () => ref.invalidate(productSearchProvider(keys.first)),
      );
    }
    if (!first.hasValue) return const _Loading();

    final products = [for (final page in pages) ...?page.value?.products];
    if (products.isEmpty) {
      return StatusView(
        icon: Icons.search_off,
        title: l10n.searchNoOnlineResults,
        message: l10n.searchNoResultsHint,
        compact: true,
      );
    }

    final last = pages.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final product in products)
          FoodTile.offProduct(product, onTap: () => widget.onOpen(product)),
        switch (last) {
          AsyncError(:final error) when !last.isLoading => _ErrorView(
            error: error,
            onRetry: () => ref.invalidate(productSearchProvider(keys.last)),
          ),
          AsyncData(:final value) when value.hasMore => Padding(
            padding: const EdgeInsets.all(Spacing.s),
            child: Center(
              child: OutlinedButton(
                onPressed: () => setState(() => _pageCount++),
                child: Text(l10n.searchLoadMore),
              ),
            ),
          ),
          AsyncData() => const SizedBox.shrink(),
          _ => const _Loading(),
        },
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.l,
            Spacing.s,
            Spacing.l,
            0,
          ),
          child: Text(
            l10n.productAttribution,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Spacing.xl),
    child: Center(child: CircularProgressIndicator()),
  );
}

/// The message for a failed search, with "Nochmal versuchen".
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = this.error;
    return StatusView(
      icon: error is Offline ? Icons.cloud_off : Icons.error_outline,
      title: error is AppFailure
          ? failureMessage(error, l10n)
          : l10n.errorGeneric,
      actionLabel: l10n.actionRetry,
      onAction: onRetry,
      compact: true,
    );
  }
}
