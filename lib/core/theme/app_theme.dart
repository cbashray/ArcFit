import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ArcFit Design System - Data-Dense & Functional
/// High information density, clear hierarchy, power-user focused
class AppTheme {
  // ══════════════════════════════════════════════════════════════════════════════
  // BACKWARD COMPATIBILITY ALIASES (for existing code)
  // ══════════════════════════════════════════════════════════════════════════════

  // Old color names mapped to new palette
  static const Color primaryGreen = Color(0xFF007A33);     // success
  static const Color accentOrange = Color(0xFFE65100);     // warning
  static const Color errorRed = Color(0xFFC62828);         // error
  static const Color secondaryBlue = Color(0xFF2D4A6B);    // primary
  static const Color primaryBlue = Color(0xFF2D4A6B);      // primary

  // ══════════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE - LIGHT
  // ══════════════════════════════════════════════════════════════════════════════

  // Primary - Deep Slate Blue (trust, focus, performance)
  static const Color primary = Color(0xFF2D4A6B);
  static const Color primaryLight = Color(0xFF4A6FA5);
  static const Color primaryDark = Color(0xFF1E344F);
  static const Color primaryContainer = Color(0xFFE8EEF5);
  static const Color onPrimaryContainer = Color(0xFF1E344F);

  // Secondary - Warm Amber (energy, progress, strength)
  static const Color secondary = Color(0xFFB8860B);
  static const Color secondaryLight = Color(0xFFD4A83C);
  static const Color secondaryContainer = Color(0xFFFFF3E0);
  static const Color onSecondaryContainer = Color(0xFF5D4000);

