import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/entry.dart';
import 'transactions_details.dart';

class TransactionDetailsOverlay extends StatelessWidget {
  final Entry entry;
  final VoidCallback onClose;
  final Animation<Offset> slideAnimation;

  const TransactionDetailsOverlay({
    super.key,
    required this.entry,
    required this.onClose,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(), // Allows listening for keyboard input
      onKey: (RawKeyEvent event) {
        if (event.runtimeType == RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          onClose(); // Handles Escape key to close panel
        }
      },
      child: Stack(
        children: [
          // Background overlay (click to dismiss)
          GestureDetector(
            onTap: onClose,
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Slide-in side panel
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: slideAnimation,
              child: ClipRRect(
                 borderRadius : BorderRadius.only(
                  topLeft: Radius.circular(20),  // Rounded top-left corner
                  bottomLeft: Radius.circular(20), // Rounded bottom-left corner
                ),
                child: Material(
                  elevation: 10,
                  color: Theme.of(context).colorScheme.surface,
                  child: SizedBox(
                    width: 400,
                    height: double.infinity,
                    // 🌟 Added Container with theme-based background and column layout
                    child: Container(
                      color: Theme.of(context).colorScheme.surface, // ✨ Background matching sidebar style
                      child: Column(
                        children: [
                          // 🌟 Top panel header similar to DrawerHeader
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: Theme.of(context).colorScheme.primary,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Transaction Details",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: onClose,
                                ),
                              ],
                            ),
                          ),

                          // 🌟 Main content from existing TransactionDetailsPanel
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0), // ✨ Padding for cleaner layout
                              child: TransactionDetailsPanel(
                                entry: entry,
                                onClose: onClose,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ),
              ),

            ),
          ),
        ],
      ),
    );
  }
}
