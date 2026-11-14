import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// The green gradient header at the top of a screen.
///
/// It reaches up under the status bar (with light status-bar icons), has
/// round bottom corners and two soft decorative circles. [top] is the row
/// with buttons (back, arrows, actions – use `SquareIconButton(onHero:
/// true)`); [child] is the content below it.
///
/// Inside the header all text styles and icons of the theme are white, so
/// `Theme.of(context).textTheme.titleLarge` just works on the gradient.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    this.top,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      Spacing.page,
      Spacing.s,
      Spacing.page,
      Spacing.xl,
    ),
  });

  final Widget? top;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final top = this.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(Radii.hero),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: colors.heroGradient),
          child: Stack(
            children: [
              // Decoration only: no touch, no screen-reader node.
              // Placed in the corners, away from the text.
              Positioned(
                top: -90,
                right: -60,
                child: _Circle(size: 200, color: colors.heroDecor),
              ),
              Positioned(
                bottom: -110,
                left: -120,
                child: _Circle(size: 160, color: colors.heroDecor),
              ),
              Theme(
                data: theme.copyWith(
                  textTheme: theme.textTheme.apply(
                    bodyColor: colors.onHero,
                    displayColor: colors.onHero,
                  ),
                  iconTheme: theme.iconTheme.copyWith(color: colors.onHero),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [?top, child],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

/// A small translucent pill on the hero ([AppColors.heroGlass]), e.g.
/// "Nutri-Score: D …" or the "Heute" button. With [onPressed] it is a button
/// (48 px touch area). [filled] = white pill with green text, for the main
/// action on the hero ("Ziel festlegen").
class HeroPill extends StatelessWidget {
  const HeroPill({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final background = filled ? colors.onHero : colors.heroGlass;
    final foreground = filled ? colors.brandDark : colors.onHero;
    final style = Theme.of(context).textTheme.labelMedium!
        .copyWith(color: foreground, fontSize: 13);
    final onPressed = this.onPressed;
    if (onPressed == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.m, vertical: 6),
        decoration: ShapeDecoration(
          color: background,
          shape: const StadiumBorder(),
        ),
        child: Text(label, style: style),
      );
    }
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        textStyle: style,
        minimumSize: const Size(48, 34),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: const StadiumBorder(),
      ),
      child: Text(label),
    );
  }
}
