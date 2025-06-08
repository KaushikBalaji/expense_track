import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';
import 'EntryDialog.dart';

class EntryListSection extends StatefulWidget {
  final List<Entry> entries;
  final Function(Entry) onDelete;
  final Function(Entry)? onTap;

  const EntryListSection({
    super.key,
    required this.entries,
    required this.onDelete,
    this.onTap,
  });

  @override
  State<EntryListSection> createState() => _EntryListSectionState();
}

class _EntryListSectionState extends State<EntryListSection> {
  DateTime _selectedMonth = DateTime.now();

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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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

  void _handleEntryTap(Entry entry) {
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

  Widget _buildOverviewSection(List<Entry> entries) {
    double income = entries
        .where((e) => e.type == 'Income')
        .fold(0.0, (sum, e) => sum + e.amount);
    double expense = entries
        .where((e) => e.type == 'Expense')
        .fold(0.0, (sum, e) => sum + e.amount);
    double total = income - expense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _amountCard('Income', income, Colors.blue),
          _amountCard('Expense', expense, Colors.red),
          _amountCard('Total', total, Colors.black),
        ],
      ),
    );
  }

  Widget _amountCard(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          '${label == "Expense" ? "-" : ""}₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(Entry entry) {
    final isIncome = entry.type == 'Income';
    final amountColor = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade100,
          child: Icon(Icons.category, color: Colors.grey.shade800),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.title.isNotEmpty)
              Text(
                entry.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '' : '-'}₹${entry.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: amountColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.jm().format(entry.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _handleEntryTap(entry),
      ),
    );
  }

  Widget _buildMonthNavigationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeMonth(-1),
            ),
            GestureDetector(
              onTap: _selectMonthFromPicker,
              child: Text(
                '${_monthName(_selectedMonth.month)} ${_selectedMonth.year}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedEntries =
        widget.entries
            .where(
              (e) =>
                  e.date.year == _selectedMonth.year &&
                  e.date.month == _selectedMonth.month,
            )
            .toList();

    final groupedByDay = _groupEntriesByDay(selectedEntries);
    final sortedDays =
        groupedByDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        const SizedBox(height: 10),
        _buildOverviewSection(selectedEntries),
        _buildMonthNavigationBar(),
        Expanded(
          child:
              sortedDays.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No entries this month',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: sortedDays.length,
                    itemBuilder: (context, index) {
                      final day = sortedDays[index];
                      final entries = groupedByDay[day]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                            child: Text(
                              _formattedDay(day),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...entries.map(_buildEntryCard),
                        ],
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
