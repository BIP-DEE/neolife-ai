import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF4F7FC);
  static const Color backgroundAlt = Color(0xFFFBFCFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF6F8FC);
  static const Color surfaceMuted = Color(0xFFEEF2F8);
  static const Color primary = Color(0xFF1A4FA7);
  static const Color primaryDeep = Color(0xFF0A214F);
  static const Color secondary = Color(0xFF1FB4DA);
  static const Color secondarySoft = Color(0xFFDDF5FB);
  static const Color accent = Color(0xFF6F82FF);
  static const Color accentSoft = Color(0xFFE9ECFF);
  static const Color blush = Color(0xFFF7EDEC);
  static const Color sand = Color(0xFFFBF4EB);
  static const Color stable = Color(0xFF2F8CA8);
  static const Color warning = Color(0xFFD8A047);
  static const Color danger = Color(0xFFE07279);
  static const Color textPrimary = Color(0xFF152440);
  static const Color textSecondary = Color(0xFF5B6982);
  static const Color border = Color(0xFFDCE4F0);
  static const Color shadow = Color(0x12223857);

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 720;

  static EdgeInsets panelPadding(
    BuildContext context, {
    double phone = 16,
    double regular = 20,
  }) {
    return EdgeInsets.all(isPhone(context) ? phone : regular);
  }

  static double panelRadius(
    BuildContext context, {
    double phone = 24,
    double regular = 30,
  }) {
    return isPhone(context) ? phone : regular;
  }

  static double sectionGap(
    BuildContext context, {
    double phone = 18,
    double regular = 24,
  }) {
    return isPhone(context) ? phone : regular;
  }

  static List<BoxShadow> get softShadow => [
        const BoxShadow(
          color: shadow,
          blurRadius: 28,
          offset: Offset(0, 14),
        ),
        const BoxShadow(
          color: Color(0x08FFFFFF),
          blurRadius: 10,
          offset: Offset(0, -2),
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        const BoxShadow(
          color: shadow,
          blurRadius: 42,
          offset: Offset(0, 24),
        ),
      ];

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [
          primaryDeep,
          primary,
          secondary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get ambientGradient => const LinearGradient(
        colors: [
          Color(0xFFF7FBFF),
          Color(0xFFF2F7FF),
          backgroundAlt,
          Color(0xFFF8F3FF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get panelGradient => LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.99),
          const Color(0xFFF8FBFF).withValues(alpha: 0.98),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primaryDeep,
        secondary: secondary,
        surface: surface,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      dividerColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        margin: EdgeInsets.zero,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: border),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(
          fontSize: 34,
          height: 1.06,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.2,
        ),
        headlineMedium: const TextStyle(
          fontSize: 27,
          height: 1.14,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.8,
        ),
        headlineSmall: const TextStyle(
          fontSize: 22,
          height: 1.18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.35,
        ),
        titleMedium: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 14.5,
          height: 1.56,
          color: textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 13.5,
          height: 1.48,
          color: textSecondary,
        ),
        labelLarge: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          shadowColor: primary.withValues(alpha: 0.18),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDeep,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: primaryDeep,
          backgroundColor: Colors.white.withValues(alpha: 0.88),
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.white.withValues(alpha: 0.86),
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      switchTheme: base.switchTheme.copyWith(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryDeep;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return secondarySoft;
          }
          return border;
        }),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        iconColor: primary,
        titleTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        subtitleTextStyle: const TextStyle(
          fontSize: 13,
          height: 1.4,
          color: textSecondary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: surfaceSoft,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? textPrimary
                : textSecondary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
    );
  }
}
