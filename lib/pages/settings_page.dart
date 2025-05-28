import 'dart:io';

import 'package:expense_track/widgets/CustomAppbar.dart';
import 'package:expense_track/widgets/CustomSidebar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(String) onThemeChanged; // callback for theme change
  final String currentTheme;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedTheme;

  final List<String> themes = [
    'Ocean',
    'Sunset',
    'Forest',
    'Midnight',
    'Retro',
    'Vscode',
  ];


  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  void _showSyncFrequencyPicker() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFrequency = prefs.getString('syncFrequency') ?? 'Daily';
    final TextEditingController _customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String selected = savedFrequency;

        return StatefulBuilder(
          builder:
              (context, setState) => Padding(
                padding: MediaQuery.of(
                  context,
                ).viewInsets.add(const EdgeInsets.all(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Sync Frequency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...['Daily', 'Weekly', 'Monthly'].map(
                      (option) => RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: selected,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selected = value;
                              _customController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    const Divider(),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          const Text('Every'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _customController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Enter days',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selected = 'custom:$value';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('days'),
                        ],
                      ),
                      value: selected,
                      groupValue: selected,
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        prefs.setString('syncFrequency', selected);
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...themes.map(
                  (theme) => RadioListTile<String>(
                    title: Text(theme),
                    value: theme,
                    groupValue: _selectedTheme,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTheme = value;
                        });
                        widget.onThemeChanged(value);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      drawer: CustomSidebar(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOption(
                icon: Icons.person_outline,
                label: 'User Profile',
                onTap: () {
                  Navigator.pushNamed(context, '/user');
                },
              ),
              _buildOption(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Budgets',
                onTap: () {
                  Navigator.pushNamed(context, '/budgets');
                },
              ),
              _buildOption(
                icon: Icons.list_alt_outlined,
                label: 'Transactions',
                onTap: () {
                  if (Platform.isWindows) {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/win_transactions');
                  } else {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/transactions');
                  }
                },
              ),
              const Divider(),
              _buildOption(
                icon: Icons.person_outline,
                label: 'Category Page',
                onTap: () {
                  Navigator.pushNamed(context, '/categories');
                },
              ),
              _buildOption(
                icon: Icons.sync,
                label: 'Auto Sync Frequency',
                onTap: _showSyncFrequencyPicker,
              ),

              _buildOption(
                icon: Icons.color_lens_outlined,
                label: 'Change Theme',
                onTap: _showThemePicker,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
