import 'package:expense_track/models/budget.dart';
import 'package:expense_track/models/category_item.dart';
import 'package:expense_track/models/recurring_entry.dart';
import 'package:expense_track/pages/budgets_page.dart';
import 'package:expense_track/pages/category_page.dart';
import 'package:expense_track/pages/monthly_transactions_page.dart';
import 'package:expense_track/pages/recurring_entries_page.dart';
import 'package:expense_track/pages/sync_settings_page.dart';
import 'package:expense_track/pages/sync_status_page.dart';
import 'package:expense_track/pages/transactions_page.dart';
import 'package:expense_track/pages/user_page.dart';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,        
  );

  debugPrint('Initializing Hive...');
  await Hive.initFlutter();
  //await Hive.deleteBoxFromDisk('entriesBox');

  debugPrint('Registering Entry Adapter...');
  Hive.registerAdapter(EntryAdapter()); // Register the Entry adapter

  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(BudgetAdapter());
  }

  // For Recurring entry hive
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(RecurringEntryAdapter());
  }

  // to save categories in hive
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(CategoryItemAdapter());
  }

  // await Hive.deleteBoxFromDisk('categories');

  debugPrint('Opening expensesBox...');
  await initialize();
  await generateDueRecurringEntries();
  await trySyncData();

  runApp(const MyApp());
}

Future<void> initialize() async {
  try {
    await Hive.openBox<Budget>('budgetsBox');
    await Hive.openBox<List>('deletedEntries');
    await Hive.openBox<Entry>('entriesBox');
    await Hive.openBox<CategoryItem>('categories');
    await Hive.openBox<RecurringEntry>('recurring_entries_box');

    debugPrint('Hivebox open');
  } catch (e) {
    debugPrint('Error opening Hive box: $e');
  }
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
      case 'Lapis':
        return isDarkMode
            ? LapisMinimalTheme().darkTheme
            : LapisMinimalTheme().lightTheme;
      case 'Quartz':
        return isDarkMode
            ? QuartzMistTheme().darkTheme
            : QuartzMistTheme().lightTheme;
      case 'Midnight':
        return isDarkMode
            ? MidnightTheme().darkTheme
            : MidnightTheme().lightTheme;
      case 'Carbon':
        return isDarkMode
            ? CarbonMatteTheme().darkTheme
            : CarbonMatteTheme().lightTheme;
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
      supportedLocales: const [
        Locale('en'), // ✅ Add supported locales
      ],
      initialRoute: '/settings',
      routes: {
        '/user': (context) => const UserPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/transactions':
            (context) => const TransactionsPage(title: 'All Transactions'),
        '/win_transactions':
            (context) => const MonthlyTransactionsPage(title: 'Transactions'),
        '/syncstatus': (context) => const SyncStatusPage(),
        '/budgets': (context) => const BudgetsPage(),
        '/recurring': (context) => const RecurringEntriesPage(),
        '/settings':
            (_) => SettingsPage(
              currentTheme: selectedThemeName,
              onThemeChanged: (newTheme) => handleThemeChange(newTheme),
            ),

        '/categories': (context) => CategoryManagementPage(),
        '/sync_settings': (context) => SyncSettingsPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: currentThemeData,
      // home: SettingsPage(
      //   currentTheme: selectedThemeName,
      //   onThemeChanged: (newTheme) => handleThemeChange(newTheme),
      // ), // your main app screen
    );
  }
}
