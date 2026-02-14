import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Muted Harmony)
  static const Color primary = Color(
    0xFF059669,
  ); // Emerald 600 - Rich, trustworthy
  static const Color primaryVariant = Color(0xFF047857); // Emerald 700
  static const Color secondary = Color(0xFFD97706); // Amber 600 - Warm accent
  static const Color secondaryVariant = Color(0xFFB45309); // Amber 700

  // Semantic Colors (Functional)
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Neutral Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFF9FAFB); // Gray 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111827); // Gray 900
  static const Color textSecondaryLight = Color(0xFF6B7280); // Gray 500
  static const Color borderLight = Color(0xFFE5E7EB); // Gray 200

  // Neutral Colors (Dark Mode - OLED Friendly)
  static const Color backgroundDark = Color(0xFF111827); // Gray 900
  static const Color surfaceDark = Color(0xFF1F2937); // Gray 800
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Gray 50
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Gray 400
  static const Color borderDark = Color(0xFF374151); // Gray 700
}

class AppConstants {
  static const String appName = 'ProdEye';
  static const String fontFamily =
      'tajawal'; // Modern, clean font for Arabic/English
}
