import 'package:flutter/material.dart';
import '../models/entry.dart';
import 'ShowEntryCard.dart';

class EntryListSection extends StatefulWidget {
  final List<Entry> entries;
  final Function(Entry) onDelete;

  const EntryListSection({
    super.key,
    required this.entries,
    required this.onDelete,
  });

  @override
  State<EntryListSection> createState() => _EntryListSectionState();
}

class _EntryListSectionState extends State<EntryListSection> {
  final Set<String> _expandedMonths = {};

  @override
  void initState() {
    super.initState();
    _expandAllMonths();
  }

  void _expandAllMonths() {
    final grouped = _groupEntriesByMonth(widget.entries);
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aMonth = _monthIndex(a.split(' ')[0]).toString().padLeft(2, '0');
        final bMonth = _monthIndex(b.split(' ')[0]).toString().padLeft(2, '0');
        final aDate = DateTime.parse('${a.split(' ')[1]}-$aMonth-01');
        final bDate = DateTime.parse('${b.split(' ')[1]}-$bMonth-01');
        return bDate.compareTo(aDate);
      });

    // Expanding all months by default
    setState(() {
      _expandedMonths.addAll(sortedKeys);
    });
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  int _monthIndex(String monthName) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months.indexOf(monthName) + 1;
  }

  Map<String, List<Entry>> _groupEntriesByMonth(List<Entry> entries) {
    Map<String, List<Entry>> grouped = {};
    for (var entry in entries) {
      final key = '${_monthName(entry.date.month)} ${entry.date.year}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    for (var entry in grouped.entries) {
      entry.value.sort((a, b) => b.date.compareTo(a.date));
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupEntriesByMonth(widget.entries);
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aMonth = _monthIndex(a.split(' ')[0]).toString().padLeft(2, '0');
        final bMonth = _monthIndex(b.split(' ')[0]).toString().padLeft(2, '0');
        final aDate = DateTime.parse('${a.split(' ')[1]}-$aMonth-01');
        final bDate = DateTime.parse('${b.split(' ')[1]}-$bMonth-01');
        return bDate.compareTo(aDate);
      });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final monthKey = sortedKeys[index];
        final isExpanded = _expandedMonths.contains(monthKey);
        final entries = grouped[monthKey]!;

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedMonths.remove(monthKey);
                  } else {
                    _expandedMonths.add(monthKey);
                  }
                });
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        monthKey,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (index != 0)
              const Padding(
                padding: EdgeInsets.only(top: 6.0, bottom: 10.0),
                child: Divider(thickness: 1.0),
              ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                children: isExpanded
                    ? entries.map((entry) {
                  return EntryCard(
                    entry: entry,
                    onDelete: () => widget.onDelete(entry),
                  );
                }).toList()
                    : [],
              ),
            ),
          ],
        );
      },
    );
  }
}
