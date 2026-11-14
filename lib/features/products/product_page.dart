import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/clock.dart';
import '../../core/errors.dart';
import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_view.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../diary/day_label.dart';
import '../diary/diary_repository.dart';
import '../diary/widgets/amount_field.dart';
import '../diary/widgets/meal_dropdown.dart';
import 'food_source.dart';
import 'nutrient_format.dart';
import 'nutrients.dart';
import 'product_repository.dart';
import 'widgets/nutrition_table.dart';
import 'widgets/rating_section.dart';

/// Product details: health rating, nutrients, portion picker and
/// "Hinzufügen" to the diary.
///
/// Opened either with a [barcode] (looked up in the cache, then at
/// Open Food Facts) or with the [foodId] of a food already stored on the
/// device. [day] and [mealId] say where "Hinzufügen" puts the food; when they
/// are null, today and the meal that fits the time of day are used.
///
/// After "Hinzufügen" the page closes with the result `true`.
class ProductPage extends ConsumerWidget {
  const ProductPage.barcode({
    super.key,
    required String this.barcode,
    this.day,
    this.mealId,
  }) : foodId = null;

  const ProductPage.food({
    super.key,
    required int this.foodId,
    this.day,
    this.mealId,
  }) : barcode = null;

  final String? barcode;
  final int? foodId;
  final String? day;
  final int? mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barcode = this.barcode;
    if (barcode != null) {
      return _BarcodeLookup(barcode: barcode, day: day, mealId: mealId);
    }
    // The two constructors make sure that either barcode or foodId is set.
    return _StoredFood(foodId: foodId!, day: day, mealId: mealId);
  }
}

/// Looks the barcode up (device first, then Open Food Facts).
class _BarcodeLookup extends ConsumerWidget {
  const _BarcodeLookup({required this.barcode, this.day, this.mealId});

  final String barcode;
  final String? day;
  final int? mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (
      barcode: barcode,
      languageCode: AppLocalizations.of(context).localeName,
    );
    final lookup = ref.watch(barcodeLookupProvider(key));
    return switch (lookup) {
      AsyncData(:final value) => _StoredFood(
        foodId: value.id,
        day: day,
        mealId: mealId,
      ),
      // While "Nochmal versuchen" runs, show the spinner, not the old error.
      AsyncError(:final error) when !lookup.isLoading => _FailureView(
        error: error,
        barcode: barcode,
        day: day,
        mealId: mealId,
        onRetry: () => ref.invalidate(barcodeLookupProvider(key)),
      ),
      _ => const _LoadingView(),
    };
  }
}

/// Shows a food stored on the device and follows its changes (favourite).
class _StoredFood extends ConsumerWidget {
  const _StoredFood({required this.foodId, this.day, this.mealId});

  final int foodId;
  final String? day;
  final int? mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final food = ref.watch(foodProvider(foodId));
    return switch (food) {
      // Without calories the food cannot be logged: ask to complete it.
      AsyncData(value: final food?) when food.kcal == null => _MessageScaffold(
        icon: Icons.edit_note,
        title: l10n.failureIncomplete,
        actionLabel: l10n.productCompleteValues,
        onAction: () => context.pushReplacement(
          food.source == FoodSource.user
              ? Routes.editFood(food.id)
              : Routes.newFood(barcode: food.barcode, day: day, mealId: mealId),
        ),
      ),
      AsyncData(value: final food?) => _FoodDetails(
        food: food,
        day: day,
        mealId: mealId,
      ),
      AsyncData() => _MessageScaffold(
        icon: Icons.no_food_outlined,
        title: l10n.productGone,
      ),
      AsyncError() when !food.isLoading => _MessageScaffold(
        icon: Icons.error_outline,
        title: l10n.errorGeneric,
        actionLabel: l10n.actionRetry,
        onAction: () => ref.invalidate(foodProvider(foodId)),
      ),
      _ => const _LoadingView(),
    };
  }
}

