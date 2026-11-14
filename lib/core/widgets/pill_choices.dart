import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// One option of [PillChoices].
@immutable
class PillChoice<T> {
  const PillChoice(this.label, this.value);

  final String label;
  final T value;
}

/// A group of pill buttons of which one is selected (dark "selected"
/// colours, the others soft grey). Replaces Material chips and segmented
/// buttons.
///
/// [segmented] = one row of equally wide segments (radius 14), e.g.
/// "100 g · 1 Portion · Zuletzt" (they wrap when the text is very large);
/// otherwise round chips that wrap.
///
/// Each pill is a button with the "selected" state for screen readers and
/// a touch area of at least 48 px height.
class PillChoices<T> extends StatelessWidget {
  const PillChoices({
    super.key,
    required this.choices,
    required this.selected,
    required this.onSelected,
    this.segmented = false,
  });

  final List<PillChoice<T>> choices;

  /// The selected value; `null` when none of the choices fits.
  final T? selected;
  final ValueChanged<T> onSelected;
  final bool segmented;

  @override
  Widget build(BuildContext context) {
    Pill pill(PillChoice<T> choice) => Pill(
      label: choice.label,
      selected: choice.value == selected,
      radius: segmented ? Radii.segment : Radii.pill,
      onTap: () => onSelected(choice.value),
    );
    // With very large text equal widths would break words apart: then
    // the segments wrap like chips.
    if (segmented && MediaQuery.textScalerOf(context).scale(1) <= 1.5) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, choice) in choices.indexed) ...[
            if (index > 0) const SizedBox(width: 6),
            Expanded(child: pill(choice)),
          ],
        ],
      );
    }
    return Wrap(
      spacing: Spacing.s,
      children: [for (final choice in choices) pill(choice)],
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
    this.radius = Radii.pill,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = Theme.of(context).textTheme.labelMedium!.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: selected ? colors.onSelected : colors.ink,
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
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : shortAnimationDuration,
            constraints: const BoxConstraints(minHeight: 40, minWidth: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.m,
              vertical: Spacing.s,
            ),
            decoration: BoxDecoration(
              color: selected ? colors.selected : colors.surfaceAlt,
              borderRadius: BorderRadius.circular(radius),
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
