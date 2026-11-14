import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// A white (dark: surface) card with round corners and a soft shadow – the
/// basic container of every screen.
///
/// With [onTap] the whole card is tappable and gives press feedback: it
/// shrinks to 98 % and its shadow gets closer (no animation when the system
/// asks for reduced motion).
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.l),
    this.radius = Radii.card,
    this.color,
    this.shadow,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Another background, e.g. a tinted note (then without shadow).
  /// Defaults to the surface colour.
  final Color? color;

  /// Another shadow than the card shadow (e.g. the summary card's).
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final borderRadius = BorderRadius.circular(widget.radius);
    final content = Padding(padding: widget.padding, child: widget.child);
    final onTap = widget.onTap;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 120);
    final shadow = widget.color != null
        ? null
        : _pressed
        ? colors.pressedShadow
        : widget.shadow ?? colors.cardShadow;

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: duration,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadow,
        ),
        child: Material(
          color: widget.color ?? colors.surface,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: onTap == null
              ? content
              : InkWell(
                  onTap: onTap,
                  onHighlightChanged: (pressed) =>
                      setState(() => _pressed = pressed),
                  child: content,
                ),
        ),
      ),
    );
  }
}

/// The big card at the top of "Heute" and "Profil": radius 30, more padding
/// and a deeper shadow than an [AppCard].
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(
    radius: Radii.summary,
    padding: const EdgeInsets.all(18),
    shadow: context.appColors.summaryShadow,
    child: child,
  );
}