  // Accent - Emerald Green (success, completion, health)
  static const Color success = Color(0xFF007A33);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFE65100);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorContainer = Color(0xFFFDEDEC);

  // Neutrals - High contrast, readable
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE0E0E0);

  static const Color onBackground = Color(0xFF1A1A1A);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF424242);
  static const Color outline = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Shadows - Subtle, layered
  static const Color shadow = Color(0x0D000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowStrong = Color(0x1F000000);

  // ══════════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE - DARK
  // ══════════════════════════════════════════════════════════════════════════════

  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceVariant = Color(0xFF21262D);
  static const Color darkSurfaceContainer = Color(0xFF30363D);
  static const Color darkSurfaceContainerHigh = Color(0xFF484F58);

  static const Color darkOnBackground = Color(0xFFF0F6FC);
  static const Color darkOnSurface = Color(0xFFF0F6FC);
  static const Color darkOnSurfaceVariant = Color(0xFF8B949E);
  static const Color darkOutline = Color(0xFF30363D);
  static const Color darkOutlineVariant = Color(0xFF21262D);

  static const Color darkShadow = Color(0x33000000);
  static const Color darkShadowMedium = Color(0x4D000000);
  static const Color darkShadowStrong = Color(0x66000000);

  static const Color darkPrimary = Color(0xFF58A6FF);
  static const Color darkPrimaryLight = Color(0xFF79C0FF);
  static const Color darkPrimaryDark = Color(0xFF388BF8);
  static const Color darkPrimaryContainer = Color(0xFF1F3A5F);
  static const Color darkOnPrimaryContainer = Color(0xFFD0E8FF);
  static const Color darkSecondary = Color(0xFFD2A106);
  static const Color darkSecondaryContainer = Color(0xFF4D3E00);
  static const Color darkSuccess = Color(0xFF3FB950);
  static const Color darkWarning = Color(0xFFFFA657);
  static const Color darkError = Color(0xFFF85149);

  // ══════════════════════════════════════════════════════════════════════════════
  // BACKWARD COMPATIBILITY ALIASES - DARK
  // ══════════════════════════════════════════════════════════════════════════════

  static const Color darkPrimaryGreen = Color(0xFF3FB950);   // darkSuccess
  static const Color darkAccentOrange = Color(0xFFFFA657);   // darkWarning
  static const Color darkErrorRed = Color(0xFFF85149);       // darkError
  static const Color darkSecondaryBlue = Color(0xFF58A6FF);  // darkPrimary
  static const Color darkPrimaryBlue = Color(0xFF58A6FF);    // darkPrimary

  // ══════════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY - Space Grotesk (Display) + IBM Plex Sans (Body) + JetBrains Mono (Data)
  // ══════════════════════════════════════════════════════════════════════════════

  static TextTheme _buildTextTheme({required bool isDark}) {
    final displayBase = GoogleFonts.spaceGroteskTextTheme();
    final bodyBase = GoogleFonts.ibmPlexSansTextTheme();

    final fg = isDark ? darkOnBackground : onBackground;
    final fgMedium = isDark ? darkOnSurfaceVariant : onSurfaceVariant;
    final fgMuted = isDark ? Color(0xFF6E7681) : Color(0xFF757575);

    return bodyBase.copyWith(
      // ═══ DISPLAY - Space Grotesk ═══
      displayLarge: displayBase.displayLarge?.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: fg,
        height: 1.12,
      ),
      displayMedium: displayBase.displayMedium?.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: fg,
        height: 1.16,
      ),
      displaySmall: displayBase.displaySmall?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: fg,
        height: 1.22,
      ),

      // ═══ HEADLINE - Space Grotesk ═══
      headlineLarge: displayBase.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: fg,
        height: 1.25,
      ),
      headlineMedium: displayBase.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: fg,
        height: 1.29,
      ),
      headlineSmall: displayBase.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: fg,
        height: 1.33,
      ),

      // ═══ TITLE - Space Grotesk (Large) / IBM Plex Sans (Medium, Small) ═══
      titleLarge: displayBase.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: fg,
        height: 1.27,
      ),
      titleMedium: bodyBase.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: fg,
        height: 1.5,
      ),
      titleSmall: bodyBase.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: fgMedium,
        height: 1.43,
      ),

      // ═══ BODY - IBM Plex Sans ═══
      bodyLarge: bodyBase.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: fg,
        height: 1.5,
      ),
      bodyMedium: bodyBase.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: fgMedium,
        height: 1.43,
      ),
      bodySmall: bodyBase.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: fgMuted,
        height: 1.33,
      ),

      // ═══ LABEL - IBM Plex Sans ═══
      labelLarge: bodyBase.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: fg,
        height: 1.43,
      ),
      labelMedium: bodyBase.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: fgMedium,
        height: 1.33,
      ),
      labelSmall: bodyBase.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: fgMuted,
        height: 1.45,
      ),
    );
  }

  static TextTheme _buildDataTextTheme({required bool isDark}) {
    final fg = isDark ? darkOnBackground : onBackground;
    final fgMedium = isDark ? darkOnSurfaceVariant : onSurfaceVariant;
    final monoBase = GoogleFonts.jetBrainsMonoTextTheme(ThemeData.light().textTheme);

    return monoBase.copyWith(
      // ═══ DATA - JetBrains Mono (Tabular Figures) ═══
      displayLarge: monoBase.displayLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: fg,
        height: 1.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      displayMedium: monoBase.displayMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: fg,
        height: 1.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      displaySmall: monoBase.displaySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: fg,
        height: 1.54,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: monoBase.headlineMedium?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: fgMedium,
        height: 1.45,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // SPACING & RADIUS TOKENS
  // ══════════════════════════════════════════════════════════════════════════════

  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space7 = 28.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ══════════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    const brightness = Brightness.light;

    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: success,
      onTertiary: Colors.white,
      tertiaryContainer: successContainer,
      onTertiaryContainer: success,
      error: error,
      onError: Colors.white,
      errorContainer: errorContainer,
      onErrorContainer: error,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHigh,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: shadow,
    );

    final textTheme = _buildTextTheme(isDark: false);
    final dataTextTheme = _buildDataTextTheme(isDark: false);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,

      // ═══ APP BAR ═══
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onBackground,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: onBackground,
          letterSpacing: 0,
          height: 1.27,
        ),
        toolbarHeight: 56,
        actionsIconTheme: IconThemeData(
          size: 22,
          color: onSurfaceVariant,
        ),
      ),

      // ═══ CARDS ═══
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ═══ BUTTONS ═══
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: shadow,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.pressed)
                ? primaryDark.withValues(alpha: 0.3)
                : states.contains(WidgetState.hovered)
                    ? primaryDark.withValues(alpha: 0.1)
                    : null,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: outline, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered)
                ? primaryContainer
                : states.contains(WidgetState.pressed)
                    ? primaryContainer.withValues(alpha: 0.7)
                    : Colors.transparent,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered)
                ? primaryContainer
                : states.contains(WidgetState.pressed)
                    ? primaryContainer.withValues(alpha: 0.7)
                    : Colors.transparent,
          ),
        ),
      ),

      // ═══ INPUT FIELDS ═══
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: outlineVariant, width: 1),
        ),
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9E9E9E),
        ),
        floatingLabelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: primary,
        ),
        errorStyle: GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: error,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        alignLabelWithHint: true,
      ),

      // ═══ CHIPS ═══
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        disabledColor: surfaceContainerHigh,
        selectedColor: primaryContainer,
        secondarySelectedColor: primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurface,
          letterSpacing: 0.3,
        ),
        secondaryLabelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        brightness: brightness,
        elevation: 0,
        pressElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          side: BorderSide(color: outlineVariant, width: 1),
        ),
        side: BorderSide(color: outlineVariant, width: 1),
        showCheckmark: false,
      ),

      // ═══ DIVIDER ═══
      dividerTheme: DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 1,
        indent: 0,
        endIndent: 0,
      ),

      // ═══ LIST TILES ═══
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        tileColor: Colors.transparent,
        selectedTileColor: primaryContainer,
        iconColor: onSurfaceVariant,
        textColor: onSurface,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onSurface,
          height: 1.5,
        ),
        subtitleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
          height: 1.38,
        ),
        dense: true,
        horizontalTitleGap: 12,
        minLeadingWidth: 40,
      ),

      // ═══ NAVIGATION BAR ═══
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusSm)),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
        elevation: 0,
        shadowColor: shadow,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.ibmPlexSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ═══ BOTTOM SHEET ═══
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: shadowStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        modalBackgroundColor: surface,
        modalElevation: 0,
        modalBarrierColor: shadowStrong,
        constraints: BoxConstraints(minWidth: double.infinity),
      ),

      // ═══ DIALOG ═══
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: shadowStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        contentTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
      ),

      // ═══ SNACK BAR ═══
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurface.withValues(alpha: 0.9),
        contentTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ═══ FLOATING ACTION BUTTON ═══
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        extendedTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ═══ SEGMENTED BUTTON ═══
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.selected)
                ? primaryContainer
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.selected)
                ? primary
                : onSurfaceVariant,
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (states) => states.contains(WidgetState.selected)
                ? BorderSide(color: primary, width: 1.5)
                : BorderSide(color: outlineVariant, width: 1),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),

      // ═══ SWITCH ═══
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.grey.shade400,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.grey.shade300,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.hovered)
              ? primary.withValues(alpha: 0.1)
              : null,
        ),
      ),

      // ═══ CHECKBOX ═══
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXs)),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.hovered)
              ? primary.withValues(alpha: 0.1)
              : null,
        ),
      ),

      // ═══ RADIO ═══
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : onSurfaceVariant,
        ),
      ),

      // ═══ SLIDER ═══
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primaryContainer,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),

      // ═══ PROGRESS INDICATOR ═══
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primaryContainer,
        circularTrackColor: primaryContainer,
        linearMinHeight: 8,
        borderRadius: BorderRadius.circular(radiusFull),
      ),

      // ═══ TAB BAR ═══
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: onSurfaceVariant,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.hovered)
              ? primaryContainer
              : null,
        ),
      ),

      // ═══ TOOLTIP ═══
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(radiusXs),
        ),
        textStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        preferBelow: true,
        verticalOffset: 8,
        waitDuration: const Duration(milliseconds: 500),
      ),

      // ═══ EXTENSIONS - Custom theme extensions for data text ═══
      extensions: <ThemeExtension<dynamic>>[
        _DataTextThemeExtension(dataTextTheme),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ══════════════════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    const brightness = Brightness.dark;

    final colorScheme = ColorScheme.dark(
      primary: darkPrimary,
      onPrimary: darkBackground,
      primaryContainer: darkPrimaryContainer,
      onPrimaryContainer: darkOnPrimaryContainer,
      secondary: darkSecondary,
      onSecondary: darkBackground,
      secondaryContainer: darkSecondaryContainer,
      onSecondaryContainer: darkSecondaryContainer.computeLuminance() > 0.5 ? darkBackground : darkOnBackground,
      tertiary: darkSuccess,
      onTertiary: darkBackground,
      tertiaryContainer: Color(0xFF0D2818),
      onTertiaryContainer: darkSuccess,
      error: darkError,
      onError: darkBackground,
      errorContainer: Color(0xFF491110),
      onErrorContainer: darkError,
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerHighest: darkSurfaceContainerHigh,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,
      shadow: darkShadow,
      scrim: darkShadow,
    );

    final textTheme = _buildTextTheme(isDark: true);
    final dataTextTheme = _buildDataTextTheme(isDark: true);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme,
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,

      // ═══ APP BAR ═══
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkOnBackground,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: darkOnBackground,
          letterSpacing: 0,
          height: 1.27,
        ),
        toolbarHeight: 56,
        actionsIconTheme: IconThemeData(
          size: 22,
          color: darkOnSurfaceVariant,
        ),
      ),

      // ═══ CARDS ═══
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: darkShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: darkOutlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ═══ BUTTONS ═══
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkBackground,
          elevation: 0,
          shadowColor: darkShadow,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.pressed)
                ? darkPrimaryDark.withValues(alpha: 0.3)
                : states.contains(WidgetState.hovered)
                    ? darkPrimaryDark.withValues(alpha: 0.1)
                    : null,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: BorderSide(color: darkOutline, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered)
                ? darkPrimaryContainer
                : states.contains(WidgetState.pressed)
                    ? darkPrimaryContainer.withValues(alpha: 0.7)
                    : Colors.transparent,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered)
                ? darkPrimaryContainer
                : states.contains(WidgetState.pressed)
                    ? darkPrimaryContainer.withValues(alpha: 0.7)
                    : Colors.transparent,
          ),
        ),
      ),

      // ═══ INPUT FIELDS ═══
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: darkOutlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: darkOutlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: darkError, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: darkOutlineVariant, width: 1),
        ),
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkOnSurfaceVariant,
        ),
        hintStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6E7681),
        ),
        floatingLabelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkPrimary,
        ),
        errorStyle: GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: darkError,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        alignLabelWithHint: true,
      ),

      // ═══ CHIPS ═══
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceContainer,
        disabledColor: darkSurfaceContainerHigh,
        selectedColor: darkPrimaryContainer,
        secondarySelectedColor: darkPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
          letterSpacing: 0.3,
        ),
        secondaryLabelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkBackground,
        ),
        brightness: brightness,
        elevation: 0,
        pressElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          side: BorderSide(color: darkOutlineVariant, width: 1),
        ),
        side: BorderSide(color: darkOutlineVariant, width: 1),
        showCheckmark: false,
      ),

      // ═══ DIVIDER ═══
      dividerTheme: DividerThemeData(
        color: darkOutlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ═══ LIST TILES ═══
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        tileColor: Colors.transparent,
        selectedTileColor: darkPrimaryContainer,
        iconColor: darkOnSurfaceVariant,
        textColor: darkOnSurface,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
          height: 1.5,
        ),
        subtitleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: darkOnSurfaceVariant,
          height: 1.38,
        ),
        dense: true,
        horizontalTitleGap: 12,
        minLeadingWidth: 40,
      ),

      // ═══ NAVIGATION BAR ═══
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        indicatorColor: darkPrimaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusSm)),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
        elevation: 0,
        shadowColor: darkShadow,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.ibmPlexSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // ═══ BOTTOM SHEET ═══
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: darkShadowStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
        modalBackgroundColor: darkSurface,
        modalElevation: 0,
        modalBarrierColor: darkShadowStrong,
        constraints: BoxConstraints(minWidth: double.infinity),
      ),

      // ═══ DIALOG ═══
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: darkShadowStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXl)),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
        ),
        contentTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: darkOnSurfaceVariant,
        ),
      ),

      // ═══ SNACK BAR ═══
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkOnSurface.withValues(alpha: 0.9),
        contentTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkBackground,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ═══ FLOATING ACTION BUTTON ═══
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: darkBackground,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        extendedTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ═══ SEGMENTED BUTTON ═══
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.selected)
                ? darkPrimaryContainer
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.selected)
                ? darkPrimary
                : darkOnSurfaceVariant,
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>(
            (states) => states.contains(WidgetState.selected)
                ? BorderSide(color: darkPrimary, width: 1.5)
                : BorderSide(color: darkOutlineVariant, width: 1),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),

      // ═══ SWITCH ═══
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.grey.shade400,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? darkPrimary
              : darkSurfaceContainerHigh,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? darkPrimary
              : Colors.transparent,
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.hovered)
              ? darkPrimary.withValues(alpha: 0.1)
              : null,
        ),
      ),

      // ═══ CHECKBOX ═══
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? darkPrimary
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(darkBackground),
        side: BorderSide(color: darkOutline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusXs)),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.hovered)
              ? darkPrimary.withValues(alpha: 0.1)
              : null,
        ),
      ),

      // ═══ RADIO ═══
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.selected)
              ? darkPrimary
              : darkOnSurfaceVariant,
        ),
      ),

      // ═══ SLIDER ═══
      sliderTheme: SliderThemeData(
        activeTrackColor: darkPrimary,
        inactiveTrackColor: darkPrimaryContainer,
        thumbColor: darkPrimary,
        overlayColor: darkPrimary.withValues(alpha: 0.12),
        valueIndicatorColor: darkPrimary,
        valueIndicatorTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkBackground,
        ),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),

      // ═══ PROGRESS INDICATOR ═══
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: darkPrimary,
        linearTrackColor: darkPrimaryContainer,
        circularTrackColor: darkPrimaryContainer,
        linearMinHeight: 8,
        borderRadius: BorderRadius.circular(radiusFull),
      ),

      // ═══ TAB BAR ═══
      tabBarTheme: TabBarThemeData(
        labelColor: darkPrimary,
        unselectedLabelColor: darkOnSurfaceVariant,
        indicatorColor: darkPrimary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.hovered)
              ? darkPrimaryContainer
              : null,
        ),
      ),

      // ═══ TOOLTIP ═══
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: darkOnSurface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(radiusXs),
        ),
        textStyle: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkBackground,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        preferBelow: true,
        verticalOffset: 8,
        waitDuration: const Duration(milliseconds: 500),
      ),

      // ═══ EXTENSIONS ═══
      extensions: <ThemeExtension<dynamic>>[
        _DataTextThemeExtension(dataTextTheme),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// THEME EXTENSIONS
// ══════════════════════════════════════════════════════════════════════════════

class _DataTextThemeExtension extends ThemeExtension<_DataTextThemeExtension> {
  final TextTheme dataTextTheme;

  const _DataTextThemeExtension(this.dataTextTheme);

  @override
  _DataTextThemeExtension copyWith({TextTheme? dataTextTheme}) {
    return _DataTextThemeExtension(dataTextTheme ?? this.dataTextTheme);
  }

  @override
  _DataTextThemeExtension lerp(ThemeExtension<_DataTextThemeExtension>? other, double t) {
    if (other is! _DataTextThemeExtension) return this;
    return _DataTextThemeExtension(TextTheme.lerp(dataTextTheme, other.dataTextTheme, t));
  }
}

extension DataTextTheme on BuildContext {
  TextTheme get dataTextTheme => Theme.of(this).extension<_DataTextThemeExtension>()?.dataTextTheme ?? Theme.of(this).textTheme;
}