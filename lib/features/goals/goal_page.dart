import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/eating_disorder_help.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_view.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../router.dart';
import '../products/nutrient_format.dart';
import '../products/nutrients.dart';
import 'calculator.dart';
import 'goal_enums.dart';
import 'goals_repository.dart';

/// Calculates or sets the daily calorie and macro goal.
///
/// Two modes: "Berechnen" (calculator with a live result) and "Selbst
/// eingeben" (calories typed in, macros optional). The saved goal prefills
/// the form. The disclaimer and the eating-disorder help are always visible.
class GoalPage extends ConsumerWidget {
  const GoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goal = ref.watch(goalProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalTitle)),
      body: switch (goal) {
        // The form reads the saved goal only once, when it is created, so
        // the user's typing is not overwritten by later updates.
        AsyncData(:final value) => _GoalForm(saved: value),
        AsyncError() => StatusView(
          icon: Icons.error_outline,
          title: l10n.errorGeneric,
          actionLabel: l10n.actionRetry,
          onAction: () => ref.invalidate(goalProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

enum _Mode { calculate, manual }

/// Highest calories a manual goal may have (protects against typos).
const _maxManualKcal = 10000;

/// Highest grams for one macro goal.
const _maxMacroGrams = 1000.0;

class _GoalForm extends ConsumerStatefulWidget {
  const _GoalForm({required this.saved});

  final UserGoalRow? saved;

  @override
  ConsumerState<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<_GoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _manualKcal = TextEditingController();
  final _macros = {
    Nutrient.protein: TextEditingController(),
    Nutrient.carbs: TextEditingController(),
    Nutrient.fat: TextEditingController(),
  };

  _Mode _mode = _Mode.calculate;
  Sex _sex = Sex.unspecified;
  ActivityLevel _activity = ActivityLevel.low;
  GoalType _goalType = GoalType.maintain;
  bool _saving = false;

  /// The saved goal is put into the fields only once.
  bool _isPrefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Needs the locale for the decimal comma, so not in initState.
    if (_isPrefilled) return;
    _isPrefilled = true;
    _prefill(widget.saved);
  }

  void _prefill(UserGoalRow? saved) {
    if (saved == null) return;
    final locale = AppLocalizations.of(context).localeName;
    String text(double value) => formatInputNumber(value, locale);

    _manualKcal.text = '${saved.kcal}';
    final sex = saved.sex;
    final age = saved.age;
    final height = saved.heightCm;
    final weight = saved.weightKg;
    final activity = saved.activity;
    final goalType = saved.goalType;
    if (sex != null &&
        age != null &&
        height != null &&
        weight != null &&
        activity != null &&
        goalType != null) {
      _sex = sex;
      _age.text = '$age';
      _height.text = text(height);
      _weight.text = text(weight);
      _activity = activity;
      _goalType = goalType;
      return;
    }

    // A goal typed in by hand. Macros that are just the defaults stay
    // empty, so they follow a changed calorie value.
    _mode = _Mode.manual;
    final defaults = manualMacros(saved.kcal.toDouble());
    void fill(Nutrient nutrient, double? value, double defaultValue) {
      if (value != null && (value - defaultValue).abs() > 0.5) {
        _macros[nutrient]!.text = text(value);
      }
    }

    fill(Nutrient.protein, saved.protein, defaults.protein);
    fill(Nutrient.carbs, saved.carbs, defaults.carbs);
    fill(Nutrient.fat, saved.fat, defaults.fat);
  }

  @override
  void dispose() {
    for (final controller in [
      _age,
      _height,
      _weight,
      _manualKcal,
      ..._macros.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Reading the fields

  int? get _ageValue => int.tryParse(_age.text.trim());

  /// The calculator input, or `null` while a field is empty or invalid.
  CalculatorInput? get _input {
    final age = _ageValue;
    final height = parseUserNumber(_height.text);
    final weight = parseUserNumber(_weight.text);
    if (age == null || height == null || weight == null) return null;
    final input = CalculatorInput(
      sex: _sex,
      age: age,
      heightCm: height,
      weightKg: weight,
      activity: _activity,
      goalType: _goalType,
    );
    return input.isValid ? input : null;
  }

  /// Lowest goal without the confirm dialog: from the calculator fields if
  /// they are filled in, otherwise 1200 kcal.
  double get _manualFloor {
    final input = _input;
    if (input == null) return minimumGoalKcal;
    return calculateGoal(input).floor;
  }

  /// Validator for a number field: empty is fine (no error while typing),
  /// otherwise the value must pass [isValid].
  String? Function(String?) _numberValidator(
    bool Function(String text) isValid,
    String message,
  ) {
    return (text) {
      final trimmed = (text ?? '').trim();
      if (trimmed.isEmpty) return null;
      return isValid(trimmed) ? null : message;
    };
  }

  // ---------------------------------------------------------------------------
  // Saving

  Future<void> _saveCalculated(GoalResult result, CalculatorInput input) {
    return _save(
      () => ref
          .read(goalsRepositoryProvider)
          .saveGoal(
            kcal: result.kcal.round(),
            protein: result.macros.protein,
            carbs: result.macros.carbs,
            fat: result.macros.fat,
            sex: input.sex,
            age: input.age,
            heightCm: input.heightCm,
            weightKg: input.weightKg,
            activity: input.activity,
            goalType: input.goalType,
          ),
    );
  }

  Future<void> _saveManual() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    // Checked by the validator above.
    final kcal = parseUserNumber(_manualKcal.text)?.round();
    if (kcal == null) return;
    final floor = _manualFloor;
    if (kcal < floor) {
      final confirmed = await _confirmBelowFloor(floor);
      if (confirmed != true || !mounted) return;
    }
    double? grams(Nutrient nutrient) =>
        parseUserNumber(_macros[nutrient]!.text);
    final macros = manualMacros(
      kcal.toDouble(),
      protein: grams(Nutrient.protein),
      fat: grams(Nutrient.fat),
      carbs: grams(Nutrient.carbs),
    );
    await _save(
      // No calculator inputs: a manual goal removes the old ones.
      () => ref
          .read(goalsRepositoryProvider)
          .saveGoal(
            kcal: kcal,
            protein: macros.protein,
            carbs: macros.carbs,
            fat: macros.fat,
          ),
    );
  }

  Future<bool?> _confirmBelowFloor(double floor) {
    final l10n = AppLocalizations.of(context);
    final kcal = formatKcal(floor, l10n.localeName);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.goalBelowFloorTitle(kcal)),
        content: Text(l10n.goalBelowFloorText(kcal)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.goalBelowFloorChange),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.goalBelowFloorSave),
          ),
        ],
      ),
    );
  }

  /// Runs [write], shows "gespeichert" and closes the page.
  Future<void> _save(Future<void> Function() write) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).goalSaved;
    setState(() => _saving = true);
    try {
      await write();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
    if (!mounted) return;
    // Opened from "Heute" with `go`, the profile page is below; just in case
    // there is nothing to go back to, open the profile tab.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.profile);
    }
  }

  // ---------------------------------------------------------------------------
  // Layout

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // Not a ListView: the Form can only validate fields that are built.
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.l,
          Spacing.s,
          Spacing.l,
          Spacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<_Mode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _Mode.calculate,
                  icon: const Icon(Icons.calculate_outlined),
                  label: Text(l10n.goalModeCalculate),
                ),
                ButtonSegment(
                  value: _Mode.manual,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.goalModeManual),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) =>
                  setState(() => _mode = selection.first),
            ),
            const SizedBox(height: Spacing.l),
            if (_mode == _Mode.calculate)
              ..._calculatorFields(l10n)
            else
              ..._manualFields(l10n),
            const SizedBox(height: Spacing.xl),
            const Divider(),
            const SizedBox(height: Spacing.l),
            Text(
              l10n.disclaimerGoals,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.l),
            const EatingDisorderHelp(),
          ],
        ),
      ),
    );
  }

  List<Widget> _calculatorFields(AppLocalizations l10n) {
    const gap = SizedBox(height: Spacing.m);
    final input = _input;
    final result = input == null ? null : calculateGoal(input);
    final age = _ageValue;

    return [
      _Label(l10n.goalSexLabel),
      Wrap(
        spacing: Spacing.s,
        children: [
          for (final sex in Sex.values)
            ChoiceChip(
              label: Text(_sexLabel(sex, l10n)),
              selected: _sex == sex,
              onSelected: (_) => setState(() => _sex = sex),
            ),
        ],
      ),
      gap,
      _NumberField(
        controller: _age,
        label: l10n.goalAgeLabel,
        suffix: l10n.goalAgeSuffix,
        decimal: false,
        validator: _numberValidator((text) {
          final value = int.tryParse(text);
          return value != null && isValidAge(value);
        }, l10n.goalAgeInvalid),
        onChanged: () => setState(() {}),
      ),
      gap,
      _NumberField(
        controller: _height,
        label: l10n.goalHeightLabel,
        suffix: 'cm',
        validator: _numberValidator((text) {
          final value = parseUserNumber(text);
          return value != null && isValidHeightCm(value);
        }, l10n.goalHeightInvalid),
        onChanged: () => setState(() {}),
      ),
      gap,
      _NumberField(
        controller: _weight,
        label: l10n.goalWeightLabel,
        suffix: 'kg',
        validator: _numberValidator((text) {
          final value = parseUserNumber(text);
          return value != null && isValidWeightKg(value);
        }, l10n.goalWeightInvalid),
        onChanged: () => setState(() {}),
      ),
      const SizedBox(height: Spacing.l),
      _Label(l10n.goalActivityLabel),
      RadioGroup<ActivityLevel>(
        groupValue: _activity,
        onChanged: (value) {
          if (value != null) setState(() => _activity = value);
        },
        child: Column(
          children: [
            for (final level in ActivityLevel.values)
              RadioListTile<ActivityLevel>(
                contentPadding: EdgeInsets.zero,
                value: level,
                title: Text(_activityLabel(level, l10n)),
                subtitle: Text(_activityText(level, l10n)),
              ),
          ],
        ),
      ),
      const SizedBox(height: Spacing.s),
      _Label(l10n.goalTypeLabel),
      RadioGroup<GoalType>(
        groupValue: _goalType,
        onChanged: (value) {
          if (value != null) setState(() => _goalType = value);
        },
        child: Column(
          children: [
            for (final type in GoalType.values)
              RadioListTile<GoalType>(
                contentPadding: EdgeInsets.zero,
                value: type,
                title: Text(_goalTypeLabel(type, l10n)),
              ),
          ],
        ),
      ),
      const SizedBox(height: Spacing.l),
      // Shown as soon as the age is known, even before the result.
      if (age != null && isValidAge(age) && isMinor(age)) ...[
        const _MinorHintCard(),
        gap,
      ],
      _ResultCard(result: result),
      const SizedBox(height: Spacing.l),
      FilledButton(
        onPressed: result == null || input == null || _saving
            ? null
            : () => _saveCalculated(result, input),
        child: Text(l10n.goalApply),
      ),
    ];
  }

  List<Widget> _manualFields(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final maxGrams = formatKcal(_maxMacroGrams, l10n.localeName);
    return [
      _NumberField(
        controller: _manualKcal,
        label: l10n.goalManualKcal,
        suffix: 'kcal',
        decimal: false,
        validator: (text) {
          final value = parseUserNumber(text ?? '');
          return value == null || value.round() < 1 || value > _maxManualKcal
              ? l10n.goalManualKcalInvalid(
                  formatKcal(_maxManualKcal.toDouble(), l10n.localeName),
                )
              : null;
        },
      ),
      SectionHeader(l10n.goalManualMacrosTitle),
      Text(
        l10n.goalManualMacrosHint,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      for (final MapEntry(key: nutrient, value: controller)
          in _macros.entries) ...[
        const SizedBox(height: Spacing.m),
        _NumberField(
          controller: controller,
          label: nutrientName(nutrient, l10n),
          suffix: 'g',
          validator: _numberValidator((text) {
            final value = parseUserNumber(text);
            return value != null && value >= 0 && value <= _maxMacroGrams;
          }, l10n.goalMacroInvalid(maxGrams)),
        ),
      ],
      const SizedBox(height: Spacing.l),
      FilledButton(
        onPressed: _saving ? null : _saveManual,
        child: Text(l10n.actionSave),
      ),
    ];
  }
}

