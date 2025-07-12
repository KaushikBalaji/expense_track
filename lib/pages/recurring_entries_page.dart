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

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Transactions')),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final next = calculateNextOccurrence(entry);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ), // Or 500/700 based on your design
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            entry.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.indigo,
                              ),
                              // tooltip: 'Edit',
                              onPressed: () {
                                // Handle edit
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              // tooltip: 'Delete',
                              onPressed: () => _deleteRecurringEntry(entry.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              entry.type == 'Income'
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color:
                                  entry.type == 'Income'
                                      ? Colors.green
                                      : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₹${entry.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Next: ${DateFormat.yMMMd().format(next)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Repeats: ${entry.frequency} every ${entry.interval}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
