import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF5F8FD);
  static const Color backgroundAlt = Color(0xFFFFFCF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF3F7FC);
  static const Color surfaceMuted = Color(0xFFEEF3F9);
  static const Color primary = Color(0xFF184C98);
  static const Color primaryDeep = Color(0xFF0A214F);
  static const Color secondary = Color(0xFF22B3E6);
  static const Color secondarySoft = Color(0xFFDDF4FF);
  static const Color accent = Color(0xFF7787FF);
  static const Color accentSoft = Color(0xFFE8ECFF);
  static const Color blush = Color(0xFFF8E9E6);
  static const Color sand = Color(0xFFF7F0E9);
  static const Color stable = Color(0xFF3789A3);
  static const Color warning = Color(0xFFD8A047);
  static const Color danger = Color(0xFFE07279);
  static const Color textPrimary = Color(0xFF152440);
  static const Color textSecondary = Color(0xFF6D7A93);
  static const Color border = Color(0xFFE2EAF4);
  static const Color shadow = Color(0x14223857);

  static List<BoxShadow> get softShadow => [
        const BoxShadow(
          color: shadow,
          blurRadius: 28,
          offset: Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        const BoxShadow(
          color: shadow,
          blurRadius: 36,
          offset: Offset(0, 20),
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
          background,
          backgroundAlt,
          Color(0xFFF0F7FF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
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
          fontSize: 32,
          height: 1.06,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.1,
        ),
        headlineMedium: const TextStyle(
          fontSize: 26,
          height: 1.12,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.7,
        ),
        headlineSmall: const TextStyle(
          fontSize: 21,
          height: 1.18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleMedium: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 14,
          height: 1.52,
          color: textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 13,
          height: 1.42,
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
          backgroundColor: primaryDeep,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
          backgroundColor: Colors.white.withValues(alpha: 0.86),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
            borderRadius: BorderRadius.circular(16),
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
        fillColor: surfaceSoft,
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
