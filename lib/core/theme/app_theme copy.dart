// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const _primary = Color(0xFF6EE7F2); // aqua
  static const _secondary = Color(0xFFB794F4); // lavender
  static const _tertiary = Color(0xFFFFC857); // warm accent
  static const _error = Color(0xFFFF6B6B);

  // Dark surfaces
  static const _bg = Color(0xFF0F1115); // page background
  static const _surface = Color(0xFF171A21); // cards / panels
  static const _outline = Color(0x22FFFFFF); // soft borders

  // Light surfaces
  static const _bgLight = Color(0xFFF7F8FB);
  static const _surfaceLight = Color(0xFFFFFFFF);
  static const _outlineLight = Color(0x11000000);

  /// Use this in MaterialApp: theme: AppTheme.dark()
  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: _primary,
        onPrimary: Colors.black,
        secondary: _secondary,
        onSecondary: Colors.black,
        tertiary: _tertiary,
        onTertiary: Colors.black,
        error: _error,
        onError: Colors.white,
        background: _bg,
        onBackground: Colors.white,
        surface: _surface,
        onSurface: Colors.white,
      ),
    );

    return base.copyWith(
      // Typography
      textTheme: _textTheme(base.textTheme, isDark: true),

      // AppBar (glass-friendly, low elevation)
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),

      // Cards (rounded, no hard elevation; we add shadows in widgets when needed)
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.all(0),
      ),

      // Inputs (rounded, filled)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(.05),
        hintStyle: const TextStyle(color: Colors.white54),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary),
        ),
      ),

      // Chips (used for filters, mobility, categories)
      chipTheme: base.chipTheme.copyWith(
        shape: StadiumBorder(side: const BorderSide(color: _outline)),
        backgroundColor: Colors.white.withOpacity(.05),
        selectedColor: _primary.withOpacity(.18),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        iconTheme: const IconThemeData(size: 16),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _surface,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: _outline),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      // Bottom sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _surface.withOpacity(.92),
        modalBackgroundColor: _surface.withOpacity(.96),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Dividers / outlines
      dividerTheme: const DividerThemeData(
        color: _outline,
        thickness: 1,
        space: 1,
      ),

      // SnackBars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white.withOpacity(.06),
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white70,
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // Navigation bar (if you use Material3 default nav bars anywhere)
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: Color(0x336EE7F2),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  /// Optional light theme (keeps brand identity).
  static ThemeData light() {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: _bgLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _primary,
        onPrimary: Colors.black,
        secondary: _secondary,
        onSecondary: Colors.black,
        tertiary: _tertiary,
        onTertiary: Colors.black,
        error: _error,
        onError: Colors.white,
        background: _bgLight,
        onBackground: Colors.black,
        surface: _surfaceLight,
        onSurface: Colors.black,
      ),
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, isDark: false),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
      cardTheme: CardThemeData(
        color: _surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
        hintStyle: const TextStyle(color: Colors.black54),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: StadiumBorder(side: const BorderSide(color: _outlineLight)),
        backgroundColor: const Color(0xFFF2F4F7),
        selectedColor: _primary.withOpacity(.15),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: _outlineLight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black.withOpacity(.85),
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.black54,
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }

  // ---------- Typography helpers ----------

  static TextTheme _textTheme(TextTheme base, {required bool isDark}) {
    final onColor = isDark ? Colors.white : Colors.black;
    final onSubtle = isDark ? Colors.white70 : Colors.black54;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: onColor),
      displayMedium: base.displayMedium?.copyWith(color: onColor),
      displaySmall: base.displaySmall?.copyWith(color: onColor),
      headlineLarge: base.headlineLarge?.copyWith(
        color: onColor,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: onColor,
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: onColor,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: onColor,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: onColor,
        fontWeight: FontWeight.w800,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: onColor,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: onColor),
      bodyMedium: base.bodyMedium?.copyWith(color: onColor),
      bodySmall: base.bodySmall?.copyWith(color: onSubtle),
      labelLarge: base.labelLarge?.copyWith(
        color: onColor,
        fontWeight: FontWeight.w800,
        letterSpacing: .2,
      ),
      labelMedium: base.labelMedium?.copyWith(color: onSubtle),
      labelSmall: base.labelSmall?.copyWith(color: onSubtle),
    );
  }
}
