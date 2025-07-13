import 'package:flutter/material.dart';

class AutoSyncFrequencySelector extends StatelessWidget {
  final String selected;
  final TextEditingController controller;
  final void Function(String) onChanged;

  const AutoSyncFrequencySelector({
    super.key,
    required this.selected,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = selected.startsWith('custom');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Auto-Sync Frequency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...['Daily', 'Weekly', 'Monthly'].map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selected,
            onChanged: (val) {
              controller.clear();
              onChanged(val!);
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
        RadioListTile<String>(
          value: 'custom',
          groupValue: isCustom ? 'custom' : selected,
          onChanged: (_) => onChanged('custom'),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              const Text('Every'),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter days',
                    isDense: true,
                  ),
                  onTap: () => onChanged('custom'),
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
}
