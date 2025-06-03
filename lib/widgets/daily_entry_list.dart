import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import 'ShowEntryCard.dart';
import 'EntryDialog.dart';

class DailyEntryListPanel extends StatefulWidget {
  final List<Entry> allEntries;
  final DateTime initialDate;
  final Function(Entry) onDelete;
  final Function()? onChanged; // to trigger parent reload

  const DailyEntryListPanel({
    Key? key,
    required this.allEntries,
    required this.initialDate,
    required this.onDelete,
    this.onChanged,
  }) : super(key: key);

  @override
  State<DailyEntryListPanel> createState() => _DailyEntryListPanelState();
}

class _DailyEntryListPanelState extends State<DailyEntryListPanel> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  String get _formattedDate =>
      DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);

  List<Entry> get _entriesForSelectedDate {
    return widget.allEntries.where((entry) {
      return entry.date.year == _selectedDate.year &&
          entry.date.month == _selectedDate.month &&
          entry.date.day == _selectedDate.day;
    }).toList();
  }

  void _changeDate(int offset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offset));
    });
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => EntryDialog(
        initialDate: _selectedDate,
        mode: EntryDialogMode.add,
        onSuccess: () {
          widget.onChanged?.call();
        },
      ),
    );
  }

  void _handleTapEntry(Entry entry) {
    showDialog(
      context: context,
      builder: (ctx) => EntryDialog(
        initialEntry: entry,
        mode: EntryDialogMode.view,
        onSuccess: () {
          widget.onChanged?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entriesForSelectedDate;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () => _changeDate(-1),
                  ),
                  Text(
                    _formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () => _changeDate(1),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _openAddDialog,
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('No entries for this date.'))
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (ctx, i) => EntryCard(
                        entry: entries[i],
                        onTap: () => _handleTapEntry(entries[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
