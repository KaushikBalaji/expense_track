import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResponsiveSidePanel extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onClose;
  final Widget Function(BuildContext) buildContent;

  const ResponsiveSidePanel({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.buildContent,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final panelContent = Material(
      elevation: 16,
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                IconButton(icon: Icon(Icons.close, color: Theme.of(context).colorScheme.inversePrimary), onPressed: onClose),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(child: buildContent(context)),
            ),
          ),
        ],
      ),
    );

    // Wrap in a SizedBox and Align for 50% height positioning
    final panel = Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: isDesktop ? height * 0.65 : height * 0.55, // Set to 50% height
        width: isDesktop ? 350 : width * 0.7,
        child: panelContent,
      ),
    );

    return isDesktop
        ? KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              onClose();
            }
          },
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: isVisible ? 16 : -400,
                top: 0,
                bottom: 0,
                child: panel,
              ),
            ],
          ),
        )
        : Stack(
          children: [
            if (isVisible)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: isVisible ? 16 : -400,
                top: 0,
                bottom: 0,
                child: panel,
              ),
          ],
        );
  }
}

