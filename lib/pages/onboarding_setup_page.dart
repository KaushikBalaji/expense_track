import 'package:expense_track/custom_theme.dart';
import 'package:expense_track/main.dart';
import 'package:expense_track/models/category_item.dart';
import 'package:expense_track/utils/predefined_categories.dart';
import 'package:expense_track/widgets/CustomAppbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sync_mode_selector.dart';
import '../widgets/auto_sync_frequency_selector.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  bool syncPrefConfirmed = false;
  bool categoryPrefConfirmed = false;

  // These could be lifted to global scope if needed elsewhere
  String _selectedSyncMode = 'offline';
  String _selectedFrequency = 'Daily';
  String _selectedTheme = 'Vscode'; // default value
  bool _isDarkMode = false;

  final TextEditingController _customDaysController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   initializeDefaultCategoriesIfNeeded();
  // }

  // to set default categories on app first launch
  final List<String> defaultCategoryIds = [
    'salary',
    'freelance',
    'gift',
    'investment',
    'bonus',
    'food',
    'house',
    'clothing',
    'transport',
    'shopping',
    'medical',
    'bills',
    'groceries',
    'education',
    'subscription',
    'entertainment',
    'loan',
    'personal_care',
    'repair',
    'travel',
  ];

  final List<String> themes = [
    'Ocean',
    'Lapis',
    'Quartz',
    'Midnight',
    'Carbon',
    'Vscode',
  ];

  void _showThemePicker() {
    final appState = MyApp.of(context); // Get access to MyApp's state
    showModalBottomSheet(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              final theme = appState?.getThemeByName(
                appState.selectedThemeName,
              );
              final darkMode = appState?.isDarkMode ?? false;
              return Theme(
                data: theme ?? Theme.of(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Choose Theme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...themes.map(
                        (theme) => RadioListTile<String>(
                          title: Text(theme),
                          value: theme,
                          groupValue: _selectedTheme,
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => _selectedTheme = value);
                              setState(() => _selectedTheme = value);
                              appState?.handleThemeChange(value);
                            }
                          },
                        ),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        value: _isDarkMode,
                        onChanged: (value) {
                          setModalState(() => _isDarkMode = value);
                          setState(() => _isDarkMode = value);
                          appState?.toggleThemeMode(value);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  ThemeData _getCurrentTheme() {
    switch (_selectedTheme) {
      case 'Lapis':
        return _isDarkMode
            ? LapisMinimalTheme().darkTheme
            : LapisMinimalTheme().lightTheme;
      case 'Quartz':
        return _isDarkMode
            ? QuartzMistTheme().darkTheme
            : QuartzMistTheme().lightTheme;
      case 'Midnight':
        return _isDarkMode
            ? MidnightTheme().darkTheme
            : MidnightTheme().lightTheme;
      case 'Carbon':
        return _isDarkMode
            ? CarbonMatteTheme().darkTheme
            : CarbonMatteTheme().lightTheme;
      case 'Ocean':
        return _isDarkMode ? OceanTheme().darkTheme : OceanTheme().lightTheme;
      case 'Vscode':
        return _isDarkMode ? VscodeTheme().darkTheme : VscodeTheme().lightTheme;
      default:
        return _isDarkMode ? OceanTheme().darkTheme : OceanTheme().lightTheme;
    }
  }

  Future<void> _saveSyncPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String finalFreq = _selectedFrequency;

    if (_selectedSyncMode == 'auto' && _selectedFrequency == 'custom') {
      final customVal = int.tryParse(_customDaysController.text.trim());
      if (customVal == null || customVal < 1) {
        _showError('Enter a valid custom day interval');
        return;
      }
      finalFreq = 'custom:$customVal';
    }

    await prefs.setString('syncMode', _selectedSyncMode);
    await prefs.setString('syncFrequency', finalFreq);

    setState(() => syncPrefConfirmed = true);
  }

  Future<void> initializeDefaultCategoriesIfNeeded() async {
    final box = Hive.box<CategoryItem>('categories');

    for (final cat in predefinedCategories) {
      if (defaultCategoryIds.contains(cat.id) &&
          !box.values.any((c) => c.id == cat.id)) {
        cat.isActive = true;
        await box.put(cat.id, cat);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedSetup', true);
    await prefs.setString('themeName', _selectedTheme); // 👈 Save theme
    await prefs.setBool('isDarkMode', _isDarkMode);

    // Apply the theme immediately in the app
    final app = MyApp.of(context);
    app?.handleThemeChange(_selectedTheme);
    app?.toggleThemeMode(_isDarkMode);

    // Navigate to home screen or main app
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/settings');
    }
  }

  bool _initializedTheme = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initializedTheme) {
      final appState = MyApp.of(context);
      if (appState != null) {
        setState(() {
          _selectedTheme = appState.selectedThemeName;
          _isDarkMode = appState.isDarkMode;
          _initializedTheme = true;
        });
      }
    }

    initializeDefaultCategoriesIfNeeded();

  }

  Widget _buildPreferenceCard({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      child: ExpansionTile(
        title: Row(
          children: [
            Checkbox(value: value, onChanged: onChanged),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        children: [Padding(padding: const EdgeInsets.all(16.0), child: child)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Theme(
      data: _getCurrentTheme(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Onboarding Page'),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    "Let's get your app ready!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Choose your preferences below. All steps are required to continue.",
                  ),
                  const SizedBox(height: 24),

                  // ✅ Sync Preferences Section
                  _buildPreferenceCard(
                    title: "Sync Preferences",
                    value: syncPrefConfirmed,
                    onChanged: (val) {
                      if (val == true) {
                        _saveSyncPreferences();
                      } else {
                        setState(() => syncPrefConfirmed = false);
                      }
                    },
                    child: Column(
                      children: [
                        SyncModeSelector(
                          selected: _selectedSyncMode,
                          onChanged: (val) {
                            setState(() => _selectedSyncMode = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_selectedSyncMode == 'auto')
                          AutoSyncFrequencySelector(
                            selected: _selectedFrequency,
                            onChanged: (val) {
                              setState(() {
                                _selectedFrequency = val;
                                _customDaysController.clear();
                              });
                            },
                            controller: _customDaysController,
                          ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _saveSyncPreferences,
                          child: const Text('Save Sync Settings'),
                        ),
                      ],
                    ),
                  ),

                  // 🗂️ Future: Category Preference Setup
                  _buildPreferenceCard(
                    title: "Category Preferences",
                    value: categoryPrefConfirmed,
                    onChanged: (val) {
                      setState(() => categoryPrefConfirmed = val ?? false);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "To be implemented: Let user select default active categories.",
                        ),
                      ],
                    ),
                  ),

                  _buildPreferenceCard(
                    title: "App Theme",
                    value: true,
                    onChanged: (_) {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Theme: $_selectedTheme, Mode: ${_isDarkMode ? 'Dark' : 'Light'}",
                        ),
                        ElevatedButton(
                          onPressed: _showThemePicker,
                          child: const Text("Change"),
                        ),
                      ],
                    ),
                  ),

                  // _buildPreferenceCard(
                  //   title: "Appearance Preferences",
                  //   value: true, // or bind it to a state if needed
                  //   onChanged: (_) {},
                  //   child: _buildThemeSelector(),
                  // ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Continue to App'),
                    onPressed:
                        syncPrefConfirmed && categoryPrefConfirmed
                            ? _completeSetup
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
