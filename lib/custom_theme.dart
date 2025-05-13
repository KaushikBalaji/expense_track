import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF1F8E9), // Mint
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00ACC1), // Cyan
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFFE0F7FA), // Light Aqua
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00838F), // Darker Cyan
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00838F),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF00ACC1),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1C313A), // Dark Blue-Grey
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF004D40), // Deep Teal
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF263238), // Charcoal
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00ACC1), // Cyan
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00ACC1),
        foregroundColor: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF00ACC1),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
