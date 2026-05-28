import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Soft Teal & Warm Cream
  static const Color primary = Color(0xFF4ECDC4);
  static const Color primaryDark = Color(0xFF2BAD9E);
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color accent = Color(0xFFFFE66D);
  static const Color bgLight = Color(0xFFF7F3EE);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMedium = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color danger = Color(0xFFE17055);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color pink = Color(0xFFE84393);
  static const Color orange = Color(0xFFE67E22);

  // Mood Colors
  static const Color moodGreat = Color(0xFF00B894);
  static const Color moodGood = Color(0xFF4ECDC4);
  static const Color moodOkay = Color(0xFFFFE66D);
  static const Color moodBad = Color(0xFFFF7675);
  static const Color moodTerrible = Color(0xFFE17055);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: bgLight,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
          displayMedium: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          headlineMedium: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            color: textDark,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            color: textMedium,
          ),
          labelLarge: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          iconTheme: const IconThemeData(color: textDark),
        ),
        cardTheme: CardThemeData(
  color: bgCard,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      );
}