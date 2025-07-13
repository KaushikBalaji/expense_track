import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  String _syncMode = 'auto'; // auto, manual, offline, paused
  String _syncFrequency = 'Daily'; // Daily, Weekly, Monthly, custom:3
  final TextEditingController _customController = TextEditingController();

  DateTime? _lastSync;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSyncPrefs();
  }

  Future<void> _loadSyncPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _syncMode = prefs.getString('syncMode') ?? 'auto';
      _syncFrequency = prefs.getString('syncFrequency') ?? 'Daily';

      final lastMillis = prefs.getInt('lastSyncTimestamp');
      _lastSync =
          lastMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(lastMillis)
              : null;

      if (_syncFrequency.startsWith('custom:')) {
        _customController.text = _syncFrequency.split(':').last;
      }
      _loading = false;
    });
  }

  Future<void> _saveSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();

    String finalFreq = _syncFrequency;
    if (_syncMode == 'auto' && _syncFrequency == 'custom') {
      final customVal = int.tryParse(_customController.text.trim());
      if (customVal == null || customVal < 1) {
        _showError('Enter a valid number of days');
        return;
      }
      finalFreq = 'custom:$customVal';
    }

    await prefs.setString('syncMode', _syncMode);
    await prefs.setString('syncFrequency', finalFreq);

    setState(() => _syncFrequency = finalFreq);
    _showSuccess('Sync settings saved');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  Widget _buildSyncModeOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sync Mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...[
          {'label': 'Auto Sync', 'value': 'auto'},
          {'label': 'Manual Only', 'value': 'manual'},
          {'label': 'Paused', 'value': 'paused'},
          {'label': 'Offline Mode (local only)', 'value': 'offline'},
        ].map((option) {
          return RadioListTile<String>(
            title: Text(option['label']!),
            value: option['value']!,
            groupValue: _syncMode,
            onChanged: (value) => setState(() => _syncMode = value!),
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildAutoSyncOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Auto-Sync Frequency',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...['Daily', 'Weekly', 'Monthly'].map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _syncFrequency,
            onChanged: (val) {
              setState(() {
                _syncFrequency = val!;
                _customController.clear();
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
        RadioListTile<String>(
          value: 'custom',
          groupValue:
              _syncFrequency.startsWith('custom') ? 'custom' : _syncFrequency,
          onChanged: (_) => setState(() => _syncFrequency = 'custom'),
          dense: true,
          contentPadding: EdgeInsets.zero,
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
                    isDense: true,
                  ),
                  onTap: () => setState(() => _syncFrequency = 'custom'),
                ),
              ),
              const SizedBox(width: 8),
              const Text('days'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    String description;
    switch (_syncMode) {
      case 'auto':
        description =
            'Your data will be synced to the cloud automatically '
            'based on the frequency you choose.';
        break;
      case 'manual':
        description =
            'Sync will only happen when you manually press the Sync Now button. \nPlease use in moderation as Cloud syncs are precious 🥺';
        break;
      case 'paused':
        description =
            'Auto sync is temporarily paused. You can resume sync anytime.';
        break;
      case 'offline':
        description =
            'App will run in full offline mode. No cloud sync will happen.';
        break;
      default:
        description = '';
    }

    final now = DateTime.now();
    final last = _lastSync?.toLocal();

    int intervalDays = 0;
    if (_syncFrequency.startsWith('custom:')) {
      intervalDays = int.tryParse(_syncFrequency.split(':').last) ?? 0;
    } else {
      intervalDays =
          {'Daily': 1, 'Weekly': 7, 'Monthly': 30}[_syncFrequency] ?? 0;
    }

    final next =
        (_syncMode == 'auto' && last != null)
            ? last.add(Duration(days: intervalDays))
            : null;

    return Card(
      elevation: 2,
      //   color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🛈 Sync Mode Info',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            const Divider(),
            const Text(
              '📅 Sync Status',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Sync: ${last != null ? last.toString().split('.').first : 'Never'}',
            ),
            if (_syncMode == 'auto' && next != null)
              Text('Next Sync: ${next.toString().split('.').first}'),
            if (_syncMode == 'auto') Text('Frequency: $_syncFrequency'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Settings')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child:
                    isWide
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildSyncModeOptions()),
                                const SizedBox(width: 32),
                                if (_syncMode == 'auto')
                                  Expanded(child: _buildAutoSyncOptions()),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Info card
                                Expanded(child: _buildInfoCard()),
                                const SizedBox(width: 24),
                                // Buttons
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _saveSyncSettings,
                                      child: const Text('Save Settings'),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed:
                                          _syncMode == 'paused' ||
                                                  _syncMode == 'offline'
                                              ? null
                                              : () => _showSuccess(
                                                'Manual sync triggered!',
                                              ),
                                      icon: const Icon(Icons.sync),
                                      label: const Text('Sync Now'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                        : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildSyncModeOptions(),
                            const SizedBox(height: 24),
                            if (_syncMode == 'auto') _buildAutoSyncOptions(),
                            const SizedBox(height: 32),
                            _buildInfoCard(),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _saveSyncSettings,
                              child: const Text('Save Settings'),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed:
                                  _syncMode == 'paused' ||
                                          _syncMode == 'offline'
                                      ? null
                                      : () => _showSuccess(
                                        'Manual sync triggered!',
                                      ),
                              icon: const Icon(Icons.sync),
                              label: const Text('Sync Now'),
                            ),
                          ],
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}
