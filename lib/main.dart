import 'package:expense_track/services/hive_service.dart';
import 'package:flutter/material.dart';
import './widgets/CustomAppbar.dart';
import 'custom_theme.dart';
import './widgets/CustomSidebar.dart';
import 'models/entry.dart';
import 'pages/dashboard_page.dart';
import 'dart:io' show Platform;
import 'package:hive_flutter/hive_flutter.dart';
import '/pages/transactions_page.dart';
import '/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Initializing Hive...');
  await Hive.initFlutter();

  print('Registering Entry Adapter...');
  Hive.registerAdapter(EntryAdapter());       // Register the Entry adapter
  Hive.registerAdapter(EntryTypeAdapter());

  print('Opening expensesBox...');
  await HiveService.initialize();             // Initialize the HiveService to open the box

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const DashboardPage(),
    );
  }
}
