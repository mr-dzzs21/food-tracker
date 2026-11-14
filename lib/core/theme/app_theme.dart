import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoPageTransitionsBuilder;
import 'package:material_ui/material_ui.dart';

// The visual language of the app (design A "Garten", see
// .notes/design/design-a.md): warm cream page, white cards with soft
// shadows, very round shapes, the Manrope font. Screens never type colours or
// radii themselves – they use the tokens here and the shared widgets in
// lib/core/widgets/.

/// The font of the whole app (bundled in assets/fonts/, licence in
/// Manrope-OFL.txt).
const appFontFamily = 'Manrope';

/// Numbers with equal widths, so "1.240" does not jump while it changes.
const tabularFigures = [FontFeature.tabularFigures()];

/// How long the calorie ring and the macro bars take to reach a new value.
const progressAnimationDuration = Duration(milliseconds: 700);

/// Short animations: the active tab pill, pressed cards, pills.
const shortAnimationDuration = Duration(milliseconds: 200);

/// Spacing steps. Use these instead of random numbers so the app looks even.
abstract final class Spacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Side padding of page headers (a bit more air than the cards).
  static const double page = 20;
}

/// Corner radii. The named ones say where they belong; `s`…`l` are general
/// steps for everything else.
abstract final class Radii {
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;

  /// Segment pills (equal widths in one row).
  static const double segment = 14;

  /// Text fields and the big icon squares (meal icons).
  static const double input = 16;

  /// Buttons and the rating tiles on the product page.
  static const double button = 22;

  /// White cards.
  static const double card = 24;

  /// Top corners of bottom sheets, dialogs.
  static const double sheet = 28;

  /// The camera area on the Scan tab and the scanner page.
  static const double camera = 28;

  /// The big summary card (Today, Profile).
  static const double summary = 30;

  /// Fully round ends (pills, chips, the navigation bar).
  static const double pill = 999;
}

/// Background and icon colour of one meal's icon square.
@immutable
class MealPalette {
  const MealPalette(this.background, this.icon);

  final Color background;
  final Color icon;

  static MealPalette lerp(MealPalette a, MealPalette b, double t) =>
      MealPalette(
        Color.lerp(a.background, b.background, t)!,
        Color.lerp(a.icon, b.icon, t)!,
      );
}

