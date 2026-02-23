import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors (Indigo → Purple gradient palette) ─────────────────────────
  static const Color primaryColor = Color(0xFF6366F1); // indigo-500
  static const Color primaryDark = Color(0xFF4F46E5); // indigo-600
  static const Color accentColor = Color(0xFF9333EA); // purple-600

  // ── Surface Colors (glassmorphism light) ─────────────────────────────────────
  static const Color bgGradientStart = Color(0xFFEEF2FF); // indigo-50
  static const Color bgGradientMid = Color(0xFFF5F3FF); // purple-50
  static const Color bgGradientEnd = Color(0xFFFDF2F8); // pink-50

  static const Color cardColor = Color(0x80FFFFFF); // white/50
  static const Color cardBorder = Color(0x99FFFFFF); // white/60
  static const Color secondaryColor = Color(
    0xCCFFFFFF,
  ); // white/80 (for list tiles)

  // ── Text Colors ───────────────────────────────────────────────────────────────
  static const Color textColor = Color(0xFF1E293B); // slate-800
  static const Color greyColor = Color(0xFF64748B); // slate-500
  static const Color subtleColor = Color(0xFF94A3B8); // slate-400

  // ── Status Colors ─────────────────────────────────────────────────────────────
  static const Color successColor = Color(0xFF10B981); // emerald-500
  static const Color warningColor = Color(0xFFF59E0B); // amber-500
  static const Color errorColor = Color(0xFFF43F5E); // rose-500

  // ── Category badge colors ─────────────────────────────────────────────────────
  static const Color spearBg = Color(0xFFFFF7ED); // orange-50
  static const Color spearText = Color(0xFFEA580C); // orange-600
  static const Color seedBg = Color(0xFFF0FDF4); // green-50
  static const Color seedText = Color(0xFF16A34A); // green-600
  static const Color netBg = Color(0xFFEFF6FF); // blue-50
  static const Color netText = Color(0xFF2563EB); // blue-600

  // ── Gradient helpers ──────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgGradientStart, bgGradientMid, bgGradientEnd],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFB923C), Color(0xFFF97316)],
  );

  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFEEF2FF),
    primaryColor: primaryColor,
    canvasColor: Colors.white,
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: cardBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
      displayMedium: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
      displaySmall: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
      headlineSmall: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(color: textColor, fontFamily: 'Inter'),
      bodyMedium: TextStyle(color: greyColor, fontFamily: 'Inter'),
    ),
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFEEF2FF),
          secondary: accentColor,
          error: errorColor,
        ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      selectedItemColor: primaryColor,
      unselectedItemColor: greyColor,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: greyColor, fontFamily: 'Inter'),
      hintStyle: const TextStyle(color: subtleColor, fontFamily: 'Inter'),
    ),
  );
}
