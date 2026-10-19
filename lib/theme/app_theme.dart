import 'package:flutter/material.dart';

class AppTheme {
  // Signature Wise Brand Colors
  static const Color wiseLime = Color(0xFF9FE870); // Wise Electric Lime
  static const Color wiseForest = Color(0xFF163300); // Wise Deep Forest Green
  static const Color wiseForestLight = Color(0xFF244F00);
  static const Color wiseLimePressed = Color(0xFF8BD55C);

  // Light Theme Colors (Wise Soft Sage & Linen — Eliminates sterile hospital white)
  static const Color backgroundLight = Color(0xFFECEFE6); // Warm Organic Sage
  static const Color surfaceLightMode = Color(0xFFFFFFFF); // Clean Card Surface
  static const Color surfaceSecondaryLight = Color(0xFFF4F6F0);
  static const Color fieldLight = Color(0xFFE1E5DC); // Input field background
  static const Color borderLight = Color(0xFFD3D9CC); // Warm subtle border

  // Dark Theme Colors (Wise Deep Forest Graphite)
  static const Color backgroundDark = Color(0xFF090D09); // Deep Obsidian
  static const Color surfaceDark = Color(0xFF121812); // Forest Graphite Card
  static const Color surfaceElevatedDark = Color(0xFF192219);
  static const Color fieldDark = Color(0xFF1A221A);
  static const Color borderDark = Color(0xFF253325);

  // Typography Colors
  static const Color textForest = Color(0xFF163300); // Deep High-Contrast Text
  static const Color textForestMuted = Color(0xFF55694D); // Soft Forest Sage
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA5B8A5);
  static const Color textMuted = Color(0xFF708470);

  // Danger
  static const Color danger = Color(0xFFDC2626);

  // Fallbacks
  static const LinearGradient mainGradient = LinearGradient(
    colors: [wiseForest, wiseForestLight],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: wiseLime,
      colorScheme: const ColorScheme.dark(
        primary: wiseLime,
        onPrimary: wiseForest,
        secondary: wiseLime,
        surface: surfaceDark,
        onSurface: textWhite,
        surfaceContainerHighest: fieldDark,
        outline: borderDark,
        onSurfaceVariant: textSecondary,
        error: danger,
      ),
      iconTheme: const IconThemeData(color: textWhite),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldDark,
        hintStyle: const TextStyle(color: textMuted, fontSize: 16),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: borderDark),
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: borderDark),
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: wiseLime, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: borderDark, width: 1),
        ),
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
      dividerTheme: const DividerThemeData(color: borderDark, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceElevatedDark,
        contentTextStyle: const TextStyle(
          color: textWhite,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: wiseLime,
          foregroundColor: wiseForest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: wiseForest,
      colorScheme: const ColorScheme.light(
        primary: wiseForest,
        onPrimary: wiseLime,
        secondary: wiseForestLight,
        surface: surfaceLightMode,
        onSurface: textForest,
        surfaceContainerHighest: fieldLight,
        outline: borderLight,
        onSurfaceVariant: textForestMuted,
        error: danger,
      ),
      iconTheme: const IconThemeData(color: textForest),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLightMode,
        hintStyle: const TextStyle(color: textForestMuted, fontSize: 16),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: borderLight),
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: borderLight),
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: wiseForest, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLightMode,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textForest,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceLightMode,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: borderLight, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: wiseForest,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: wiseForest,
          foregroundColor: wiseLime,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
