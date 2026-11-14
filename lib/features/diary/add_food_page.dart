import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_view.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../products/product_repository.dart';
import '../products/widgets/food_tile.dart';
import '../products/widgets/online_search_results.dart';
import 'day_label.dart';
import 'diary_repository.dart';

/// Adds food to one meal of one day: search, recents, favourites, own foods.
///
/// Every way ends on the product page with [day] and [mealId]. After
/// "Hinzufügen" there, this page closes too, so the user is back on "Heute".
class AddFoodPage extends ConsumerStatefulWidget {
  const AddFoodPage({super.key, required this.day, required this.mealId});

  /// Day key yyyy-MM-dd.
  final String day;

  /// Id of the MealSlot.
  final int mealId;

  @override
  ConsumerState<AddFoodPage> createState() => _AddFoodPageState();
}

/// The lists below the search field.
enum _Segment { recent, favourites, own }

class _AddFoodPageState extends ConsumerState<AddFoodPage> {
  /// Waiting time after the last key press before the local list is
  /// filtered, so the list does not flicker while typing.
  static const _filterDelay = Duration(milliseconds: 250);

  final _search = TextEditingController();
  Timer? _filterTimer;

  /// The text the local list is filtered by ('' = show the segments).
  String _filter = '';

  /// The text of the last online search (only on submit), or null.
  String? _onlineQuery;

  _Segment _segment = _Segment.recent;

  @override
  void dispose() {
    _filterTimer?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _filterTimer?.cancel();
    _filterTimer = Timer(_filterDelay, () {
      if (!mounted) return;
      final filter = text.trim();
      setState(() {
        _filter = filter;
        // Online results of an older search would no longer match.
        if (filter != _onlineQuery) _onlineQuery = null;
      });
    });
  }

  void _onSubmitted(String query) {
    _filterTimer?.cancel();
    setState(() {
      _filter = query;
      _onlineQuery = query;
    });
  }

