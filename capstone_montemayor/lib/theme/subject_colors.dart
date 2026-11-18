import 'package:flutter/material.dart';

class SubjectTheme {
  final Color primary;
  final Color background;
  final Color text;

  const SubjectTheme({
    required this.primary,
    required this.background,
    required this.text,
  });
}

class SubjectColors {
  static const Map<String, SubjectTheme> _palette = {
    'CSIT284': SubjectTheme(
      primary: Color(0xFF4F46E5), // Indigo
      background: Color(0xFFEEF2FF),
      text: Color(0xFF312E81),
    ),
    'IT312': SubjectTheme(
      primary: Color(0xFFE11D48), // Rose / Coral
      background: Color(0xFFFFE4E6),
      text: Color(0xFF881337),
    ),
    'IT314': SubjectTheme(
      primary: Color(0xFF059669), // Emerald / Mint
      background: Color(0xFFECFDF5),
      text: Color(0xFF064E3B),
    ),
    'CAP101': SubjectTheme(
      primary: Color(0xFF7C3AED), // Violet
      background: Color(0xFFF5F3FF),
      text: Color(0xFF4C1D95),
    ),
  };

  static const SubjectTheme defaultOverloadTheme = SubjectTheme(
    primary: Color(0xFFD97706), // Amber
    background: Color(0xFFFFFBEB),
    text: Color(0xFF78350F),
  );

  static const SubjectTheme defaultTheme = SubjectTheme(
    primary: Color(0xFF0284C7), // Sky Blue
    background: Color(0xFFF0F9FF),
    text: Color(0xFF0C4A6E),
  );

  static SubjectTheme getTheme(String courseCode, {bool isOverload = false}) {
    if (isOverload) return defaultOverloadTheme;
    final cleanCode = courseCode.trim().toUpperCase();
    return _palette[cleanCode] ?? defaultTheme;
  }
}
