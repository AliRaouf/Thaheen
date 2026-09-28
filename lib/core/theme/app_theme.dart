import 'package:flutter/material.dart';

// Fonts: Sahel for headings, IBM Plex Sans Arabic for everything else.

const _sahel = 'Sahel';
const _ibmPlexSansArabic = 'IBMPlexSansArabic';

abstract class Space {
  static const spacing4 = 4.0;
  static const spacing8 = 8.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing20 = 20.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;
  static const spacing40 = 40.0;
}

abstract class Radii {
  static const small4 = 4.0;
  static const medium8 = 8.0;
  static const large14 = 14.0;
  static const pill = 9999.0;
}

TextStyle _style(
  String family,
  double size,
  double lineHeight,
  FontWeight weight,
) => TextStyle(
  fontFamily: family,
  fontFamilyFallback: family == _sahel ? const [_ibmPlexSansArabic] : null,
  fontSize: size,
  height: lineHeight / size,
  fontWeight: weight,
);

abstract class ThaheenText {
  // Display (Sahel)
  static final display = _style(_sahel, 30, 42, FontWeight.w700);
  static final titleLg = _style(_sahel, 24, 34, FontWeight.w700);
  static final title = _style(_sahel, 20, 30, FontWeight.w700);
  static final titleSm = _style(_sahel, 17, 26, FontWeight.w600);
  // Text (IBM Plex Sans Arabic)
  static final cardTitle = _style(_ibmPlexSansArabic, 16, 26, FontWeight.w600);
  static final body = _style(_ibmPlexSansArabic, 15, 25, FontWeight.w400);
  static final bodySm = _style(_ibmPlexSansArabic, 14, 22, FontWeight.w400);
  static final label = _style(_ibmPlexSansArabic, 14, 20, FontWeight.w500);
  static final labelLg = _style(_ibmPlexSansArabic, 18, 24, FontWeight.w700);
  static final caption = _style(_ibmPlexSansArabic, 12, 18, FontWeight.w500);
  static final numeric = _style(
    _ibmPlexSansArabic,
    13,
    18,
    FontWeight.w500,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static final textTheme = TextTheme(
    displaySmall: display,
    headlineSmall: titleLg,
    titleLarge: title,
    titleMedium: titleSm,
    titleSmall: cardTitle,
    bodyLarge: body,
    bodyMedium: bodySm,
    labelLarge: label,
    labelMedium: numeric,
    labelSmall: caption,
  );
}

@immutable
class ThaheenColors extends ThemeExtension<ThaheenColors> {
  const ThaheenColors({
    required this.bg,
    required this.surface,
    required this.surfaceSunken,
    required this.surfaceTint,
    required this.line,
    required this.lineStrong,
    required this.ink,
    required this.inkSecondary,
    required this.inkSubtle,
    required this.inkDisabled,
    required this.title,
    required this.brand,
    required this.primary,
    required this.onPrimary,
    required this.success,
    required this.successStrong,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.playerStage,
    required this.scrim,
    required this.onScrim,
    required this.snackbar,
    required this.onSnackbar,
    required this.shadowCard,
    required this.shadowBar,
    required this.shadowGlow,
  });

  final Color bg;
  final Color surface;
  final Color surfaceSunken;
  final Color surfaceTint;
  final Color line;
  final Color lineStrong;
  final Color ink;
  final Color inkSecondary;
  final Color inkSubtle;
  final Color inkDisabled;
  final Color title;
  final Color brand;
  final Color primary;
  final Color onPrimary;
  final Color success;
  final Color successStrong;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color playerStage;
  final Color scrim;
  final Color onScrim;
  final Color snackbar;
  final Color onSnackbar;
  final List<BoxShadow> shadowCard;
  final List<BoxShadow> shadowBar;
  final List<BoxShadow> shadowGlow;

