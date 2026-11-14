import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/bottom_cta_bar.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/card_list.dart';
import '../../core/widgets/dialogs.dart';
import '../../core/widgets/status_view.dart';
import '../../core/widgets/switch_row.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../diary/add_food_page.dart';
import '../diary/diary_repository.dart';
import 'food_source.dart';
import 'nutrient_format.dart';
import 'nutrients.dart';
import 'product_repository.dart';

/// Form to create or edit an own food (name + nutrients per 100 g/ml).
///
/// - [foodId] set: edit that food.
/// - [barcode] set: create a food for a product Open Food Facts does not know.
/// - [day]/[mealId] set: after saving, continue to add the new food there.
///
/// A new food opens its product page afterwards (it replaces the form), so
/// the user sees the result and can add it to the diary right away.
class FoodFormPage extends ConsumerStatefulWidget {
  const FoodFormPage({
    super.key,
    this.foodId,
    this.barcode,
    this.day,
    this.mealId,
  });

  final int? foodId;
  final String? barcode;
  final String? day;
  final int? mealId;

  /// Highest kcal per 100 g: pure fat has about 900.
  static const maxKcal = 900.0;

  /// Highest grams per 100 g of a single nutrient.
  static const maxGrams = 100.0;

  @override
  ConsumerState<FoodFormPage> createState() => _FoodFormPageState();
}

