import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// The main action of a screen or sheet ("Hinzufügen"): full width, 58 px
/// high, forest-green CTA colours (from the [FilledButton] theme) with a soft
/// green glow, optional leading icon.
class CtaButton extends StatelessWidget {
  const CtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final IconData? icon;

  static final _style = FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(58),
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.page,
      vertical: Spacing.m,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final text = Text(label, textAlign: TextAlign.center);
    final icon = this.icon;
    final button = icon == null
        ? FilledButton(onPressed: onPressed, style: _style, child: text)
        : FilledButton.icon(
            onPressed: onPressed,
            style: _style,
            icon: Icon(icon),
            label: text,
          );
    // A disabled button does not glow.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.button),
        boxShadow: onPressed == null ? null : context.appColors.ctaShadow,
      ),
      child: button,
    );
  }
}

/// A secondary button in the soft green "tonal" colours.
///
/// Use this instead of `FilledButton.tonal`: the [FilledButton] theme paints
/// every filled button in CTA colours, also the tonal variant.
class TonalButton extends StatelessWidget {
  const TonalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.large = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// As big as a [CtaButton] (full width, 58 px), for a second main action
  /// next to one.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = FilledButton.styleFrom(
      backgroundColor: colors.tonal,
      foregroundColor: colors.onTonal,
      minimumSize: large ? const Size.fromHeight(58) : null,
      padding: large
          ? const EdgeInsets.symmetric(
              horizontal: Spacing.l,
              vertical: Spacing.m,
            )
          : null,
    );
    final icon = this.icon;
    final text = Text(label, textAlign: TextAlign.center);
    if (icon == null) {
      return FilledButton(onPressed: onPressed, style: style, child: text);
    }
    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon),
      label: text,
    );
  }
}

/// A round icon button (40 px circle by default, always a 48 × 48 touch
/// area), always with a tooltip. By default a white circle with a soft
/// shadow and an ink icon, like the arrows in the page headers;
/// [background] and [foreground] change the colours (e.g. the green "+" on
/// meal cards, which has no shadow).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconSize = 22,
    this.size = 40,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double iconSize;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = this.foreground ?? colors.ink;
    final background = this.background ?? colors.surface;
    // Only white buttons float above the page with a shadow.
    final shadow = this.background == null ? colors.buttonShadow.first : null;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: iconSize),
      style: IconButton.styleFrom(
        foregroundColor: foreground,
        disabledForegroundColor: foreground.withValues(alpha: 0.4),
        backgroundColor: background,
        disabledBackgroundColor: background.withValues(
          alpha: background.a * 0.5,
        ),
        fixedSize: Size.square(size),
        minimumSize: Size.square(size),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: const CircleBorder(),
        elevation: shadow == null || onPressed == null ? 0 : 3,
        shadowColor: shadow?.color,
      ),
    );
  }
}

/// The app's back button: a [RoundIconButton] with the rounded arrow.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) => RoundIconButton(
    icon: Icons.arrow_back_rounded,
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    onPressed: () => Navigator.maybePop(context),
  );
}
