import 'package:flutter/material.dart';

class AppPalette {
  static const Color bgDark = Color(0xFF0E0F13);
  static const Color cardDark = Color(0xFF181A20);
  static const Color cardElevated = Color(0xFF22252E);
  static const Color borderSubtle = Color(0xFF2B2E38);

  static const Color electricBlue = Color(0xFF1F7CFF);
  static const Color vibrantYellow = Color(0xFFFFD426);
  static const Color flameOrange = Color(0xFFFF6B2C);
  static const Color emeraldGreen = Color(0xFF22C55E);

  static const Color inkWhite = Color(0xFFFFFFFF);
  static const Color inkMuted = Color(0xFF8E92A4);
  static const Color inkDark = Color(0xFF121318);
}

class SubjectTheme {
  final Color primary;
  final Color background;
  final Color text;
  final IconData icon;

  const SubjectTheme({
    required this.primary,
    required this.background,
    required this.text,
    this.icon = Icons.menu_book_rounded,
  });
}

class SubjectColors {
  static const List<SubjectTheme> _darkThemes = [
    SubjectTheme(
      primary: AppPalette.electricBlue,
      background: AppPalette.cardDark,
      text: AppPalette.inkWhite,
      icon: Icons.code_rounded,
    ),
    SubjectTheme(
      primary: AppPalette.vibrantYellow,
      background: AppPalette.cardDark,
      text: AppPalette.inkWhite,
      icon: Icons.layers_rounded,
    ),
    SubjectTheme(
      primary: AppPalette.flameOrange,
      background: AppPalette.cardDark,
      text: AppPalette.inkWhite,
      icon: Icons.bolt_rounded,
    ),
    SubjectTheme(
      primary: AppPalette.emeraldGreen,
      background: AppPalette.cardDark,
      text: AppPalette.inkWhite,
      icon: Icons.science_rounded,
    ),
    SubjectTheme(
      primary: Color(0xFF38BDF8), // Cyan
      background: AppPalette.cardDark,
      text: AppPalette.inkWhite,
      icon: Icons.computer_rounded,
    ),
    SubjectTheme(
      primary: Color(0xFFA78BFA), // Violet
      background: AppPalette.cardDark,
      text: AppPalette.inkWhite,
      icon: Icons.auto_stories_rounded,
    ),
  ];

  static const SubjectTheme defaultOverloadTheme = SubjectTheme(
    primary: AppPalette.vibrantYellow,
    background: AppPalette.cardDark,
    text: AppPalette.inkWhite,
    icon: Icons.add_circle_outline_rounded,
  );

  static SubjectTheme getTheme(String courseCode, {bool isOverload = false}) {
    if (isOverload) return defaultOverloadTheme;
    final cleanCode = courseCode.trim().toUpperCase();
    final hash = cleanCode.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return _darkThemes[hash % _darkThemes.length];
  }
}
