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


class SunsetTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFFFF3E0),
    cardColor: Color(0xFFFFE0B2),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFF7043),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFFFCCBC)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFD84315),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD84315),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFFF7043),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF3E2723),
    cardColor: Color(0xFF4E342E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFBF360C),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF4E342E)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF7043),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF7043),
        foregroundColor: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFFF7043),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}

class ForestTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFE8F5E9),
    cardColor: Color(0xFFC8E6C9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E7D32),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color.fromARGB(255, 197, 226, 198)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1B5E20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF2E7D32),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1B5E20),
    cardColor: Color(0xFF2E7D32),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF004D40),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color.fromARGB(255, 50, 107, 53)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFA5D6A7),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA5D6A7),
        foregroundColor: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF2E7D32),
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

class RetroTheme {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFFFF9C4),
    cardColor: Color(0xFFFFE082),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF7E57C2),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFF8BBD0)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFF06292),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF06292),
        foregroundColor: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF7E57C2),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF263238),
    cardColor: Color(0xFF37474F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF7E57C2),
      foregroundColor: Colors.white,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF37474F)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF8A65),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF8A65),
        foregroundColor: Colors.black,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFF06292),
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
