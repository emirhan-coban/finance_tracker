import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from Design
  static const Color primaryColor = Color.fromARGB(
    255,
    19,
    109,
    236,
  ); // Vibrant Blue
  static const Color backgroundDark = Color(0xFF000000); // Deep Black
  static const Color surfaceDark = Color(0xFF1C1C1E); // iOS System Gray 6
  static const Color borderDark = Color(0xFF2C2C2E);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color fieldDark = Color(0xFF1C1C1E);

  // Text Styles
  static TextStyle get displayFont => GoogleFonts.inter();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceDark,
        onSurface: textWhite,
        background: backgroundDark,
        secondary: primaryColor,
        outline: borderDark,
        surfaceContainerHighest: fieldDark,
        onSurfaceVariant: textSecondary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textWhite, displayColor: textWhite),
      iconTheme: const IconThemeData(color: textWhite),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldDark,
        hintStyle: const TextStyle(color: textMuted),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: borderDark),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: borderDark),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
