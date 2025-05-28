import 'package:expense_track/models/budget.dart';
import 'package:expense_track/models/category_item.dart';
import 'package:expense_track/pages/budgets_page.dart';
import 'package:expense_track/pages/category_page.dart';
import 'package:expense_track/pages/monthly_transactions_page.dart';
import 'package:expense_track/pages/sync_status_page.dart';
import 'package:expense_track/pages/transactions_page.dart';
import 'package:expense_track/pages/user_page.dart';
import 'package:expense_track/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'custom_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/entry.dart';
import 'pages/dashboard_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'pages/settings_page.dart';
import 'utils/sync_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qjjooylsjtrdvmnnvnhx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqam9veWxzanRyZHZtbm52bmh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMzcyMDQsImV4cCI6MjA2MjgxMzIwNH0.npHvRdDTqudBWJiLpFVjPTsdy3pZ_z7yDpHqmdBe0FM',
  );

  print('Initializing Hive...');
  await Hive.initFlutter();
  //await Hive.deleteBoxFromDisk('entriesBox');

  print('Registering Entry Adapter...');
  Hive.registerAdapter(EntryAdapter()); // Register the Entry adapter

  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(BudgetAdapter());
  }

  // to save categories in hive
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(CategoryItemAdapter());
  }

  //await Hive.deleteBoxFromDisk('categories');



  print('Opening expensesBox...');
  await HiveService.initialize();
  // Initialize the HiveService to open the box

  await Hive.openBox<Budget>('budgetsBox');
  await Hive.openBox<List>('categoryStatus');
  await Hive.openBox<CategoryItem>('categories');
  await Hive.openBox<List>('deletedEntries');
  await Hive.openBox<Entry>('entriesBox');

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
  // bool isDarkMode = false;
  late String selectedThemeName;
  late ThemeData currentThemeData;
  bool isDarkMode = false; // You can make this persistent if needed

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      currentThemeData = getThemeByName(selectedThemeName);
    });
  }

  @override
  void initState() {
    super.initState();
    trySyncData();
    selectedThemeName = 'Vscode'; // default theme
    currentThemeData = getThemeByName(selectedThemeName);
  }

  void handleThemeChange(String newTheme) {
    setState(() {
      selectedThemeName = newTheme;
      currentThemeData = getThemeByName(newTheme);

      // Optional: switch dark/light mode based on theme
      isDarkMode = currentThemeData.brightness == Brightness.dark;
    });
  }

  ThemeData getThemeByName(String name) {
    switch (name) {
      case 'Forest':
        return isDarkMode ? ForestTheme().darkTheme : ForestTheme().lightTheme;
      case 'Sunset':
        return isDarkMode ? SunsetTheme().darkTheme : SunsetTheme().lightTheme;
      case 'Midnight':
        return isDarkMode
            ? MidnightTheme().darkTheme
            : MidnightTheme().lightTheme;
      case 'Retro':
        return isDarkMode ? RetroTheme().darkTheme : RetroTheme().lightTheme;
      case 'Ocean':
        return isDarkMode ? OceanTheme().darkTheme : OceanTheme().lightTheme;
      case 'Vscode':
        return isDarkMode ? VscodeTheme().darkTheme : VscodeTheme().lightTheme;
      default:
        return isDarkMode ? OceanTheme().darkTheme : OceanTheme().lightTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate, // ✅ Required
      ],
      routes: {
        '/user': (context) => const UserPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/transactions':
            (context) => const TransactionsPage(title: 'All Transactions'),
        '/win_transactions':
            (context) => const MonthlyTransactionsPage(title: 'Transactions'),
        '/syncstatus': (context) => const SyncStatusPage(),
        '/budgets': (context) => const BudgetsPage(),
        '/settings':
            (_) => SettingsPage(
              currentTheme: selectedThemeName,
              onThemeChanged: (newTheme) => handleThemeChange(newTheme),
            ),

        '/categories': (context) => CategoryManagementPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: currentThemeData,
      home: DashboardPage(), // your main app screen
    );
  }
}
