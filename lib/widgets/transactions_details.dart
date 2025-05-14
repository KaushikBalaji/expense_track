import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/entry.dart';
import 'sidepanel/mobile_right_panel.dart';
import 'sidepanel/windows_right_panel.dart';

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
    print(
      '[TransactionDetailsPanel] build called. isMobile=$isMobile, Entry Title=${entry.title}',
    );
    if (isMobile) {
      // Show the dialog (only once, not every build)
      // So you should call this from a button press or somewhere else
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _buildMobileDialog(context);
      });

      // Return an empty widget or a placeholder screen
      return const SizedBox.shrink();
    } else {
      return DesktopRightTransactionPanel(
        isPanelVisible: true,
        onClose: onClose,
        buildContent: _buildTransactionDetails,
      );
    }
  }

  void _buildMobileDialog(BuildContext context) {
    print('[TransactionDetailsPanel] Building mobile dialog');
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: offsetAnimation,
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.7,
              heightFactor: 0.6,
              child: RightSideTransactionPanel(
                onClose: () => Navigator.of(context).pop(),
                buildContent: _buildTransactionDetails, // Your function
              ),
            ),
          ),
        );
      },
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
    print(
      '[TransactionDetailsPanel] Building transaction details for ${entry.title}',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailItem('Title', entry.title),
        _detailItem('Amount', '₹${entry.amount.toStringAsFixed(2)}'),
        _detailItem('Type',entry.type),
        _detailItem(
          'Date',
          '${entry.date.month}/${entry.date.day}/${entry.date.year}',
        ),
        _detailItem('Category', entry.tag),
        const SizedBox(height: 12),
        Text(
          'Edit functionality coming soon...',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