/// What to show when the lookup failed.
class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.error,
    required this.barcode,
    required this.onRetry,
    this.day,
    this.mealId,
  });

  final Object error;
  final String barcode;
  final VoidCallback onRetry;
  final String? day;
  final int? mealId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = this.error;
    // The own-food form, prefilled with the barcode. It replaces this page,
    // so "back" from the form does not return to the error.
    void openForm() => context.pushReplacement(
      Routes.newFood(barcode: barcode, day: day, mealId: mealId),
    );

    if (error is! AppFailure) {
      return _MessageScaffold(
        icon: Icons.error_outline,
        title: l10n.errorGeneric,
        actionLabel: l10n.actionRetry,
        onAction: onRetry,
      );
    }
    final message = failureMessage(error, l10n);
    return switch (error) {
      ProductNotFound() => _MessageScaffold(
        icon: Icons.search_off,
        title: message,
        actionLabel: l10n.productCreateOwn,
        onAction: openForm,
      ),
      IncompleteProduct() => _MessageScaffold(
        icon: Icons.edit_note,
        title: message,
        actionLabel: l10n.productCompleteValues,
        onAction: openForm,
      ),
      // Retrying cannot help with these two.
      NotFood() || InvalidBarcode() => _MessageScaffold(
        icon: Icons.info_outline,
        title: message,
      ),
      Offline() => _MessageScaffold(
        icon: Icons.cloud_off,
        title: message,
        actionLabel: l10n.actionRetry,
        onAction: onRetry,
      ),
      RequestTimeout() ||
      RateLimited() ||
      ServerUnavailable() => _MessageScaffold(
        icon: Icons.hourglass_empty,
        title: message,
        actionLabel: l10n.actionRetry,
        onAction: onRetry,
      ),
    };
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: const Center(child: CircularProgressIndicator()),
  );
}

/// A page with only a back button and a [StatusView].
class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: StatusView(
      icon: icon,
      title: title,
      actionLabel: actionLabel,
      onAction: onAction,
    ),
  );
}

// -----------------------------------------------------------------------------
// The product itself

class _FoodDetails extends ConsumerStatefulWidget {
  const _FoodDetails({required this.food, this.day, this.mealId});

  final Food food;
  final String? day;
  final int? mealId;

  @override
  ConsumerState<_FoodDetails> createState() => _FoodDetailsState();
}

class _FoodDetailsState extends ConsumerState<_FoodDetails> {
  final _amount = TextEditingController();

  /// The meal the user picked in the dropdown (null = not changed yet).
  int? _pickedSlotId;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    // "Zuletzt angesehen" on the Scan tab.
    unawaited(ref.read(productRepositoryProvider).markViewed(widget.food.id));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start with one portion if known, otherwise 100 g. Set here (not in
    // initState) because the number format needs the language.
    if (_amount.text.isEmpty) {
      final serving = widget.food.servingSize;
      _amount.text = formatInputNumber(
        (serving != null && serving > 0) ? serving : 100,
        AppLocalizations.of(context).localeName,
      );
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// The meal "Hinzufügen" uses: the user's choice, else the meal from the
  /// route, else the one that fits the time of day.
  MealSlot? _slotFor(List<MealSlot> slots, Clock clock) {
    final wanted = _pickedSlotId ?? widget.mealId;
    return slots.where((slot) => slot.id == wanted).firstOrNull ??
        preselectMealSlot(slots, minuteOfDay(clock.now()));
  }

  Future<void> _add({
    required MealSlot slot,
    required double amount,
    required String day,
  }) async {
    final l10n = AppLocalizations.of(context);
    // Taken before the await: the page may be gone afterwards. The root
    // ScaffoldMessenger outlives this page, so the SnackBar stays visible on
    // the page we return to.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _adding = true);
    try {
      await ref
          .read(diaryRepositoryProvider)
          .addEntry(
            food: widget.food,
            amount: amount,
            day: day,
            mealSlotId: slot.id,
          );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
    unawaited(HapticFeedback.selectionClick());
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.productAdded(mealSlotName(slot, l10n)))),
    );
    await navigator.maybePop(true);
  }

