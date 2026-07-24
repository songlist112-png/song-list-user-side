import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Main background (dark blue)
  static const Color bg = Color(0xFF005A9E);

  static const Color bgDark = Color(0xFF004A80);

  // Column background (light gray)
  static const Color bgColumn = Color(0xFFF1F2F4);

  // Card background
  static const Color bgCard = Color(0xFFFFFFFF);

  // Text colors
  static const Color text = Color(0xFF172B4D);
  static const Color textMuted = Color(0xFF44546F);

  // Accent / primary action blue
  static const Color accent = Color(0xFF0C66E4);

  // Border
  static const Color border = Color(0xFFDCDFE4);

  // Card hover
  static const Color cardHoverBg = Color(0xFFF8F9FA);

  // Button hover
  static const Color btnHover = Color(0x0F091E42);

  // Drag over
  static const Color dragOverBg = Color(0xFFEBECF0);

  // Filter button
  static const Color filterBtnBg = Color(0x33FFFFFF);
  static const Color filterBtnActive = Color(0xFFFFFFFF);
  static const Color filterBtnActiveText = Color(0xFF0C66E4);

  // Shadow for cards
  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x40091E42), offset: Offset(0, 1), blurRadius: 1),
    BoxShadow(color: Color(0x4F091E42), offset: Offset(0, 0), blurRadius: 1),
  ];
}
