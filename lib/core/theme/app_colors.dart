import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color bg       = Color(0xFF08080E);
  static const Color surface  = Color(0xFF101018);
  static const Color surface2 = Color(0xFF181824);
  static const Color surface3 = Color(0xFF20202E);
  static const Color border   = Color(0xFF252538);
  static const Color text     = Color(0xFFE8E8F0);
  static const Color muted    = Color(0xFF8888A8);
  static const Color subtle   = Color(0xFF555570);
  static const Color accent   = Color(0xFF06D6A0);
  static const Color purple   = Color(0xFF8338EC);
  static const Color blue     = Color(0xFF3A86FF);
  static const Color gold     = Color(0xFFFFBE0B);
  static const Color red      = Color(0xFFFF006E);
  static const Color orange   = Color(0xFFFB5607);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, blue],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [red, orange],
  );

  static const List<Color> confettiColors = [
    accent, purple, gold, orange, red, blue,
  ];

  /// Reusable greyscale colour filter (boss defeated, locked badges).
  static const ColorFilter grayscaleFilter = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ]);
}
