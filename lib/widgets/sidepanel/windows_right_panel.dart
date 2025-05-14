import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DesktopRightTransactionPanel extends StatelessWidget {
  final bool isPanelVisible;
  final VoidCallback onClose;
  final Widget Function(BuildContext) buildContent;

  const DesktopRightTransactionPanel({
    super.key,
    required this.isPanelVisible,
    required this.onClose,
    required this.buildContent,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          onClose(); // Close on Escape
        }
      },
      child: Container(
        width: 500,
        height: 700,
        child: Stack(
          children: [
            // The sliding side panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: isPanelVisible ? 16 : -350,
              top: MediaQuery.of(context).size.height * 0.2,
              bottom: MediaQuery.of(context).size.height * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  elevation: 12,
                  color: Theme.of(context).colorScheme.surface,
                  child: SizedBox(
                    width: 350,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Theme.of(context).colorScheme.primary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Transaction Details",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: onClose,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              child: buildContent(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
