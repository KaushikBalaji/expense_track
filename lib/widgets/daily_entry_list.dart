import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import 'ShowEntryCard.dart';
import 'EntryDialog.dart';

class DailyEntryListPanel extends StatefulWidget {
  // final List<Entry> allEntries;
  final DateTime initialDate;
  final Function(Entry) onDelete;
  final Function()? onChanged;

  const DailyEntryListPanel({
    Key? key,
    // required this.allEntries,
    required this.initialDate,
    required this.onDelete,
    this.onChanged,
  }) : super(key: key);

  @override
  State<DailyEntryListPanel> createState() => _DailyEntryListPanelState();
}

class _DailyEntryListPanelState extends State<DailyEntryListPanel> {
  late DateTime _selectedDate;
  List<Entry> _entries = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final box = Hive.box<Entry>('entriesBox');
    final allEntries = box.values.toList();
    final filtered =
        allEntries.where((entry) {
          final d = entry.date;
          return d.year == _selectedDate.year &&
              d.month == _selectedDate.month &&
              d.day == _selectedDate.day;
        }).toList();
    setState(() {
      _entries = filtered;
    });
    widget.onChanged?.call(); // In case parent wants to react
  }

  String get _formattedDate =>
      DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);

  List<Entry> get _entriesForSelectedDate {
    return _entries.where((entry) {
      return entry.date.year == _selectedDate.year &&
          entry.date.month == _selectedDate.month &&
          entry.date.day == _selectedDate.day;
    }).toList();
  }

  void _changeDate(int offset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offset));
    });
    _loadEntries();
  }

  void _openAddDialog() async {
    final result = await showDialog(
      context: context,
      builder:
          (ctx) => EntryDialog(
            initialDate: _selectedDate,
            mode: EntryDialogMode.add,
          ),
    );

    if (result == true) {
      await _loadEntries(); // Refresh this panel
      widget.onChanged?.call(); // Notify parent to refresh day cell
    }
  }

  void _handleDelete(Entry entry) async {
    await widget.onDelete(entry); // Delete and inform parent
    await _loadEntries(); // Refresh this panel
    widget.onChanged?.call(); // Notify parent to reload calendar
  }

  void _handleTapEntry(Entry entry) async {
    showDialog(
      context: context,
      builder:
          (_) => EntryDialog(
            initialEntry: entry,
            mode: EntryDialogMode.view,
            onSuccess: (action) {
              if (action == EntryDialogAction.deleted) {
                widget.onDelete(entry); // Notify TransactionsPage
              } else if (action == EntryDialogAction.edited) {
                setState(() {}); // Just refresh locally if needed
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entriesForSelectedDate;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _changeDate(-1),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _formattedDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => _changeDate(1),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.add_circle_rounded, size: 28),
                    tooltip: 'Add Entry',
                    onPressed: _openAddDialog,
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),
            const Divider(height: 0, thickness: 1),

            // Entry List
            Expanded(
              child:
                  entries.isEmpty
                      ? const Center(
                        child: Text(
                          'No entries for this date.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder:
                            (ctx, i) => EntryCard(
                              entry: _entries[i],
                              onTap: () => _handleTapEntry(_entries[i]),
                              // onDelete:
                              //     () => _handleDelete(
                              //       _entries[i],
                              //     ), // Optional delete icon
                            ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
