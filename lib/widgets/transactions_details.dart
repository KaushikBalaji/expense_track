import 'package:flutter/material.dart';
import '../models/entry.dart';
import 'sidepanel.dart'; // import the new unified widget

class TransactionDetailsPanel extends StatelessWidget {
  final Entry entry;
  final VoidCallback onClose;

  const TransactionDetailsPanel({
    super.key,
    required this.entry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveSidePanel(
      isVisible: true,
      onClose: onClose,
      buildContent: _buildTransactionDetails,
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(BuildContext context) {
        print('Sidepanel entry: ${entry.id}, ${entry.amount}, ${entry.date}, ${entry.tag}, ${entry.title}, ${entry.type}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoTile(context, Icons.title, 'Title', entry.title),
        _infoTile(
          context,
          Icons.attach_money,
          'Amount',
          '₹${entry.amount.toStringAsFixed(2)}',
        ),
        _infoTile(context, Icons.category, 'Category', entry.tag),
        _infoTile(context, Icons.swap_vert, 'Type', entry.type),
        _infoTile(
          context,
          Icons.date_range,
          'Date',
          '${entry.date.day}/${entry.date.month}/${entry.date.year}',
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              // Open edit mode
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Transaction'),
          ),
        ),
      ],
    );
  }

  Widget _infoTile(BuildContext context, icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
