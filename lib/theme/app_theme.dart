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
  static const Color surfaceDark = Color(0xFF18181B); // Zinc 900
  static const Color surfaceLight = Color(0xFF27272A); // Zinc 800

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF4F4F5); // Zinc 100
  static const Color surfaceLightMode = Color(0xFFFFFFFF); // White
  static const Color textBlack = Color(0xFF18181B); // Zinc 900
  static const Color textGray = Color(0xFF52525B); // Zinc 600
  static const Color borderLight = Color(0xFFE4E4E7); // Zinc 200
  static const Color fieldLight = Color(0xFFF4F4F5); // Zinc 100

  // Gradient Colors
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D6AEE), // Bright Blue
      Color(0xFF8B5CF6), // Violet
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF18181B), Color(0xFF27272A)],
  );
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
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textWhite,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dividerTheme: DividerThemeData(color: borderDark),
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

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        surface: surfaceLightMode,
        onSurface: textBlack,
        background: backgroundLight,
        secondary: primaryColor,
        outline: borderLight,
        surfaceContainerHighest: fieldLight,
        onSurfaceVariant: textGray,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: textBlack, displayColor: textBlack),
      iconTheme: const IconThemeData(color: textBlack),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldLight,
        hintStyle: const TextStyle(color: textGray),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: borderLight),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: borderLight),
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
      cardTheme: CardThemeData(
        color: surfaceLightMode,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textBlack,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceLightMode,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dividerTheme: DividerThemeData(color: borderLight),
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
