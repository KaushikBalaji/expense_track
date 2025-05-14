import 'package:flutter/material.dart';

class RightSideTransactionPanel extends StatelessWidget {
  final VoidCallback onClose;
  final Widget Function(BuildContext) buildContent;

  const RightSideTransactionPanel({
    super.key,
    required this.onClose,
    required this.buildContent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius:
              const BorderRadius.only(topLeft: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: buildContent(context),
              ),
            ),
          ),

          // Bottom action
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 12),
              child: TextButton(
                onPressed: onClose,
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
