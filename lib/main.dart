import 'package:expense_track/models/budget.dart';
import 'package:expense_track/pages/budgets_page.dart';
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
  Hive.registerAdapter(EntryAdapter());  // Register the Entry adapter
  
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(BudgetAdapter());
  }
   

  print('Opening expensesBox...');
  await HiveService.initialize();
  // Initialize the HiveService to open the box

  // await Hive.openBox<Budget>('budgetsBox');

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
        '/syncstatus': (context) => const SyncStatusPage(),
        '/budgets': (context) => const BudgetsPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: isDarkMode ? ForestTheme().darkTheme : ForestTheme().lightTheme,
      home: DashboardPage(), // your main app screen
    );
  }
}
