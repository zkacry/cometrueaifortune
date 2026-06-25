import 'package:flutter/material.dart';

enum ThemeMode { light, dark }

class AppTheme {
  // Dark theme colors
  static const _darkBackground = Color(0xFF0A0A14);
  static const _darkSurface = Color(0xFF13131F);
  static const _darkCard = Color(0xFF1C1C2E);
  static const _darkTextPrimary = Color(0xFFF0EEF8);
  static const _darkTextSecondary = Color(0xFF8A87A0);
  static const _darkDivider = Color(0xFF2A2A40);

  // Light theme colors
  static const _lightBackground = Color(0xFFFAF9FB);
  static const _lightSurface = Color(0xFFF5F3F8);
  static const _lightCard = Color(0xFFFFFFFF);
  static const _lightTextPrimary = Color(0xFF1A1A2E);
  static const _lightTextSecondary = Color(0xFF666680);
  static const _lightDivider = Color(0xFFE0DCEB);

  static const accent = Color(0xFF9C7FE0); // パープル
  static const accentGold = Color(0xFFD4AF37);
  static const accentRose = Color(0xFFE070A0);
  static const success = Color(0xFF4CAF8A);
  static const error = Color(0xFFE05050);

  // Plan colors
  static const freePlan = Color(0xFF607090);
  static const lightPlan = Color(0xFF9C7FE0);
  static const proPlan = Color(0xFFD4AF37);

  // Typography
  static const headingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.5,
  );

  static const bodyMediumStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );

  static const bodySmallStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  static const labelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Spacing constants
  static const spacingXS = 4.0;
  static const spacingS = 8.0;
  static const spacingM = 12.0;
  static const spacingL = 16.0;
  static const spacingXL = 20.0;
  static const spacing2XL = 24.0;

  // Border radius constants
  static const radiusS = 6.0;
  static const radiusM = 12.0;
  static const radiusL = 16.0;
  static const radiusXL = 20.0;

  // Dark theme colors (for backward compatibility)
  static const background = _darkBackground;
  static const surface = _darkSurface;
  static const card = _darkCard;
  static const textPrimary = _darkTextPrimary;
  static const textSecondary = _darkTextSecondary;
  static const divider = _darkDivider;

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.dark(
          primary: accent,
          secondary: accentGold,
          surface: surface,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 16,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          hintStyle: TextStyle(color: textSecondary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: accent),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: accent.withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(color: textSecondary, fontSize: 12),
          ),
        ),
        dividerTheme: DividerThemeData(color: divider, thickness: 1),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textPrimary),
          bodySmall: TextStyle(color: textSecondary),
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: _lightBackground,
        colorScheme: const ColorScheme.light(
          primary: accent,
          secondary: accentGold,
          surface: _lightSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: _lightTextPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _lightBackground,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: _lightTextPrimary,
            fontSize: 16,
            letterSpacing: 3,
            fontWeight: FontWeight.w300,
          ),
          iconTheme: IconThemeData(color: _lightTextPrimary),
        ),
        cardTheme: const CardThemeData(
          color: _lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32)),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _lightSurface,
          hintStyle: const TextStyle(color: _lightTextSecondary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _lightDivider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: accent),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _lightSurface,
          indicatorColor: accent.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: _lightTextSecondary, fontSize: 12),
          ),
        ),
        dividerTheme: const DividerThemeData(color: _lightDivider, thickness: 1),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: _lightTextPrimary),
          bodyMedium: TextStyle(color: _lightTextPrimary),
          bodySmall: TextStyle(color: _lightTextSecondary),
        ),
      );
}
