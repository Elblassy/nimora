import 'package:flutter/material.dart';

const String _fontFamily = 'Fredoka';

class AppTheme {
  // Night sky palette
  static const Color primary = Color(0xFFFF6B6B);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color accent = Color(0xFFFFD93D);

  // Background colors (dark sky)
  static const Color background = Colors.transparent; // screens are transparent over animated bg
  static const Color skyDeep = Color(0xFF1F1843);
  static const Color skyBlue = Color(0xFF3778AC);
  static const Color skyPurple = Color(0xFF693C72);

  // Surface colors for cards/forms on dark bg
  static const Color surface = Color(0x33FFFFFF); // translucent white
  static const Color surfaceSolid = Color(0xFF1E2A4A); // solid dark card
  static const Color storyBackground = Color(0x22FFFFFF);

  // Text on dark background
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFFB0B8CC);

  // Star gold
  static const Color starGold = Color(0xFFFBE1B6);

  static ThemeData get theme {
    final base = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surfaceSolid,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          color: textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x22FFFFFF),
        hintStyle: const TextStyle(color: Color(0x88FFFFFF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: secondary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceSolid,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
