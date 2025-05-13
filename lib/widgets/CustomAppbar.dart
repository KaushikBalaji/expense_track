import 'package:flutter/material.dart';
import '../main.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading; // ✅ New property to allow custom leading widget

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 50,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      )
          : leading, // ✅ Use custom leading if provided
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.brightness_6),
          tooltip: 'Toggle Theme',
          onPressed: () => MyApp.of(context)?.toggleTheme(),
        ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
