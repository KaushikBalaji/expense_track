import 'package:expense_track/widgets/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return AppBar(
      toolbarHeight: 50,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
              : leading,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.brightness_6),
          tooltip: 'Toggle Theme',
          onPressed: () => MyApp.of(context)?.toggleTheme(),
        ),

        // 👤 User profile dropdown
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          offset: const Offset(0, kToolbarHeight),
          onSelected: (value) async {
            switch (value) {
              case 'user':
                Navigator.pushNamed(context, '/user');
                break;
              case 'signin':
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        contentPadding: const EdgeInsets.all(24),
                        content: const AuthDialogContent(),
                      ),
                );
                break;
              case 'settings':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings tapped')),
                );
                break;
              case 'logout':
                await Supabase.instance.client.auth.signOut();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logged out')));
                Navigator.pushNamed(context, '/dashboard');
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              if (user == null)
                const PopupMenuItem(
                  value: 'signin',
                  child: Text('Sign In / Sign Up'),
                ),
              if (user != null) ...[
                const PopupMenuItem(value: 'user', child: Text('User Profile')),
                PopupMenuItem(value: 'settings', child: Text('Settings')),
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            ];
          },
        ),

        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