/// All colours of the app, for light and dark mode.
///
/// Text colours were chosen so they have at least 4.5:1 contrast on the
/// backgrounds they are used on (checked in test/core/theme_test.dart).
///
/// Rating colours are only an *extra* hint. The app always shows an icon and a
/// word as well, so colour-blind people get the same information. Going over
/// the daily goal (or the reference intake) is never shown in a rating or
/// error colour.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.track,
    required this.ink,
    required this.inkMuted,
    required this.border,
    required this.brand,
    required this.ringStart,
    required this.ringEnd,
    required this.cta,
    required this.onCta,
    required this.tonal,
    required this.onTonal,
    required this.navBar,
    required this.navInactive,
    required this.navActive,
    required this.onNavActive,
    required this.selected,
    required this.onSelected,
    required this.star,
    required this.snackAction,
    required this.shadow,
    required this.ratingLow,
    required this.ratingLowBg,
    required this.ratingMedium,
    required this.ratingMediumBg,
    required this.ratingHigh,
    required this.ratingHighBg,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealPalettes,
    required this.camera,
    required this.cameraScrim,
    required this.onCamera,
  });

  /// Warm cream page background behind cards.
  final Color background;

  /// Cards, sheets and dialogs.
  final Color surface;

  /// Text fields, unselected pills, rows inside sheets.
  final Color surfaceAlt;

  /// The empty part of the calorie ring and of the macro and week bars.
  final Color track;

  /// Main text and icons.
  final Color ink;

  /// Secondary text.
  final Color inkMuted;

  /// Thin lines: dividers, table rows (ink at 10 %).
  final Color border;

  /// The forest green: text buttons, focus border, plus points, selections.
  final Color brand;

  /// The two ends of the green gradient of the calorie ring (top left to
  /// bottom right); also today's bar in the statistics.
  final Color ringStart;
  final Color ringEnd;

  /// Main buttons ("Hinzufügen"), the "+" on meal cards.
  final Color cta;
  final Color onCta;

  /// Secondary buttons and the "Heute" pill.
  final Color tonal;
  final Color onTonal;

  /// The floating navigation bar and its icons that are not selected.
  final Color navBar;
  final Color navInactive;

  /// The pill of the selected tab and its icon/label.
  final Color navActive;
  final Color onNavActive;

  /// A selected pill or segment ("100 g", "Berechnen").
  final Color selected;
  final Color onSelected;

  /// The favourite star.
  final Color star;

  /// The "Rückgängig" button on a SnackBar (SnackBars use [cta] colours).
  final Color snackAction;

  /// Base colour of all shadows (alphas in the getters below); transparent
  /// in dark mode, where the surface colour alone sets cards apart.
  final Color shadow;

  /// Rating "niedrig": text/icon colour and its tile background.
  final Color ratingLow;
  final Color ratingLowBg;

  /// Rating "mittel".
  final Color ratingMedium;
  final Color ratingMediumBg;

  /// Rating "hoch".
  final Color ratingHigh;
  final Color ratingHighBg;

  /// Colours of the three macro nutrients (bars and dots).
  final Color protein;
  final Color carbs;
  final Color fat;

  /// Meal icon colours: peach, mint, lavender, butter, sky, rose. See
  /// `mealPaletteIndex` in the diary feature for which meal gets which.
  final List<MealPalette> mealPalettes;

  /// Behind the camera picture (until it arrives) on the Scan tab.
  final Color camera;

  /// The dark frame around the viewfinder and the pills on the camera
  /// picture (hint, torch). Dark enough that white text stays readable on
  /// any picture, even a white one.
  final Color cameraScrim;

  /// Text, icons and viewfinder corners on the camera picture.
  final Color onCamera;

  BoxShadow _shadow(double alpha, double blur, double y) => BoxShadow(
    color: shadow.withValues(alpha: shadow.a * alpha),
    blurRadius: blur,
    offset: Offset(0, y),
  );

  /// Soft shadow under white cards (none in dark mode).
  List<BoxShadow> get cardShadow => [_shadow(0.05, 18, 6)];

  /// A card while it is pressed: closer to the page, so a smaller shadow.
  List<BoxShadow> get pressedShadow => [_shadow(0.04, 8, 2)];

  /// The big summary card.
  List<BoxShadow> get summaryShadow => [_shadow(0.07, 30, 10)];

  /// Round white buttons and white info chips.
  List<BoxShadow> get buttonShadow => [_shadow(0.08, 12, 4)];

  /// The floating navigation bar.
  List<BoxShadow> get navShadow => [_shadow(0.25, 30, 12)];

  /// The green glow under the main button.
  List<BoxShadow> get ctaShadow => [
    BoxShadow(
      color: cta.withValues(alpha: shadow.a * 0.3),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // Colours with transparency are written as 0xAARRGGBB, e.g. ink at 10 %
  // = 0x1A17251E (0x1A = 26 = 10 % of 255).
  static const light = AppColors(
    background: Color(0xFFF6F3EC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF2F1EC),
    track: Color(0xFFEEF0EA),
    ink: Color(0xFF17251E),
    inkMuted: Color(0xFF5E6D64),
    border: Color(0x1A17251E),
    brand: Color(0xFF1F5C45),
    ringStart: Color(0xFF2E8B57),
    ringEnd: Color(0xFF9BD770),
    cta: Color(0xFF1F5C45),
    onCta: Color(0xFFFFFFFF),
    tonal: Color(0xFFDDF1E4),
    onTonal: Color(0xFF1D5E3A),
    navBar: Color(0xFF17251E),
    navInactive: Color(0xFF9DB3A6),
    navActive: Color(0xFFCFEBD9),
    onNavActive: Color(0xFF17251E),
    selected: Color(0xFF17251E),
    onSelected: Color(0xFFFFFFFF),
    star: Color(0xFFB7791F),
    snackAction: Color(0xFF9FE0B4),
    shadow: Color(0xFF17251E),
    ratingLow: Color(0xFF1D5E3A),
    ratingLowBg: Color(0xFFDDF1E4),
    ratingMedium: Color(0xFF7A5200),
    ratingMediumBg: Color(0xFFFBEFD3),
    ratingHigh: Color(0xFF8E2E17),
    ratingHighBg: Color(0xFFFBE4DC),
    protein: Color(0xFF5B8DEF),
    carbs: Color(0xFFF2B544),
    fat: Color(0xFFC78BE0),
    mealPalettes: [
      MealPalette(Color(0xFFFDEBD2), Color(0xFFA4521A)),
      MealPalette(Color(0xFFDDF1E4), Color(0xFF1F5C45)),
      MealPalette(Color(0xFFE6E2F7), Color(0xFF5B45B0)),
      MealPalette(Color(0xFFFFF2BF), Color(0xFF7A5E00)),
      MealPalette(Color(0xFFD8ECFF), Color(0xFF1F5FA8)),
      MealPalette(Color(0xFFFFE0EA), Color(0xFFA8325E)),
    ],
    camera: Color(0xFF17251E),
    cameraScrim: Color(0x99000000),
    onCamera: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    background: Color(0xFF131814),
    surface: Color(0xFF1D241F),
    surfaceAlt: Color(0xFF262E28),
    track: Color(0xFF2C352F),
    ink: Color(0xFFECEFE8),
    inkMuted: Color(0xFFA3B1A8),
    border: Color(0x1AECEFE8),
    brand: Color(0xFF8FD3AE),
    ringStart: Color(0xFF3FAE6A),
    ringEnd: Color(0xFFA8E07F),
    cta: Color(0xFF8FD3AE),
    onCta: Color(0xFF131814),
    tonal: Color(0xFF163A25),
    onTonal: Color(0xFF9FE0B4),
    navBar: Color(0xFF2A332D),
    navInactive: Color(0xFF9DB3A6),
    navActive: Color(0xFFCFEBD9),
    onNavActive: Color(0xFF17251E),
    selected: Color(0xFFECEFE8),
    onSelected: Color(0xFF131814),
    star: Color(0xFFF2C14E),
    snackAction: Color(0xFF0E4D2F),
    shadow: Color(0x00000000),
    ratingLow: Color(0xFF9FE0B4),
    ratingLowBg: Color(0xFF163A25),
    ratingMedium: Color(0xFFFFD98A),
    ratingMediumBg: Color(0xFF3F3412),
    ratingHigh: Color(0xFFFFB4A0),
    ratingHighBg: Color(0xFF4A2219),
    protein: Color(0xFF8AB8F0),
    carbs: Color(0xFFF2C14E),
    fat: Color(0xFFD7A6EB),
    mealPalettes: [
      MealPalette(Color(0xFF3A2A1F), Color(0xFFFFB98A)),
      MealPalette(Color(0xFF173626), Color(0xFF8EE0A8)),
      MealPalette(Color(0xFF2A2540), Color(0xFFC3B5FF)),
      MealPalette(Color(0xFF393117), Color(0xFFFFD966)),
      MealPalette(Color(0xFF16283D), Color(0xFF9CC8FF)),
      MealPalette(Color(0xFF3D1B28), Color(0xFFFFB0CB)),
    ],
    camera: Color(0xFF0B0F0C),
    cameraScrim: Color(0x99000000),
    onCamera: Color(0xFFFFFFFF),
  );

  /// The tokens are fixed per brightness; there is nothing to change.
  @override
  AppColors copyWith() => this;

  /// Smoothly blends light and dark when the theme mode changes.
  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      track: mix(track, other.track),
      ink: mix(ink, other.ink),
      inkMuted: mix(inkMuted, other.inkMuted),
      border: mix(border, other.border),
      brand: mix(brand, other.brand),
      ringStart: mix(ringStart, other.ringStart),
      ringEnd: mix(ringEnd, other.ringEnd),
      cta: mix(cta, other.cta),
      onCta: mix(onCta, other.onCta),
      tonal: mix(tonal, other.tonal),
      onTonal: mix(onTonal, other.onTonal),
      navBar: mix(navBar, other.navBar),
      navInactive: mix(navInactive, other.navInactive),
      navActive: mix(navActive, other.navActive),
      onNavActive: mix(onNavActive, other.onNavActive),
      selected: mix(selected, other.selected),
      onSelected: mix(onSelected, other.onSelected),
      star: mix(star, other.star),
      snackAction: mix(snackAction, other.snackAction),
      shadow: mix(shadow, other.shadow),
      ratingLow: mix(ratingLow, other.ratingLow),
      ratingLowBg: mix(ratingLowBg, other.ratingLowBg),
      ratingMedium: mix(ratingMedium, other.ratingMedium),
      ratingMediumBg: mix(ratingMediumBg, other.ratingMediumBg),
      ratingHigh: mix(ratingHigh, other.ratingHigh),
      ratingHighBg: mix(ratingHighBg, other.ratingHighBg),
      protein: mix(protein, other.protein),
      carbs: mix(carbs, other.carbs),
      fat: mix(fat, other.fat),
      mealPalettes: [
        for (var i = 0; i < mealPalettes.length; i++)
          MealPalette.lerp(
            mealPalettes[i],
            other.mealPalettes[math.min(i, other.mealPalettes.length - 1)],
            t,
          ),
      ],
      camera: mix(camera, other.camera),
      cameraScrim: mix(cameraScrim, other.cameraScrim),
      onCamera: mix(onCamera, other.onCamera),
    );
  }
}

