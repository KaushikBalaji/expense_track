import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/entry.dart';

class TransactionDetailsPanel extends StatelessWidget {
  final Entry entry;
  final VoidCallback onClose;

  const TransactionDetailsPanel({
    super.key,
    required this.entry,
    required this.onClose,
  });

  bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    return isMobile
        ? _buildMobileDialog(context)
        : _buildDesktopSidePanel(context);
  }

  Widget _buildMobileDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Transaction Details'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300, maxWidth: 350),
        child: SingleChildScrollView(
          child: _buildTransactionDetails(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDesktopSidePanel(BuildContext context) {
    return Container(
      width: 400,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const Divider(),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: _buildTransactionDetails(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailItem('Title', entry.title),
        _detailItem('Amount', '₹${entry.amount.toStringAsFixed(2)}'),
        _detailItem(
          'Type',
          entry.type == EntryType.expense ? 'Expense' : 'Income',
        ),
        _detailItem(
          'Date',
          '${entry.date.month}/${entry.date.day}/${entry.date.year}',
        ),
        _detailItem('Category', entry.tag),
        const SizedBox(height: 12),
        Text(
          'Edit functionality coming soon...',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
