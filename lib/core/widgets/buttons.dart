import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// The main action of a screen or sheet ("Hinzufügen"): full width, 58 px
/// high, dark CTA colours (from the [FilledButton] theme), optional icon.
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
    if (icon == null) {
      return FilledButton(onPressed: onPressed, style: _style, child: text);
    }
    return FilledButton.icon(
      onPressed: onPressed,
      style: _style,
      icon: Icon(icon),
      label: text,
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

/// A rounded-square icon button (40 × 40 by default, always a 48 × 48 touch
/// area), always with a tooltip. [onHero] = white icon on the hero's glass
/// colour, otherwise a white card button on the page background. [background] and
/// [foreground] override the colours (e.g. the dark "+" on meal tiles).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.onHero = false,
    this.iconSize = 22,
    this.size = 40,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool onHero;
  final double iconSize;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = this.foreground ?? (onHero ? colors.onHero : colors.ink);
    final background =
        this.background ?? (onHero ? colors.heroGlass : colors.surface);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            size < 40 ? Radii.square : Radii.iconButton,
          ),
        ),
      ),
    );
  }
}

/// The app's back button: "‹" in a rounded square ([SquareIconButton]).
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onHero = false});

  final bool onHero;

  @override
  Widget build(BuildContext context) => SquareIconButton(
    icon: Icons.arrow_back_ios_new_rounded,
    iconSize: 18,
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    onHero: onHero,
    onPressed: () => Navigator.maybePop(context),
  );
}
