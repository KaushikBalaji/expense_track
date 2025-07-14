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
import 'package:shared_preferences/shared_preferences.dart';
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
import 'pages/onboarding_setup_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  debugPrint('Initializing Hive...');
  await Hive.initFlutter();

  Hive.registerAdapter(EntryAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(BudgetAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(CategoryItemAdapter());
  if (!Hive.isAdapterRegistered(5))
    Hive.registerAdapter(RecurringEntryAdapter());

  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('hasCompletedSetup', false);

  final hasCompletedSetup = prefs.getBool('hasCompletedSetup') ?? false;
  final themeName = prefs.getString('themeName') ?? 'Vscode';
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  await initialize();
  await generateDueRecurringEntries();
  await trySyncData();

  runApp(
    MyApp(
      startOnSetup: !hasCompletedSetup,
      initialTheme: themeName,
      initialDarkMode: isDarkMode,
    ),
  );
}

Future<void> initialize() async {
  try {
    await Hive.openBox<Budget>('budgetsBox');
    await Hive.openBox<List>('deletedEntries');
    await Hive.openBox<Entry>('entriesBox');
    await Hive.openBox<CategoryItem>('categories');
    await Hive.openBox<RecurringEntry>('recurring_entries_box');
    debugPrint('Hive boxes opened');
  } catch (e) {
    debugPrint('Error opening Hive box: $e');
  }
}

class MyApp extends StatefulWidget {
  final bool startOnSetup;
  final String initialTheme;
  final bool initialDarkMode;
  const MyApp({
    super.key,
    required this.startOnSetup,
    required this.initialTheme,
    required this.initialDarkMode,
  });

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  late String selectedThemeName = 'Vscode';
  late ThemeData currentThemeData = VscodeTheme().lightTheme;
  bool isDarkMode = false;
  //   bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // SharedPreferences.getInstance().then((prefs) {
    //     final theme = prefs.getString('themeName') ?? 'Vscode';
    //     final DarkMode = prefs.getBool('isDarkMode') ?? false;
    //   setState(() {
    //     selectedThemeName = theme;
    //     isDarkMode = DarkMode;
    //     currentThemeData = getThemeByName(selectedThemeName);
    //     // _isInitialized = true;
    //   });
    // });
    selectedThemeName = widget.initialTheme;
    isDarkMode = widget.initialDarkMode;
    currentThemeData = getThemeByName(selectedThemeName);
  }

  void handleThemeChange(String newTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeName', newTheme);
    setState(() {
      selectedThemeName = newTheme;
      currentThemeData = getThemeByName(newTheme);
    });
  }

  void toggleThemeMode(bool darkModeEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', darkModeEnabled);
    setState(() {
      isDarkMode = darkModeEnabled;
      currentThemeData = getThemeByName(selectedThemeName);
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
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      initialRoute: widget.startOnSetup ? '/setup' : '/settings',
      routes: {
        '/setup': (context) => const SetupPage(),
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
              onThemeChanged: handleThemeChange,
            ),
        '/categories': (context) => CategoryManagementPage(),
        '/sync_settings': (context) => SyncSettingsPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: currentThemeData,
    );
  }
}