  Future<void> _openOnOff(String barcode) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).productLinkFailed;
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.https('world.openfoodfacts.org', '/product/$barcode'),
        mode: LaunchMode.externalApplication,
      );
    } on PlatformException {
      opened = false;
    }
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final food = widget.food;
    final clock = ref.watch(clockProvider);
    final day = widget.day ?? todayKey(clock);
    final slots = ref.watch(mealSlotsProvider).value ?? const <MealSlot>[];
    final slot = _slotFor(slots, clock);
    final lastAmount = ref.watch(lastAmountProvider(food.id)).value;
    final amount = parseEntryAmount(_amount.text);
    final barcode = food.barcode;
    final fromOff = food.source == FoodSource.openFoodFacts && barcode != null;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(food.isFavourite ? Icons.star : Icons.star_border),
            tooltip: food.isFavourite
                ? l10n.productFavouriteRemove
                : l10n.productFavouriteAdd,
            onPressed: () =>
                ref.read(productRepositoryProvider).toggleFavourite(food.id),
          ),
          if (food.source == FoodSource.user)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.actionEdit,
              onPressed: () => context.push(Routes.editFood(food.id)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          _Header(food: food),
          RatingSection(food: food),
          SectionHeader(l10n.productAmountTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AmountField(
                  controller: _amount,
                  isLiquid: food.isLiquid,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: Spacing.s),
                _AmountChips(
                  food: food,
                  lastAmount: lastAmount,
                  selected: amount,
                  onSelected: (value) => setState(
                    () => _amount.text = formatInputNumber(
                      value,
                      l10n.localeName,
                    ),
                  ),
                ),
                if (amount != null) ...[
                  const SizedBox(height: Spacing.m),
                  _PortionSummary(nutrients: food.nutrients.scaled(amount)),
                ],
                const SizedBox(height: Spacing.l),
                if (slots.isNotEmpty)
                  MealDropdown(
                    slots: slots,
                    selectedId: slot?.id,
                    onChanged: (id) => setState(() => _pickedSlotId = id),
                  ),
                const SizedBox(height: Spacing.s),
                Text(
                  l10n.productDay(
                    dayLabel(day, today: todayKey(clock), l10n: l10n),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.l),
                FilledButton.icon(
                  onPressed: (amount == null || slot == null || _adding)
                      ? null
                      : () => _add(slot: slot, amount: amount, day: day),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.actionAdd),
                ),
              ],
            ),
          ),
          NutritionTable(food: food),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.l,
              Spacing.xl,
              Spacing.l,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fromOff) ...[
                  Text(
                    l10n.productAttribution,
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    l10n.productCorrectHint,
                    style: theme.textTheme.bodySmall,
                  ),
                  TextButton.icon(
                    onPressed: () => _openOnOff(barcode),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.productOpenOff),
                  ),
                  const SizedBox(height: Spacing.s),
                ],
                Text(
                  fromOff ? l10n.disclaimerShort : l10n.disclaimerRating,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo, name, brand and package size.
class _Header extends StatelessWidget {
  const _Header({required this.food});

  final Food food;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final imageUrl = food.imageUrl;
    final brand = food.brand;
    final quantity = food.quantityLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null) ...[
            // Product photos are CC BY-SA: the caption names the licence.
            Tooltip(
              message: l10n.productImageCaption,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Radii.m),
                child: Image.network(
                  imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  // No internet or a broken link: a neutral placeholder.
                  errorBuilder: (context, _, _) => Container(
                    width: 72,
                    height: 72,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Spacing.l),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name.isEmpty ? l10n.productUnknownName : food.name,
                  style: theme.textTheme.headlineSmall,
                ),
                if (brand != null)
                  Text(
                    brand,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (quantity != null)
                  Text(quantity, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick choices: 100 g, one portion (if known), the amount used last time.
class _AmountChips extends StatelessWidget {
  const _AmountChips({
    required this.food,
    required this.lastAmount,
    required this.selected,
    required this.onSelected,
  });

  final Food food;
  final double? lastAmount;
  final double? selected;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String amountText(double value) =>
        formatAmount(value, isLiquid: food.isLiquid, locale: l10n.localeName);
    final serving = food.servingSize;
    final last = lastAmount;
    final choices = <(String, double)>[
      (amountText(100), 100),
      if (serving != null && serving > 0)
        (l10n.productServingChip(amountText(serving)), serving),
      if (last != null && last != 100 && last != serving)
        (l10n.productLastAmountChip(amountText(last)), last),
    ];
    return Wrap(
      spacing: Spacing.s,
      runSpacing: Spacing.xs,
      children: [
        for (final (label, value) in choices)
          ChoiceChip(
            label: Text(label),
            selected: selected == value,
            onSelected: (_) => onSelected(value),
          ),
      ],
    );
  }
}

/// kcal and macros for the chosen amount, updated while typing.
class _PortionSummary extends StatelessWidget {
  const _PortionSummary({required this.nutrients});

  final Nutrients nutrients;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String value(Nutrient nutrient) {
      final v = nutrients[nutrient];
      return v == null ? '–' : formatNutrientValue(nutrient, v, l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value(Nutrient.kcal), style: theme.textTheme.titleLarge),
        Wrap(
          spacing: Spacing.l,
          children: [
            for (final nutrient in const [
              Nutrient.protein,
              Nutrient.carbs,
              Nutrient.fat,
            ])
              Text(
                l10n.nutrientWithValue(
                  nutrientName(nutrient, l10n),
                  value(nutrient),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
