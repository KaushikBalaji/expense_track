import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import 'ShowEntryCard.dart';
import 'transactions_details.dart';
import 'EntryDialog.dart'; // Make sure this is imported

class EntryListSection extends StatefulWidget {
  final List<Entry> entries;
  final Function(Entry) onDelete;
  final Function(Entry)? onTap;
  final Animation<Offset>? slideAnimation;

  const EntryListSection({
    super.key,
    required this.entries,
    required this.onDelete,
    this.onTap,
    this.slideAnimation,
  });

  @override
  State<EntryListSection> createState() => _EntryListSectionState();
}

class _EntryListSectionState extends State<EntryListSection> {
  DateTime _selectedMonth = DateTime.now();
  Entry? _selectedEntry;

  bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  String _formattedDay(DateTime date) {
    return DateFormat('MMMM d, EEEE').format(date);
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
  }

  void _selectMonthFromPicker() async {
    int selectedYear = _selectedMonth.year;
    int selectedMonth = _selectedMonth.month;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              // Add this wrapper
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => setModalState(() => selectedYear--),
                        ),
                        Text(
                          '$selectedYear',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () => setModalState(() => selectedYear++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(12, (index) {
                        final monthIndex = index + 1;
                        final isSelected = monthIndex == selectedMonth;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMonth = DateTime(
                                selectedYear,
                                monthIndex,
                              );
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade200,
                            ),
                            child: Text(
                              _monthName(monthIndex),
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Map<DateTime, List<Entry>> _groupEntriesByDay(List<Entry> entries) {
    Map<DateTime, List<Entry>> grouped = {};
    for (var entry in entries) {
      final key = DateTime(entry.date.year, entry.date.month, entry.date.day);
      grouped.putIfAbsent(key, () => []).add(entry);
    }
    return grouped;
  }

  void _handleEntryTap(Entry entry, {bool forceDialog = false}) {
  if (!isMobile && !forceDialog) {
    setState(() {
      _selectedEntry = entry;
    });
  } else {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => EntryDialog(
        initialEntry: entry,
        mode: EntryDialogMode.view,
        onSuccess: () {
          setState(() {}); // refresh if needed
        },
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final selectedEntries =
        widget.entries
            .where(
              (entry) =>
                  entry.date.year == _selectedMonth.year &&
                  entry.date.month == _selectedMonth.month,
            )
            .toList();

    final groupedByDay = _groupEntriesByDay(selectedEntries);
    final sortedDays =
        groupedByDay.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // Newest first

    final entryList = ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final entries = groupedByDay[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                _formattedDay(day),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...entries.map(
              (entry) => EntryCard(
                entry: entry,
                // onDelete: () {
                //   setState(() {
                //     entry.delete();
                //   });
                // },
                onTap: () => _handleEntryTap(entry, forceDialog: true),
              ),
            ),
          ],
        );
      },
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () => _changeMonth(-1),
              ),
              GestureDetector(
                onTap: _selectMonthFromPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 2, child: entryList),
              if (!isMobile && _selectedEntry != null)
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: TransactionDetailsPanel(
                    entry: _selectedEntry!,
                    onClose: () => setState(() => _selectedEntry = null),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
