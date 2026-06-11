import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primary = Color(0xFF4ECDC4);
  static const Color primaryDark = Color(0xFF2BAD9E);
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color accent = Color(0xFFFFE66D);
  static const Color purple = Color(0xFF6C5CE7);
  static const Color pink = Color(0xFFE84393);
  static const Color orange = Color(0xFFE67E22);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color danger = Color(0xFFE17055);

  // Additional Colors
  static const Color teal = Color(0xFF0D9488);
  static const Color tealDk = Color(0xFF0F766E);
  static const Color gold = Color(0xFFF59E0B);

  // Mood Colors
  static const Color moodGreat = Color(0xFF00B894);
  static const Color moodGood = Color(0xFF4ECDC4);
  static const Color moodOkay = Color(0xFFFFE66D);
  static const Color moodBad = Color(0xFFFF7675);
  static const Color moodTerrible = Color(0xFFE17055);

  // Light Colors
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFFB2BEC3);

  // Dark Colors
  static const Color bgDark = Color(0xFF0F0F0F);
  static const Color bgCardDark = Color(0xFF1C1C1E);
  static const Color bgCard2Dark = Color(0xFF2C2C2E);
  static const Color textDarkMode = Color(0xFFECECEC);
  static const Color textMedDark = Color(0xFF9A9A9A);
  static const Color textLightDark = Color(0xFF4A4A4A);

  // Context Helpers
  static Color card(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? bgCardDark
          : bgCard;

  static Color card2(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? bgCard2Dark
          : const Color(0xFFF0EDE8);

  static Color bg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? bgDark
          : bgLight;

  static Color text(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? textDarkMode
          : textDark;

  static Color textMed(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? textMedDark
          : textMedium;

  static Color textLt(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? textLightDark
          : textLight;

  static bool isDark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  static Color divider(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.grey.shade200;

  // LIGHT THEME
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: bgLight,
        cardColor: bgCard,
        dividerColor: Colors.grey.shade200,

        textTheme: _textTheme(Brightness.light),
        appBarTheme: _appBarTheme(Brightness.light),

        cardTheme: _cardTheme(),

        elevatedButtonTheme: _elevatedButtonTheme(),
        outlinedButtonTheme: _outlinedButtonTheme(),
        textButtonTheme: _textButtonTheme(),

        inputDecorationTheme: _inputTheme(Brightness.light),

        listTileTheme: const ListTileThemeData(
          iconColor: textMedium,
        ),

        switchTheme: _switchTheme(),

        chipTheme: _chipTheme(Brightness.light),

        tabBarTheme: _tabBarTheme(Brightness.light),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
        ),
      );

  // DARK THEME
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ).copyWith(
          surface: bgDark,
          onSurface: textDarkMode,
        ),

        scaffoldBackgroundColor: bgDark,
        cardColor: bgCardDark,
        dividerColor: Colors.white.withValues(alpha: 0.08),

        textTheme: _textTheme(Brightness.dark),
        appBarTheme: _appBarTheme(Brightness.dark),

        cardTheme: _cardThemeDark(),

        elevatedButtonTheme: _elevatedButtonTheme(),
        outlinedButtonTheme: _outlinedButtonThemeDark(),
        textButtonTheme: _textButtonTheme(),

        inputDecorationTheme: _inputTheme(Brightness.dark),

        listTileTheme: const ListTileThemeData(
          iconColor: textMedDark,
        ),

        switchTheme: _switchTheme(),

        chipTheme: _chipTheme(Brightness.dark),

        tabBarTheme: _tabBarTheme(Brightness.dark),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: bgCardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: bgCardDark,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDarkMode,
          ),
          contentTextStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: textMedDark,
          ),
        ),
      );

  // TEXT THEME
  static TextTheme _textTheme(Brightness b) {
    final dark = b == Brightness.dark;

    final txt = dark ? textDarkMode : textDark;
    final med = dark ? textMedDark : textMedium;

    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: txt,
      ),

      displayMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: txt,
      ),

      headlineMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: txt,
      ),

      headlineSmall: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: txt,
      ),

      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: txt,
      ),

      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: med,
      ),

      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: med,
      ),

      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: txt,
      ),

      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        color: med,
      ),
    );
  }

  // APPBAR
  static AppBarTheme _appBarTheme(Brightness b) {
    final dark = b == Brightness.dark;

    return AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,

      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: dark ? textDarkMode : textDark,
      ),

      iconTheme: IconThemeData(
        color: dark ? textDarkMode : textDark,
      ),
    );
  }

  // CARD
  static CardThemeData _cardTheme() => CardThemeData(
        color: bgCard,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      );

  static CardThemeData _cardThemeDark() => CardThemeData(
        color: bgCardDark,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      );

  // BUTTONS
  static ElevatedButtonThemeData _elevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,

          elevation: 4,

          shadowColor: primary.withValues(alpha: 0.3),

          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,

          side: const BorderSide(
            color: primary,
            width: 1.5,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonThemeDark() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,

          side: const BorderSide(
            color: primary,
            width: 1.5,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static TextButtonThemeData _textButtonTheme() => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // INPUT
  static InputDecorationTheme _inputTheme(Brightness b) {
    final dark = b == Brightness.dark;

    return InputDecorationTheme(
      filled: true,

      fillColor:
          dark ? bgCard2Dark : const Color(0xFFF1F5F9),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: dark
              ? Colors.white12
              : Colors.transparent,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: primary,
          width: 2,
        ),
      ),

      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: dark
            ? textLightDark
            : textLight,
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
    );
  }

  // SWITCH
  static SwitchThemeData _switchTheme() => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.grey,
        ),

        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      );

  // CHIP
  static ChipThemeData _chipTheme(Brightness b) =>
      ChipThemeData(
        backgroundColor: b == Brightness.dark
            ? bgCard2Dark
            : Colors.grey.shade100,

        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),

        side: BorderSide.none,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      );

  // TABBAR
  static TabBarThemeData _tabBarTheme(Brightness b) {
    final dark = b == Brightness.dark;

    return TabBarThemeData(
      labelColor: primary,

      unselectedLabelColor:
          dark ? textMedDark : textLight,

      indicatorColor: primary,

      labelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),

      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 13,
      ),
    );
  }
}
