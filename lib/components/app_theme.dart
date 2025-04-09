import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 235, 246, 236),
      primary: const Color(0xFFABC5AE),
      secondary: const Color(0xFFCA946F),
      tertiary: const Color(0xFFA74D0F),
      surface: const Color(0xFFCBDBCD),
      inversePrimary: const Color.fromARGB(255, 235, 246, 236),
      secondaryContainer: const Color(0xFFEDDBCF),
      error: const Color(0xFFD60707),
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onTertiary: Colors.black,
      onSurface: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        bodyLarge:
            GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
        bodyMedium: GoogleFonts.manrope(fontSize: 16),
        bodySmall: GoogleFonts.manrope(fontSize: 14, color: Colors.black54),
        headlineMedium:
            GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.inversePrimary,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