// -----------------------------------------------------------------------------
// Texts for the enums

String _sexLabel(Sex sex, AppLocalizations l10n) => switch (sex) {
  Sex.male => l10n.goalSexMale,
  Sex.female => l10n.goalSexFemale,
  Sex.unspecified => l10n.goalSexUnspecified,
};

String _activityLabel(ActivityLevel level, AppLocalizations l10n) =>
    switch (level) {
      ActivityLevel.low => l10n.goalActivityLow,
      ActivityLevel.light => l10n.goalActivityLight,
      ActivityLevel.active => l10n.goalActivityActive,
      ActivityLevel.veryActive => l10n.goalActivityVeryActive,
    };

String _activityText(ActivityLevel level, AppLocalizations l10n) =>
    switch (level) {
      ActivityLevel.low => l10n.goalActivityLowText,
      ActivityLevel.light => l10n.goalActivityLightText,
      ActivityLevel.active => l10n.goalActivityActiveText,
      ActivityLevel.veryActive => l10n.goalActivityVeryActiveText,
    };

String _goalTypeLabel(GoalType type, AppLocalizations l10n) => switch (type) {
  GoalType.maintain => l10n.goalTypeMaintain,
  GoalType.loseSlow => l10n.goalTypeLoseSlow,
  GoalType.lose => l10n.goalTypeLose,
  GoalType.gainSlow => l10n.goalTypeGainSlow,
};

