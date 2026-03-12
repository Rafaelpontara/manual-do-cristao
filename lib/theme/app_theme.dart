import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const goldPrimary = Color(0xFFD4A853);
  static const goldLight = Color(0xFFE8C87A);
  static const goldDark = Color(0xFFA07830);
  static const navyDeep = Color(0xFF0D1B2A);
  static const navyMid = Color(0xFF1A2E45);
  static const navyLight = Color(0xFF243B55);
  static const creamWhite = Color(0xFFF8F3E8);
  static const creamLight = Color(0xFFFAF6ED);
  static const warmGray = Color(0xFF8B7355);
  static const crimsonAccent = Color(0xFFB5451B);
  static const forestGreen = Color(0xFF2D6A4F);
  static const purple = Color(0xFF6B4C9A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: goldPrimary,
      scaffoldBackgroundColor: navyDeep,
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        secondary: goldLight,
        surface: navyMid,
        onPrimary: navyDeep,
        onSecondary: navyDeep,
        onSurface: creamWhite,
      ),
      cardColor: navyMid,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(color: goldPrimary, fontSize: 36, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.playfairDisplay(color: creamWhite, fontSize: 28, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.playfairDisplay(color: creamWhite, fontSize: 22, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.playfairDisplay(color: goldPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.playfairDisplay(color: creamWhite, fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.lato(color: creamWhite, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.lato(color: creamWhite, fontSize: 16, height: 1.8),
        bodyMedium: GoogleFonts.lato(color: Color(0xFFCBBFA8), fontSize: 14, height: 1.6),
        bodySmall: GoogleFonts.lato(color: warmGray, fontSize: 12, height: 1.5),
        labelLarge: GoogleFonts.lato(color: goldPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: navyDeep,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(color: goldPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: goldPrimary, size: 22),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: navyMid,
        selectedItemColor: goldPrimary,
        unselectedItemColor: Color(0xFF5A6E82),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navyLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A3F5A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2A3F5A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: goldPrimary, width: 1.5)),
        hintStyle: GoogleFonts.lato(color: warmGray, fontSize: 14),
        prefixIconColor: warmGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: navyDeep,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF1E3048), thickness: 1),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: goldDark,
      scaffoldBackgroundColor: creamLight,
      colorScheme: const ColorScheme.light(
        primary: goldDark,
        secondary: goldPrimary,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: navyDeep,
        onSurface: navyDeep,
      ),
      cardColor: Colors.white,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(color: goldDark, fontSize: 36, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.playfairDisplay(color: navyDeep, fontSize: 28, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.playfairDisplay(color: navyDeep, fontSize: 22, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.playfairDisplay(color: goldDark, fontSize: 20, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.playfairDisplay(color: navyDeep, fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.lato(color: navyDeep, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.lato(color: navyDeep, fontSize: 16, height: 1.8),
        bodyMedium: GoogleFonts.lato(color: Color(0xFF3A4A5C), fontSize: 14, height: 1.6),
        bodySmall: GoogleFonts.lato(color: warmGray, fontSize: 12),
        labelLarge: GoogleFonts.lato(color: goldDark, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: creamLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(color: goldDark, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: goldDark, size: 22),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: goldDark,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8DCC8))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8DCC8))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: goldDark, width: 1.5)),
        hintStyle: GoogleFonts.lato(color: warmGray, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE8DCC8), thickness: 1),
    );
  }
}
