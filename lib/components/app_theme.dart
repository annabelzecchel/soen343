import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 235, 246, 236), // Soft green
      primary: const Color(0xFFABC5AE), // Primary color
      secondary: const Color(0xFFCA946F), // Secondary (light beige)
      tertiary: const Color(0xFFA74D0F), // Dark orange
      surface: const Color(0xFFCBDBCD), // Background color
      inversePrimary: const Color.fromARGB(255, 235, 246, 236), // App bar
      secondaryContainer: const Color(0xFFEDDBCF), // Light beige
      error: const Color(0xFFD60707), // Error color (dark orange)
      onPrimary: Colors.black, // Text on primary
      onSecondary: Colors.white, // Text on secondary
      onTertiary: Colors.black, // Text on tertiary
      onSurface: Colors.black, // Text on background
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        bodyLarge: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
        bodyMedium: GoogleFonts.manrope(fontSize: 16),
        bodySmall: GoogleFonts.manrope(fontSize: 14, color: Colors.black54),
        headlineMedium: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.bold),
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
