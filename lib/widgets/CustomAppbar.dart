
import 'package:flutter/material.dart';
import '../main.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isInternetAvailable = true;

  @override
  void initState() {
    super.initState();
    //checkInternet();
  }


  @override
  Widget build(BuildContext context) {

    return AppBar(
      toolbarHeight: 50,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : widget.leading,
      title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.brightness_6),
          tooltip: 'Toggle Theme',
          onPressed: () => MyApp.of(context)?.toggleTheme(),
        ),
        ...?widget.actions,
      ],
    );
  }
}

