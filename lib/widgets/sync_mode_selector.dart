import 'package:flutter/material.dart';

class SyncModeSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  const SyncModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {'label': 'Auto Sync', 'value': 'auto'},
      {'label': 'Manual Only', 'value': 'manual'},
      {'label': 'Paused', 'value': 'paused'},
      {'label': 'Offline Mode (local only)', 'value': 'offline'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sync Mode',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...options.map((opt) {
          return RadioListTile<String>(
            value: opt['value']!,
            groupValue: selected,
            title: Text(opt['label']!),
            onChanged: (val) => onChanged(val!),
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }
}
