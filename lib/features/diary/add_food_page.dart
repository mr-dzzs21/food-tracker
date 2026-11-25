import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/clock.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/card_list.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/pill_choices.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/status_view.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../products/product_repository.dart';
import '../products/widgets/food_search_results.dart';
import '../products/widgets/food_tile.dart';
import 'day_label.dart';
import 'diary_repository.dart';

/// Adds food to one meal of one day: search, recents, favourites, own foods.
///
/// The search shows simple foods and foods on the device while the user
/// types (FoodSearchResults), and the brand products of Open Food Facts below
/// as soon as the user stops typing for a moment – or at once on submit
/// (keyboard or the arrow in the field).
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
  /// Waiting time after the last key press before the lists on the device
  /// are filtered, so they do not flicker while typing.
  static const filterDelay = Duration(milliseconds: 250);

  /// Waiting time after the last key press before Open Food Facts is asked.
  /// Longer: OFF allows only a few searches per minute, and a search for
  /// half a word ("sky") is wasted.
  static const onlineDelay = Duration(milliseconds: 700);

  /// Shorter texts are not searched online while typing (too many hits).
  static const minOnlineLength = 2;

  final _search = TextEditingController();
  Timer? _filterTimer;
  Timer? _onlineTimer;

  /// The text the local lists are filtered by ('' = show the segments).
  String _filter = '';

  /// The text of the current online search, or null.
  String? _onlineQuery;

  _Segment _segment = _Segment.recent;

  @override
  void dispose() {
    // Timers must not fire after the page is gone (and tests check that no
    // timer is left).
    _filterTimer?.cancel();
    _onlineTimer?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _filterTimer?.cancel();
    _filterTimer = Timer(filterDelay, () {
      if (mounted) setState(() => _filter = text.trim());
    });

    _onlineTimer?.cancel();
    final query = _onlineText(text);
    if (query.length < minOnlineLength) {
      // Nothing (useful) to search online: no brand section.
      if (_onlineQuery != null) setState(() => _onlineQuery = null);
      return;
    }
    _onlineTimer = Timer(onlineDelay, () {
      if (mounted) setState(() => _onlineQuery = query);
    });
  }

  void _onSubmitted(String text) {
    _filterTimer?.cancel();
    _onlineTimer?.cancel();
    setState(() {
      _filter = text.trim();
      _onlineQuery = _onlineText(text);
    });
  }

  /// The text for Open Food Facts: without extra spaces, so "skyr " and
  /// "skyr" are one search, not two.
  static String _onlineText(String text) =>
      text.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Opens a product page for this meal; closes this page when the food was
  /// added there.
  Future<void> _open(String location) async {
    if (!mounted) return;
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
      appBar: PageHeader(
        title: slot == null
            ? dayText
            : l10n.addFoodTitle(mealSlotName(slot, l10n), dayText),
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
            child: _ActionButtons(
              // The scanner and the form replace themselves with the
              // product page and close this page after "Hinzufügen"
              // (replaceInAddFlow), so nothing to wait for here.
              scan: CtaButton(
                onPressed: () =>
                    unawaited(context.push(Routes.addFoodScan(day, mealId))),
                icon: Icons.qr_code_scanner_rounded,
                label: l10n.addFoodScan,
              ),
              createOwn: TonalButton(
                large: true,
                onPressed: () => unawaited(
                  context.push(Routes.newFood(day: day, mealId: mealId)),
                ),
                icon: Icons.add_rounded,
                label: l10n.addFoodCreateOwn,
              ),
            ),
          ),
          if (_filter.isEmpty)
            ..._segmentList(l10n, openFood)
          else
            _searchResults(),
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
        Icons.history_rounded,
        l10n.addFoodRecentEmpty,
      ),
      _Segment.favourites => (
        ref.watch(favouriteFoodsProvider),
        Icons.star_outline_rounded,
        l10n.addFoodFavouritesEmpty,
      ),
      _Segment.own => (
        ref.watch(ownFoodsProvider),
        Icons.edit_note_rounded,
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
        child: PillChoices<_Segment>(
          segmented: true,
          choices: [
            PillChoice(l10n.addFoodSegmentRecent, _Segment.recent),
            PillChoice(l10n.addFoodSegmentFavourites, _Segment.favourites),
            PillChoice(l10n.addFoodSegmentOwn, _Segment.own),
          ],
          selected: _segment,
          onSelected: (segment) => setState(() => _segment = segment),
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

  /// Simple foods, foods on the device and brand products
  /// (FoodSearchResults). The brand part keeps the last results while the
  /// user types on and shows a loading indicator before the first search.
  Widget _searchResults() {
    return FoodSearchResults(
      query: _filter,
      onlineQuery: _onlineQuery,
      onlinePending: _onlineTimer?.isActive ?? false,
      onOpenFood: (id) => unawaited(
        _open(Routes.food(id, day: widget.day, mealId: widget.mealId)),
      ),
      onOpenProduct: (product) => unawaited(
        _open(
          Routes.product(
            product.barcode,
            day: widget.day,
            mealId: widget.mealId,
          ),
        ),
      ),
    );
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
      AsyncData(value: final list) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
        child: CardGroup(
          children: [
            for (final food in list)
              FoodTile.food(food, onTap: () => onTap(food)),
          ],
        ),
      ),
      AsyncError() => StatusView(
        icon: Icons.error_outline_rounded,
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

/// "Scannen" and "Eigenes Lebensmittel" side by side, or below each other
/// when there is not enough room (narrow screen or large text).
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.scan, required this.createOwn});

  final Widget scan;
  final Widget createOwn;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (largeText || constraints.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              scan,
              const SizedBox(height: Spacing.s),
              createOwn,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: scan),
              const SizedBox(width: Spacing.s),
              Expanded(child: createOwn),
            ],
          ),
        );
      },
    );
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
