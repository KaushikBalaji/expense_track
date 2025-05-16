import 'package:flutter/material.dart';
import '../models/entry.dart';

class EntryCard extends StatelessWidget {
  final Entry entry;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const EntryCard({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == 'income'; 
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: ListTile(
                leading: Icon(
                  isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isIncome ? Colors.green : Colors.red,
                ),
                title: Text(
                  entry.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year} - ${entry.tag}',
                ),
                trailing: Text(
                  '${isIncome ? '+' : '-'} ₹ ${entry.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                tooltip: 'Delete Entry',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Entry'),
                      content: const Text('Are you sure you want to delete this item?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    onDelete();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
}
