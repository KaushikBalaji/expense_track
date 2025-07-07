import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recurring_rule.dart';

class RecurringOptionsSheet extends StatefulWidget {
  final RecurringRule? initialRule;

  const RecurringOptionsSheet({super.key, this.initialRule, required});

  @override
  State<RecurringOptionsSheet> createState() => _RecurringOptionsSheetState();
}

class _RecurringOptionsSheetState extends State<RecurringOptionsSheet> {
  RecurrenceType _frequency = RecurrenceType.none;
  int _interval = 1;
  DateTime? _endDate;
  List<int> _selectedWeekdays = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialRule != null) {
      _frequency = widget.initialRule!.type;
      _interval = widget.initialRule!.interval;
      _endDate = widget.initialRule!.endDate;
      _selectedWeekdays = widget.initialRule!.weekdays ?? [];
    }

    if (_frequency == RecurrenceType.weekly && _selectedWeekdays.isEmpty) {
      final todayIndex = (DateTime.now().weekday + 6) % 7; // 0=Mon...6=Sun
      _selectedWeekdays = [todayIndex];
    }
  }

  void _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Widget _buildFrequencyOptions() {
    return Column(
      children:
          RecurrenceType.values.map((f) {
            return RadioListTile<RecurrenceType>(
              title: Text(f.name[0].toUpperCase() + f.name.substring(1)),
              value: f,
              groupValue: _frequency,
              onChanged: (value) => setState(() => _frequency = value!),
            );
          }).toList(),
    );
  }

  Widget _buildDailyOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Text("Every"),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: _interval.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) => _interval = int.tryParse(val) ?? 1,
                decoration: const InputDecoration(isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            const Text("day(s)"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text("Ends on:"),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _pickEndDate,
              child: Text(
                _endDate != null
                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                    : "Pick date",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyOptions() {
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Repeats on:"),
        Wrap(
          spacing: 6,
          children: List.generate(7, (index) {
            final dayIndex = (index + 1) % 7;
            final selected = _selectedWeekdays.contains(dayIndex);
            return FilterChip(
              label: Text(dayLabels[index]),
              selected: selected,
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    _selectedWeekdays.add(dayIndex);
                  } else {
                    _selectedWeekdays.remove(dayIndex);
                  }
                });
              },
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text("Every"),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: _interval.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) => _interval = int.tryParse(val) ?? 1,
                decoration: const InputDecoration(isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            const Text("week(s)"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text("Ends on:"),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _pickEndDate,
              child: Text(
                _endDate != null
                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                    : "Pick date",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Every"),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: _interval.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) => _interval = int.tryParse(val) ?? 1,
                decoration: const InputDecoration(isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            const Text("month(s)"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text("Ends on:"),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _pickEndDate,
              child: Text(
                _endDate != null
                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                    : "Pick date",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYearlyOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Every"),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: _interval.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) => _interval = int.tryParse(val) ?? 1,
                decoration: const InputDecoration(isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            const Text("year(s)"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text("Ends on:"),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _pickEndDate,
              child: Text(
                _endDate != null
                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                    : "Pick date",
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildConditionalFields() {
    switch (_frequency) {
      case RecurrenceType.daily:
        return _buildDailyOptions();
      case RecurrenceType.weekly:
        return _buildWeeklyOptions();
      case RecurrenceType.monthly:
        return _buildMonthlyOptions();
      case RecurrenceType.yearly:
        return _buildYearlyOptions();
      default:
        return const SizedBox.shrink();
    }
  }

  void _submit() {
    if (_frequency != RecurrenceType.none && _interval < 1) {
      _interval = 1;
    }

    if (_frequency == RecurrenceType.weekly && _selectedWeekdays.isEmpty) {
      final todayIndex = (DateTime.now().weekday + 6) % 7;
      _selectedWeekdays = [todayIndex];
    }
    final rule = RecurringRule(
      type: _frequency,
      interval: _interval,
      endDate: _endDate,
      weekdays:
          _frequency == RecurrenceType.weekly ? _selectedWeekdays : null,
    );
    Navigator.of(context).pop(rule);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 24.0,
          top: 16.0,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Recurring Options",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _buildFrequencyOptions(),
              const SizedBox(height: 16),
              _buildConditionalFields(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Apply"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