// -----------------------------------------------------------------------------
// Small widgets

/// A small heading above a group of choices.
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }
}

/// A text field for a number with a unit after it.
class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.validator,
    this.decimal = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final FormFieldValidator<String> validator;
  final bool decimal;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      validator: validator,
      onChanged: onChanged == null ? null : (_) => onChanged(),
    );
  }
}

/// The extra hint for people younger than 18 (owner's decision: the
/// calculator still works, but says it was made for adults).
class _MinorHintCard extends StatelessWidget {
  const _MinorHintCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.goalMinorTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    l10n.goalMinorText,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The live result of the calculator, or a hint while fields are missing.
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final GoalResult? result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final result = this.result;

    String grams(double value) => l10n.unitGrams(formatGrams(value, locale));
    String approx(double kcal) =>
        l10n.goalApprox(formatKcal(roundToTen(kcal), locale));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.goalResultTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: Spacing.m),
            if (result == null)
              Text(
                l10n.goalResultMissing,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              _ValueRow(l10n.goalResultBmr, approx(result.bmr)),
              _ValueRow(l10n.goalResultTotal, approx(result.totalNeed)),
              const SizedBox(height: Spacing.s),
              _ValueRow(
                l10n.goalResultGoal,
                l10n.unitKcal(formatKcal(result.kcal, locale)),
                emphasised: true,
              ),
              if (result.wasClamped) ...[
                const SizedBox(height: Spacing.s),
                Text(
                  l10n.goalFloorNote(formatKcal(result.floor, locale)),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: Spacing.m),
              // Protein and fibre are minimums (DGE), shown as "mind.".
              _ValueRow(
                nutrientName(Nutrient.protein, l10n),
                l10n.totalAtLeast(grams(result.macros.protein)),
              ),
              _ValueRow(
                nutrientName(Nutrient.carbs, l10n),
                grams(result.macros.carbs),
              ),
              _ValueRow(
                nutrientName(Nutrient.fat, l10n),
                grams(result.macros.fat),
              ),
              _ValueRow(
                nutrientName(Nutrient.fibre, l10n),
                l10n.totalAtLeast(grams(result.macros.fibre)),
              ),
              const SizedBox(height: Spacing.m),
              Text(
                l10n.goalEstimateNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Grundumsatz ........ ca. 1.780 kcal". Both sides may wrap, so large
/// text does not overflow.
class _ValueRow extends StatelessWidget {
  const _ValueRow(this.label, this.value, {this.emphasised = false});

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = emphasised ? textTheme.titleMedium : textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: Spacing.m),
          Flexible(
            child: Text(value, style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
