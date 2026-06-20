import 'package:flutter/material.dart';

/// Shared visual tokens for the kid-friendly UI layer.
abstract final class AppStyles {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFFD93D);
  static const Color background = Color(0xFFF8F9FF);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF6B6B);
  static const Color textPrimary = Color(0xFF1E1B3A);
  static const Color textSecondary = Color(0xFF5C5678);

  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0EEFF),
      Color(0xFFF8F9FF),
      Color(0xFFFFF8E7),
    ],
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF8B83FF),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF5A52E0),
    ],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [
      Color(0xFF4CAF50),
      Color(0xFF66BB6A),
    ],
  );

  static List<BoxShadow> softShadow(Color color, {double blur = 24}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.14),
        blurRadius: blur,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: primary,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.65,
  );
}
