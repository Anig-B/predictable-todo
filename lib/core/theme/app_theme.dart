import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF2A2D3E);
  static const Color bgColor = Color(0xFF212332);
  static const Color textColor = Colors.white;
  static const Color greyColor = Color(0xFF8B8B8B);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: bgColor,
    primaryColor: primaryColor,
    canvasColor: secondaryColor,
    cardTheme: CardThemeData(
      color: secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ).copyWith(surface: bgColor, secondary: primaryColor),
  );
}