/// The text styles of the app (all Manrope, numbers in design-a.md):
///
/// | Style          | Size/weight | Used for                            |
/// |----------------|-------------|-------------------------------------|
/// | headlineMedium | 30 / 800    | big numbers (calorie ring, goal)    |
/// | headlineSmall  | 26 / 800    | page and product titles             |
/// | titleLarge     | 20 / 800    | sub-page titles                     |
/// | titleMedium    | 18 / 800    | section titles, sheet titles        |
/// | titleSmall     | 15 / 800    | card titles, meal names             |
/// | bodyLarge      | 15 / 600    | body text, list rows, text fields   |
/// | bodyMedium     | 14 / 600    | default text                        |
/// | bodySmall      | 13 / 600    | secondary text (muted colour)       |
/// | labelLarge     | 15 / 800    | buttons                             |
/// | labelMedium    | 12 / 700    | small labels, overlines, chips      |
/// | labelSmall     | 11 / 700    | tiny captions                       |
TextTheme buildTextTheme(AppColors colors) {
  TextStyle style(
    double size,
    FontWeight weight, {
    Color? color,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: appFontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color ?? colors.ink,
    letterSpacing: letterSpacing,
  );
  const extraBold = FontWeight.w800;
  const bold = FontWeight.w700;
  const semiBold = FontWeight.w600;
  return TextTheme(
    displayLarge: style(48, extraBold),
    displayMedium: style(40, extraBold),
    displaySmall: style(36, extraBold),
    headlineLarge: style(32, extraBold),
    headlineMedium: style(
      30,
      extraBold,
      letterSpacing: -0.9,
    ).copyWith(fontFeatures: tabularFigures, height: 1.05),
    // −0.02em like the mock-up.
    headlineSmall: style(
      26,
      extraBold,
      letterSpacing: -0.52,
    ).copyWith(height: 1.15),
    titleLarge: style(20, extraBold),
    titleMedium: style(18, extraBold),
    titleSmall: style(15, extraBold),
    bodyLarge: style(15, semiBold),
    bodyMedium: style(14, semiBold),
    bodySmall: style(13, semiBold, color: colors.inkMuted),
    labelLarge: style(15, extraBold),
    labelMedium: style(12, bold),
    labelSmall: style(11, bold),
  );
}

/// Builds the light or dark theme of the app.
ThemeData buildTheme(Brightness brightness) {
  final colors = brightness == Brightness.light
      ? AppColors.light
      : AppColors.dark;
  final text = buildTextTheme(colors);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: colors.brand,
        brightness: brightness,
      ).copyWith(
        primary: colors.brand,
        onPrimary: brightness == Brightness.light
            ? colors.surface
            : colors.background,
        primaryContainer: colors.tonal,
        onPrimaryContainer: colors.onTonal,
        secondary: colors.brand,
        secondaryContainer: colors.tonal,
        onSecondaryContainer: colors.onTonal,
        surface: colors.surface,
        onSurface: colors.ink,
        onSurfaceVariant: colors.inkMuted,
        surfaceContainerLowest: colors.surface,
        surfaceContainerLow: colors.surface,
        surfaceContainer: colors.surfaceAlt,
        surfaceContainerHigh: colors.surfaceAlt,
        surfaceContainerHighest: colors.surfaceAlt,
        outline: colors.inkMuted,
        outlineVariant: colors.border,
        inverseSurface: colors.cta,
        onInverseSurface: colors.onCta,
        inversePrimary: colors.snackAction,
        surfaceTint: Colors.transparent,
      );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.button),
  );
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: Spacing.page,
    vertical: Spacing.m,
  );
  final buttonText = text.labelLarge;
  final sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Radii.sheet),
  );
  return ThemeData(
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: appFontFamily,
    textTheme: text,
    scaffoldBackgroundColor: colors.background,
    canvasColor: colors.surface,
    dividerColor: colors.border,
    splashFactory: InkRipple.splashFactory,
    splashColor: colors.ink.withValues(alpha: 0.06),
    highlightColor: colors.ink.withValues(alpha: 0.04),
    iconTheme: IconThemeData(color: colors.ink),
    extensions: [colors],
    // iOS-style sliding pages on every platform (not the Android zoom).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
      },
    ),
    // Rounded back arrow in every app bar (licence page, pickers).
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (_) => const Icon(Icons.arrow_back_rounded),
      closeButtonIconBuilder: (_) => const Icon(Icons.close_rounded),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.cta,
        foregroundColor: colors.onCta,
        disabledBackgroundColor: colors.ink.withValues(alpha: 0.12),
        disabledForegroundColor: colors.ink.withValues(alpha: 0.45),
        minimumSize: const Size(64, 48),
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.tonal,
        foregroundColor: colors.onTonal,
        elevation: 0,
        minimumSize: const Size(64, 48),
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.ink,
        backgroundColor: colors.surface,
        side: BorderSide(color: colors.border),
        minimumSize: const Size(64, 48),
        padding: buttonPadding,
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.brand,
        minimumSize: const Size(48, 48),
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: colors.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.l,
        vertical: Spacing.l,
      ),
      labelStyle: text.labelMedium!.copyWith(color: colors.inkMuted),
      floatingLabelStyle: text.labelMedium!.copyWith(color: colors.brand),
      hintStyle: text.bodyLarge!.copyWith(color: colors.inkMuted),
      suffixStyle: text.bodyLarge!.copyWith(
        fontWeight: FontWeight.w800,
        color: colors.inkMuted,
      ),
      prefixIconColor: colors.inkMuted,
      suffixIconColor: colors.inkMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide(color: colors.brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.input),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.surface
            : colors.inkMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.brand
            : colors.surfaceAlt,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? colors.brand
            : colors.border,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.inkMuted,
      titleTextStyle: text.bodyLarge!.copyWith(fontWeight: FontWeight.w800),
      subtitleTextStyle: text.bodySmall,
      leadingAndTrailingTextStyle: text.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.border, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.brand,
      linearTrackColor: colors.surfaceAlt,
      circularTrackColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: sheetShape,
      titleTextStyle: text.titleMedium,
      contentTextStyle: text.bodyMedium,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      modalBackgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: colors.ink.withValues(alpha: 0.2),
      dragHandleSize: const Size(40, 5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: sheetShape,
      headerHeadlineStyle: text.headlineSmall,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: colors.surface,
      shape: sheetShape,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
      textStyle: text.bodyLarge,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(textStyle: text.bodyLarge),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.cta,
      contentTextStyle: text.bodyMedium!.copyWith(color: colors.onCta),
      actionTextColor: colors.snackAction,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colors.cta,
        borderRadius: BorderRadius.circular(Radii.s),
      ),
      textStyle: text.labelMedium!.copyWith(color: colors.onCta),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.brand,
      selectionHandleColor: colors.brand,
      selectionColor: colors.brand.withValues(alpha: 0.3),
    ),
  );
}

/// Short access to the app colours: `context.appColors.ratingHigh`.
extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
