import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// One option of [PillChoices].
@immutable
class PillChoice<T> {
  const PillChoice(this.label, this.value);

  final String label;
  final T value;
}

/// A row of round "pill" buttons of which one is selected (dark CTA
/// colours). Replaces Material chips and segmented buttons.
///
/// Each pill is a button with the "selected" state for screen readers and
/// a touch area of at least 48 px height.
class PillChoices<T> extends StatelessWidget {
  const PillChoices({
    super.key,
    required this.choices,
    required this.selected,
    required this.onSelected,
  });

  final List<PillChoice<T>> choices;

  /// The selected value; `null` when none of the choices fits.
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.s,
      children: [
        for (final choice in choices)
          Pill(
            label: choice.label,
            selected: choice.value == selected,
            onTap: () => onSelected(choice.value),
          ),
      ],
    );
  }
}

/// A single pill button (see [PillChoices]).
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = Theme.of(context).textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.w800,
      color: selected ? colors.onCta : colors.ink,
    );
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // The invisible 4 px above and below belong to the touch area
        // (40 px pill + 8 px = 48 px).
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 40, minWidth: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.l,
              vertical: Spacing.s,
            ),
            decoration: ShapeDecoration(
              color: selected ? colors.cta : colors.surface,
              shape: StadiumBorder(
                side: BorderSide(color: selected ? colors.cta : colors.border),
              ),
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(label, style: style, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