  static const light = ThaheenColors(
    bg: Color(0xFFF8F8FF),
    surface: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFF0F0F0),
    surfaceTint: Color(0xFFEEF3FE),
    line: Color(0xFFF0F0F0),
    lineStrong: Color(0xFFEBEBEB),
    ink: Color(0xFF333333),
    inkSecondary: Color(0xFF5C5C5C),
    inkSubtle: Color(0xFF787878),
    inkDisabled: Color(0xFF8A8A8A),
    title: Color(0xFF1E4B8F),
    brand: Color(0xFF2395F8),
    primary: Color(0xFF047ABE),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF37A471),
    successStrong: Color(0xFF237A52),
    successSoft: Color(0xFFEAF6F0),
    danger: Color(0xFFC43D3D),
    dangerSoft: Color(0xFFFDECEC),
    playerStage: Color(0xFF0B0F17),
    scrim: Color(0x8C080C14),
    onScrim: Color(0xFFFFFFFF),
    snackbar: Color(0xFF1E2533),
    onSnackbar: Color(0xFFFFFFFF),
    shadowCard: [
      BoxShadow(color: Color(0x26252C61), offset: Offset(0, 5), blurRadius: 15),
      BoxShadow(color: Color(0x335D6494), offset: Offset(0, 2), blurRadius: 4),
    ],
    shadowBar: [
      BoxShadow(color: Color(0x40000000), offset: Offset(0, -1), blurRadius: 4),
    ],
    shadowGlow: [
      BoxShadow(color: Color(0xFF047ABE), blurRadius: 10),
      BoxShadow(color: Color(0xFF047ABE), blurRadius: 5),
    ],
  );

  static const dark = ThaheenColors(
    bg: Color(0xFF0E1420),
    surface: Color(0xFF161D2B),
    surfaceSunken: Color(0xFF1F2A3D),
    surfaceTint: Color(0xFF16263F),
    line: Color(0xFF2A3549),
    lineStrong: Color(0xFF34405A),
    ink: Color(0xFFE8EDF6),
    inkSecondary: Color(0xFFAAB4C6),
    inkSubtle: Color(0xFF8791A4),
    inkDisabled: Color(0xFF5F6A7D),
    title: Color(0xFF8FB6F0),
    brand: Color(0xFF4AA8FF),
    primary: Color(0xFF4AA8FF),
    onPrimary: Color(0xFF0A2540),
    success: Color(0xFF4CC08A),
    successStrong: Color(0xFF4CC08A),
    successSoft: Color(0xFF15302A),
    danger: Color(0xFFFF8A7A),
    dangerSoft: Color(0xFF3A1D1F),
    playerStage: Color(0xFF05070B),
    scrim: Color(0x99000000),
    onScrim: Color(0xFFFFFFFF),
    snackbar: Color(0xFFE8EDF6),
    onSnackbar: Color(0xFF0E1420),
    shadowCard: [
      BoxShadow(color: Color(0x73000000), offset: Offset(0, 5), blurRadius: 15),
      BoxShadow(color: Color(0x59000000), offset: Offset(0, 2), blurRadius: 4),
    ],
    shadowBar: [
      BoxShadow(color: Color(0x99000000), offset: Offset(0, -1), blurRadius: 4),
    ],
    shadowGlow: [
      BoxShadow(color: Color(0xFF6BB5FF), blurRadius: 10),
      BoxShadow(color: Color(0xFF6BB5FF), blurRadius: 5),
    ],
  );

  // ThemeExtension requires these two. The app never copies a palette, and
  // switching themes just swaps palettes halfway through Material's fade.
  @override
  ThaheenColors copyWith() => this;

  @override
  ThaheenColors lerp(ThaheenColors? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

extension ThaheenThemeX on BuildContext {
  ThaheenColors get colors => Theme.of(this).extension<ThaheenColors>()!;
}

abstract class ThaheenTheme {
  static final light = _build(ThaheenColors.light, Brightness.light);
  static final dark = _build(ThaheenColors.dark, Brightness.dark);

  /// The one large primary button on a screen (`lg` Button).
  static final largeButton = FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    padding: const EdgeInsets.symmetric(horizontal: Space.spacing24),
    textStyle: ThaheenText.labelLg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.medium8),
    ),
  );

  static ThemeData _build(ThaheenColors color, Brightness brightness) {
    RoundedRectangleBorder rounded(
      double r, [
      BorderSide side = BorderSide.none,
    ]) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(r),
      side: side,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _ibmPlexSansArabic,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: color.primary,
        onPrimary: color.onPrimary,
        secondary: color.brand,
        onSecondary: color.onPrimary,
        secondaryContainer:
            color.surfaceSunken, // FilledButton.tonal = "secondary" button
        onSecondaryContainer: color.ink,
        tertiary: color.success,
        onTertiary: color.onPrimary,
        error: color.danger,
        onError: color.bg,
        errorContainer: color.dangerSoft,
        onErrorContainer: color.danger,
        surface: color.surface,
        onSurface: color.ink,
        onSurfaceVariant: color.inkSecondary,
        surfaceContainerHighest: color.surfaceSunken,
        outline: color.lineStrong,
        outlineVariant: color.line,
        inverseSurface: color.snackbar,
        onInverseSurface: color.onSnackbar,
        surfaceTint: Colors.transparent,
      ),
      scaffoldBackgroundColor: color.bg,
      textTheme: ThaheenText.textTheme.apply(
        bodyColor: color.ink,
        displayColor: color.ink,
      ),
      extensions: [color],
      appBarTheme: AppBarTheme(
        backgroundColor: color.surface,
        foregroundColor: color.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: ThaheenText.titleLg.copyWith(color: color.ink),
        shape: Border(bottom: BorderSide(color: color.line)),
      ),
      cardTheme: CardThemeData(
        color: color.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: rounded(Radii.small4, BorderSide(color: color.line)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(42, 42),
          padding: const EdgeInsets.symmetric(horizontal: Space.spacing20),
          textStyle: ThaheenText.label,
          shape: rounded(Radii.small4),
          disabledBackgroundColor: color.surfaceSunken,
          disabledForegroundColor: color.inkDisabled,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: color.primary,
          minimumSize: const Size(42, 42),
          padding: const EdgeInsets.symmetric(horizontal: Space.spacing8),
          textStyle: ThaheenText.label,
          shape: rounded(Radii.small4),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: color.lineStrong,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: color.brand,
        linearTrackColor: color.surfaceTint,
        linearMinHeight: 6,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: color.snackbar,
        contentTextStyle: ThaheenText.body.copyWith(color: color.onSnackbar),
        actionTextColor: color.onSnackbar,
        behavior: SnackBarBehavior.floating,
        shape: rounded(Radii.medium8),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: color.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Radii.large14),
          ),
        ),
      ),
    );
  }
}