  /// Opens a product page for this meal; closes this page when the food was
  /// added there.
  Future<void> _open(String location) async {
    final added = await context.push<bool>(location);
    if (added == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final day = widget.day;
    final mealId = widget.mealId;
    final slots = ref.watch(mealSlotsProvider).value ?? const <MealSlot>[];
    final slot = slots.where((s) => s.id == mealId).firstOrNull;
    final today = todayKey(ref.watch(clockProvider));
    final dayText = dayLabel(day, today: today, l10n: l10n);

    void openFood(Food food) =>
        unawaited(_open(Routes.food(food.id, day: day, mealId: mealId)));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          slot == null
              ? dayText
              : l10n.addFoodTitle(mealSlotName(slot, l10n), dayText),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.l,
              Spacing.s,
              Spacing.l,
              0,
            ),
            child: SearchField(
              controller: _search,
              hintText: l10n.addFoodSearchHint,
              onChanged: _onChanged,
              onSubmitted: _onSubmitted,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.l,
              Spacing.m,
              Spacing.l,
              0,
            ),
            // Wrap instead of Row: at large font sizes the buttons go below
            // each other instead of overflowing.
            child: Wrap(
              spacing: Spacing.s,
              runSpacing: Spacing.s,
              children: [
                FilledButton.tonalIcon(
                  // The scanner and the form replace themselves with the
                  // product page and close this page after "Hinzufügen"
                  // (replaceInAddFlow), so nothing to wait for here.
                  onPressed: () =>
                      unawaited(context.push(Routes.addFoodScan(day, mealId))),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.addFoodScan),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => unawaited(
                    context.push(Routes.newFood(day: day, mealId: mealId)),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addFoodCreateOwn),
                ),
              ],
            ),
          ),
          if (_filter.isEmpty)
            ..._segmentList(l10n, openFood)
          else
            ..._searchResults(l10n, openFood),
        ],
      ),
    );
  }

  /// Segments "Zuletzt · Favoriten · Eigene" and the chosen list.
  List<Widget> _segmentList(
    AppLocalizations l10n,
    ValueChanged<Food> openFood,
  ) {
    final (foods, emptyIcon, emptyText) = switch (_segment) {
      _Segment.recent => (
        ref.watch(recentlyUsedFoodsProvider),
        Icons.history,
        l10n.addFoodRecentEmpty,
      ),
      _Segment.favourites => (
        ref.watch(favouriteFoodsProvider),
        Icons.star_border,
        l10n.addFoodFavouritesEmpty,
      ),
      _Segment.own => (
        ref.watch(ownFoodsProvider),
        Icons.edit_note,
        l10n.addFoodOwnEmpty,
      ),
    };
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.l,
          Spacing.l,
          Spacing.l,
          Spacing.s,
        ),
        child: SegmentedButton<_Segment>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: _Segment.recent,
              label: Text(l10n.addFoodSegmentRecent),
            ),
            ButtonSegment(
              value: _Segment.favourites,
              label: Text(l10n.addFoodSegmentFavourites),
            ),
            ButtonSegment(
              value: _Segment.own,
              label: Text(l10n.addFoodSegmentOwn),
            ),
          ],
          selected: {_segment},
          onSelectionChanged: (selection) =>
              setState(() => _segment = selection.single),
        ),
      ),
      _FoodList(
        foods: foods,
        emptyIcon: emptyIcon,
        emptyText: emptyText,
        onTap: openFood,
      ),
    ];
  }

  /// Matches on the device (while typing) and online results (on submit).
  List<Widget> _searchResults(
    AppLocalizations l10n,
    ValueChanged<Food> openFood,
  ) {
    final onlineQuery = _onlineQuery;
    final local = ref.watch(localFoodSearchProvider(_filter));
    // After an online search, an empty "on your device" part is just noise.
    final hideLocal = onlineQuery != null && (local.value?.isEmpty ?? false);
    return [
      if (!hideLocal) ...[
        SectionHeader(l10n.searchLocalTitle),
        _FoodList(
          foods: local,
          emptyIcon: Icons.search_off,
          // Points the user to the online search.
          emptyText: l10n.addFoodNoLocalMatches,
          onTap: openFood,
        ),
      ],
      if (onlineQuery != null) ...[
        SectionHeader(l10n.searchOnlineTitle),
        OnlineSearchResults(
          query: onlineQuery,
          onOpen: (product) => unawaited(
            _open(
              Routes.product(
                product.barcode,
                day: widget.day,
                mealId: widget.mealId,
              ),
            ),
          ),
        ),
      ],
    ];
  }
}

/// A list of stored foods with loading, error and empty states.
class _FoodList extends StatelessWidget {
  const _FoodList({
    required this.foods,
    required this.emptyIcon,
    required this.emptyText,
    required this.onTap,
  });

  final AsyncValue<List<Food>> foods;
  final IconData emptyIcon;
  final String emptyText;
  final ValueChanged<Food> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (foods) {
      AsyncData(value: final list) when list.isEmpty => StatusView(
        icon: emptyIcon,
        title: emptyText,
        compact: true,
      ),
      AsyncData(value: final list) => Column(
        children: [
          for (final food in list)
            FoodTile.food(food, onTap: () => onTap(food)),
        ],
      ),
      AsyncError() => StatusView(
        icon: Icons.error_outline,
        title: l10n.errorGeneric,
        compact: true,
      ),
      _ => const Padding(
        padding: EdgeInsets.all(Spacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// Replaces the current page of the add-food flow (the scanner or the
/// own-food form) with [location], a product page for the chosen meal.
///
/// When the food gets added there, the add-food page below is closed too,
/// so the user ends on "Heute" – the same as when picking a food from the
/// lists. The router is taken first because the current page is gone by the
/// time the product page closes.
Future<void> replaceInAddFlow(BuildContext context, String location) async {
  final router = GoRouter.of(context);
  final added = await router.pushReplacement<bool>(location);
  if (added == true) router.pop();
}
