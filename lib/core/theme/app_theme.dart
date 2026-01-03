import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodePalette {
  static const Color primary = Color(0xFFFF4655); // Valorant Red
  static const Color background = Color(0xFF0F1923); // Dark BG
  static const Color surface = Color(0xFF1F2933); // Card BG
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color white = Color(0xFFECE8E1);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CodePalette.background,
      primaryColor: CodePalette.primary,
      colorScheme: const ColorScheme.dark(
        primary: CodePalette.primary,
        secondary: CodePalette.cyanAccent,
        surface: CodePalette.surface,
        background: CodePalette.background,
        error: CodePalette.primary,
      ),
      textTheme: GoogleFonts.robotoTextTheme().apply(
        bodyColor: CodePalette.white,
        displayColor: CodePalette.white,
      ).copyWith(
        displayLarge: GoogleFonts.oswald(fontSize: 80, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: CodePalette.white),
        headlineMedium: GoogleFonts.oswald(fontSize: 40, fontWeight: FontWeight.bold, color: CodePalette.white),
        bodyLarge: GoogleFonts.roboto(fontSize: 16, color: CodePalette.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CodePalette.background,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}