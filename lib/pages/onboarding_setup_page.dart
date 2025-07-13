import 'package:flutter/material.dart';
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
  String _selectedSyncMode = 'auto';
  String _selectedFrequency = 'Daily';
  final TextEditingController _customDaysController = TextEditingController();

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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedSetup', true);

    // Navigate to home screen or main app
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/settings');
    }
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Initial Setup')),
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
                      Text("To be implemented: Let user select default active categories."),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Continue to App'),
                  onPressed: syncPrefConfirmed && categoryPrefConfirmed
                      ? _completeSetup
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