class _FoodFormPageState extends ConsumerState<FoodFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _servingSize = TextEditingController();
  final _servingLabel = TextEditingController();
  final _values = {
    for (final nutrient in Nutrient.values) nutrient: TextEditingController(),
  };
  bool _isLiquid = false;

  /// The stored food: the one being edited, or a cached (incomplete) Open
  /// Food Facts product with the same barcode whose values prefill the form.
  Food? _existing;
  bool _loading = true;

  /// After the first "Speichern", errors update while the user types.
  bool _showErrors = false;
  bool _saving = false;

  bool get _isEdit => widget.foodId != null;

  /// The barcode of the food (read-only in the form).
  String? get _barcode => _isEdit ? _existing?.barcode : widget.barcode;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _brand,
      _servingSize,
      _servingLabel,
      ..._values.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final repository = ref.read(productRepositoryProvider);
    final foodId = widget.foodId;
    final barcode = widget.barcode;
    final food = foodId != null
        ? await repository.getFood(foodId)
        : barcode != null
        ? await repository.getFoodByBarcode(barcode)
        : null;
    if (!mounted) return;
    if (food != null) _fill(food);
    setState(() {
      _existing = food;
      _loading = false;
    });
  }

  /// Puts the stored values into the text fields.
  void _fill(Food food) {
    final locale = AppLocalizations.of(context).localeName;
    // Three decimals: small values like 0,03 g salt must survive editing.
    String text(double? value) =>
        value == null ? '' : formatInputNumber(value, locale, maxDecimals: 3);

    _name.text = food.name;
    _brand.text = food.brand ?? '';
    _isLiquid = food.isLiquid;
    _servingSize.text = text(food.servingSize);
    _servingLabel.text = food.servingLabel ?? '';
    final nutrients = food.nutrients;
    for (final nutrient in Nutrient.values) {
      _values[nutrient]!.text = text(nutrients[nutrient]);
    }
  }

  double? _number(Nutrient nutrient) =>
      parseUserNumber(_values[nutrient]!.text);

  // ---------------------------------------------------------------------------
  // Validation (texts come from the ARB files)

  String? _validateName(String? text, AppLocalizations l10n) =>
      (text ?? '').trim().isEmpty ? l10n.foodFormNameMissing : null;

  String? _validateNutrient(Nutrient nutrient, AppLocalizations l10n) {
    final text = _values[nutrient]!.text.trim();
    if (text.isEmpty) {
      // Only the calories are required: without them nothing can be counted.
      return nutrient == Nutrient.kcal ? l10n.foodFormKcalMissing : null;
    }
    final value = parseUserNumber(text);
    if (value == null) return l10n.foodFormNotANumber;

    final max = nutrient == Nutrient.kcal
        ? FoodFormPage.maxKcal
        : FoodFormPage.maxGrams;
    if (value < 0 || value > max) {
      return l10n.foodFormOutOfRange(formatKcal(max, l10n.localeName));
    }

    // Saturates are part of the fat, sugars part of the carbohydrates.
    final total = switch (nutrient) {
      Nutrient.saturatedFat => _number(Nutrient.fat),
      Nutrient.sugars => _number(Nutrient.carbs),
      _ => null,
    };
    if (total != null && value > total) {
      return nutrient == Nutrient.saturatedFat
          ? l10n.foodFormSaturatesAboveFat
          : l10n.foodFormSugarsAboveCarbs;
    }
    return null;
  }

  String? _validateServingSize(AppLocalizations l10n) {
    final text = _servingSize.text.trim();
    if (text.isEmpty) {
      // A portion name alone ("1 Scheibe") is useless without its size.
      return _servingLabel.text.trim().isEmpty
          ? null
          : l10n.foodFormPortionSizeMissing;
    }
    return parseEntryAmount(text) == null ? l10n.amountInvalid : null;
  }

  // ---------------------------------------------------------------------------
  // Actions

  Future<void> _save() async {
    setState(() => _showErrors = true);
    final form = _formKey.currentState;
    if (form == null) return;
    // Fields in the order they were built, i.e. from top to bottom.
    final invalid = form.validateGranularly();
    if (invalid.isNotEmpty) {
      // On a small screen the first error may be scrolled out of sight.
      unawaited(
        Scrollable.ensureVisible(
          invalid.first.context,
          alignment: 0.2,
          duration: const Duration(milliseconds: 200),
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final int id;
    try {
      id = await ref
          .read(productRepositoryProvider)
          .saveOwnFood(
            id: widget.foodId,
            name: _name.text,
            brand: _brand.text,
            barcode: _barcode,
            isLiquid: _isLiquid,
            servingSize: parseEntryAmount(_servingSize.text),
            servingLabel: _servingLabel.text,
            nutrients: Nutrients(
              kcal: _number(Nutrient.kcal),
              fat: _number(Nutrient.fat),
              saturatedFat: _number(Nutrient.saturatedFat),
              carbs: _number(Nutrient.carbs),
              sugars: _number(Nutrient.sugars),
              fibre: _number(Nutrient.fibre),
              protein: _number(Nutrient.protein),
              salt: _number(Nutrient.salt),
            ),
          );
    } on AppFailure catch (failure) {
      // Only possible with a broken barcode in the link.
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(failure, l10n))),
      );
      if (mounted) setState(() => _saving = false);
      return;
    }
    if (!mounted) return;

    if (_isEdit) {
      context.pop(true);
      return;
    }
    final day = widget.day;
    final mealId = widget.mealId;
    final location = Routes.food(id, day: day, mealId: mealId);
    if (day != null && mealId != null) {
      // Inside the add-food flow: after "Hinzufügen" back to "Heute".
      unawaited(replaceInAddFlow(context, location));
    } else {
      context.pushReplacement(location);
    }
  }

  Future<void> _delete(Food food) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.foodFormDeleteTitle(food.name),
      message: l10n.foodFormDeleteText,
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    await ref.read(productRepositoryProvider).deleteOwnFood(food.id);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.foodFormDeleted(food.name))),
    );
    if (mounted) context.pop();
  }

  // ---------------------------------------------------------------------------
  // Layout

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _isEdit ? l10n.foodFormEditTitle : l10n.foodFormNewTitle;

    if (_loading) {
      return Scaffold(
        appBar: AppTopBar(title: title),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final existing = _existing;
    if (_isEdit && existing == null) {
      return Scaffold(
        appBar: AppTopBar(title: title),
        body: StatusView(icon: Icons.no_food_rounded, title: l10n.productGone),
      );
    }

    final theme = Theme.of(context);
    final barcode = _barcode;
    final unit = _isLiquid ? 'ml' : 'g';
    const gap = SizedBox(height: Spacing.m);

    return Scaffold(
      appBar: AppTopBar(
        title: title,
        actions: [
          // Only own foods can be deleted (cached products are kept).
          if (existing != null && _isEdit && existing.source == FoodSource.user)
            SquareIconButton(
              icon: Icons.delete_outline_rounded,
              tooltip: l10n.actionDelete,
              onPressed: () => _delete(existing),
            ),
        ],
      ),
      // Always reachable, however long the form is.
      bottomNavigationBar: BottomCtaBar(
        child: CtaButton(
          onPressed: _saving ? null : _save,
          icon: Icons.check_rounded,
          label: l10n.actionSave,
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _showErrors
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        // Not a ListView: a ListView builds only the visible fields, and the
        // Form can only check fields that are built. The form is short
        // enough to build at once.
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: Spacing.s, bottom: Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.foodFormRequired(l10n.foodFormName),
                        ),
                        validator: (text) => _validateName(text, l10n),
                      ),
                      gap,
                      TextFormField(
                        controller: _brand,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.foodFormBrand,
                        ),
                      ),
                      if (barcode != null) ...[
                        gap,
                        // Comes from the scan; changing it would break the
                        // link to the package.
                        TextFormField(
                          initialValue: barcode,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: l10n.foodFormBarcode,
                            suffixIcon: const Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                      ],
                      const SizedBox(height: Spacing.xs),
                      SwitchRow(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.xs,
                        ),
                        title: l10n.foodFormIsLiquid,
                        value: _isLiquid,
                        onChanged: (value) => setState(() => _isLiquid = value),
                      ),
                    ],
                  ),
                ),
              ),
              CardSection(
                title: _isLiquid
                    ? l10n.foodFormNutrientsPer100ml
                    : l10n.foodFormNutrientsPer100g,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final nutrient in Nutrient.values) ...[
                      if (nutrient != Nutrient.values.first) gap,
                      TextFormField(
                        controller: _values[nutrient],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: nutrient == Nutrient.kcal
                              ? l10n.foodFormRequired(
                                  nutrientName(nutrient, l10n),
                                )
                              : nutrientName(nutrient, l10n),
                          suffixText: nutrient == Nutrient.kcal ? 'kcal' : 'g',
                        ),
                        validator: (_) => _validateNutrient(nutrient, l10n),
                      ),
                    ],
                    gap,
                    Text(
                      l10n.foodFormRequiredHint,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              CardSection(
                title: l10n.foodFormPortionTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _servingSize,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormPortionSize,
                        suffixText: unit,
                      ),
                      validator: (_) => _validateServingSize(l10n),
                    ),
                    gap,
                    TextFormField(
                      controller: _servingLabel,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: l10n.foodFormPortionLabel,
                        hintText: l10n.foodFormPortionLabelHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
