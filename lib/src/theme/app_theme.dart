import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF0F766E);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    primary: seed,
    secondary: const Color(0xFFF59E0B),
    surface: const Color(0xFFFCFAF5),
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF3EEE4),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF132238),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardColor: Colors.white,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: Color(0xFF132238),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF132238),
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF132238),
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        height: 1.45,
        color: Color(0xFF24364D),
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: Color(0xFF44546A),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: const Color(0xFFE0D9CE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide.none,
      selectedColor: colorScheme.primary.withValues(alpha: 0.12),
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
  );
}
