import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get retroTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32), // Cactus green
        secondary: const Color(0xFFFF80AB), // Pink clouds
        brightness: Brightness.dark,
        background: const Color(0xFF140026), // Dark purple sky
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent, // Let the background image show
      textTheme: GoogleFonts.vt323TextTheme().copyWith(
        displayLarge: GoogleFonts.vt323(fontWeight: FontWeight.normal, color: const Color(0xFFB39DDB), fontSize: 64),
        displayMedium: GoogleFonts.vt323(fontWeight: FontWeight.normal, color: const Color(0xFFFF80AB), fontSize: 48),
        headlineLarge: GoogleFonts.vt323(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 36),
        headlineMedium: GoogleFonts.vt323(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 28),
        titleLarge: GoogleFonts.vt323(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 24),
        titleMedium: GoogleFonts.vt323(fontWeight: FontWeight.normal, color: Colors.white70, fontSize: 20),
        bodyLarge: GoogleFonts.vt323(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50), // Green like grass
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: GoogleFonts.vt323(fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Less rounded for retro feel
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          elevation: 8,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1B0B2A).withOpacity(0.9), // Dark card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF4CAF50), width: 3), // Green border
        ),
        elevation: 12,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
