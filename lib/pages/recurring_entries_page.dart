import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/recurring_entry.dart'; // adjust path
import '../widgets/EntryDialog.dart'; // if needed later for edit

class RecurringEntriesPage extends StatefulWidget {
  const RecurringEntriesPage({super.key});

  @override
  State<RecurringEntriesPage> createState() => _RecurringEntriesPageState();
}

class _RecurringEntriesPageState extends State<RecurringEntriesPage> {
  late Box<RecurringEntry> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<RecurringEntry>('recurring_entries_box');
  }

  DateTime calculateNextOccurrence(RecurringEntry entry) {
    DateTime now = DateTime.now();
    DateTime start = entry.startDate;

    switch (entry.frequency) {
      case 'daily':
        int daysPassed = now.difference(start).inDays;
        int offset = ((daysPassed ~/ entry.interval) + 1) * entry.interval;
        return start.add(Duration(days: offset));

      case 'weekly':
        DateTime next = now;
        while (true) {
          if (entry.weekdays != null &&
              entry.weekdays!.contains(next.weekday % 7)) {
            break;
          }
          next = next.add(const Duration(days: 1));
        }
        return next;

      case 'monthly':
        int monthsPassed =
            (now.year - start.year) * 12 + (now.month - start.month);
        int nextMonthOffset =
            ((monthsPassed ~/ entry.interval) + 1) * entry.interval;
        return DateTime(start.year, start.month + nextMonthOffset, start.day);

      case 'yearly':
        int yearsPassed = now.year - start.year;
        int nextYear =
            start.year + ((yearsPassed ~/ entry.interval) + 1) * entry.interval;
        return DateTime(nextYear, start.month, start.day);

      default:
        return now;
    }
  }

  void _deleteRecurringEntry(String id) async {
    await _box.delete(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final entries = _box.values.toList();

    // Group by frequency
    final grouped = {
      'daily': <RecurringEntry>[],
      'weekly': <RecurringEntry>[],
      'monthly': <RecurringEntry>[],
      'yearly': <RecurringEntry>[],
      'other': <RecurringEntry>[],
    };

    for (var entry in entries) {
      if (grouped.containsKey(entry.frequency)) {
        grouped[entry.frequency]!.add(entry);
      } else {
        grouped['other']!.add(entry);
      }
    }

    final frequencyTitles = {
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'other': 'Other',
    };

    String _formatWeekdays(List<int> days) {
      const weekdayMap = {
        0: 'Sun',
        1: 'Mon',
        2: 'Tue',
        3: 'Wed',
        4: 'Thu',
        5: 'Fri',
        6: 'Sat',
      };
      // Sort for consistency (optional)
      final sorted = [...days]..sort();
      return sorted.map((d) => weekdayMap[d] ?? '').join(', ');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            children:
                grouped.entries.where((e) => e.value.isNotEmpty).map((group) {
                  final freq = group.key;
                  final entries = group.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        title: Text(
                          '${frequencyTitles[freq]} (${entries.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children:
                            entries.map((entry) {
                              final next = calculateNextOccurrence(entry);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        entry.type == 'Income'
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        color:
                                            entry.type == 'Income'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.title,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₹${entry.amount.toStringAsFixed(2)} • Every ${entry.interval}${entry.frequency == 'weekly' && entry.weekdays != null ? ' on ${_formatWeekdays(entry.weekdays!)}' : ''}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              'Next: ${DateFormat.yMMMd().format(next)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.indigo.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.indigo,
                                            ),
                                            onPressed: () {
                                              // TODO: Handle edit
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _deleteRecurringEntry(
                                                  entry.id,
                                                ),
                                          ),
                                        ],
                                      ),
                                      
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  );
                }).toList(),
          ),
          
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddDialog(forDate: DateTime.now()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddDialog({DateTime? forDate}) {
    showDialog(
      context: context,
      builder:
          (ctx) => EntryDialog(initialDate: forDate, mode: EntryDialogMode.add),
    );
  }
}
