import 'package:flutter/material.dart';



class VscodeTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF3F3F3),
    cardColor: const Color(0xFFFFFFFF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF007ACC), // VS Code titlebar blue
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFE5E5E5)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF0E639C),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0E639C),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF007ACC),
      brightness: Brightness.light,
    ),
    
    useMaterial3: true,
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    cardColor: const Color(0xFF252526),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF333333),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF2D2D2D)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF007ACC),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF007ACC),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF007ACC),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}

class QuartzMistTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAF9F6),
    cardColor: const Color(0xFFF2ECF4),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF8E44AD),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFEADDEF)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF9B59B6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9B59B6),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9B59B6),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF2A2234),
    cardColor: const Color(0xFF3B2B4F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6C3483),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF3B2B4F)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFAF7AC5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFAF7AC5),
        foregroundColor: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9B59B6),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}


class LapisMinimalTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardColor: const Color(0xFFE2E8F0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3B82F6),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFE2E8F0)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2563EB),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    cardColor: const Color(0xFF1E293B),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1D4ED8),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E293B)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3B82F6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}


class MidnightTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFEDE7F6),
    cardColor: Color(0xFFD1C4E9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF512DA8),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFB39DDB)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6200EA),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6200EA),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF512DA8),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1F1B24),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF311B92),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1F1B24)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFBB86FC),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBB86FC),
        foregroundColor: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF6200EA),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}

class CarbonMatteTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: const Color(0xFFE0E0E0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF424242),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFD7CCC8)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF616161),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF424242),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF424242),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF212121),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E1E1E)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF757575),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF757575),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF757575),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}


class OceanTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF1F8E9), // Mint
    cardColor: const Color(0xFFE6F4EA), // Soft mint for cards
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

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1C313A), // Dark Blue-Grey
    cardColor: const Color(
      0xFF263238,
    ), // Slightly lighter than background for contrast
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
