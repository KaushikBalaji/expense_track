import 'package:expense_track/services/supabase_services.dart';
import 'package:expense_track/widgets/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  //final _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String? username = Supabase.instance.client.auth.currentUser?.email
        .toString()
        .substring(
          0,
          Supabase.instance.client.auth.currentUser?.email
              .toString()
              .lastIndexOf('@'),
        );
    final _dispName = username != null ? '$username' : 'Guest User';

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),

            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Expense Tracker",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _dispName,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          SidebarItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            onTap: () {
              print('Dashboard tapped');
              Navigator.of(context).pop(); // close the drawer
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          SidebarItem(
            icon: Icons.list,
            label: "Transactions",
            onTap: () {
              Navigator.of(context).pop(); // close the drawer
              Navigator.pushNamed(context, '/transactions');
            },
          ),
          SidebarItem(
            icon: Icons.label,
            label: "Tags",
            onTap: () => print("Tags tapped"),
          ),
          SidebarItem(
            icon: Icons.settings,
            label: "Settings",
            onTap: () => print("Settings tapped"),
          ),
          SidebarItem(
            icon: Icons.account_balance_wallet,
            label: "Budgets",
            onTap: () {
              Navigator.pushNamed(context, '/budgets');
            },
          ),
          SizedBox(height: 20),

          SidebarItem(
            icon: Icons.sync,
            label: "Sync to cloud",
            onTap: () async {
              Navigator.of(context).pop(); // close drawer
              Navigator.pushNamed(context, '/syncstatus');
            },
          ),

          const Spacer(),
          const Divider(),
          SidebarItem(
            icon: Icons.logout,
            label: "Logout",
            onTap: () async {
              final service = SupabaseService();

              //await handleLogout();
              try {
                // await service.signOut();
                await service.handleLogout(context);
              } catch (e) {
                // debugPrint('Sign out failed to sync with server: $e');

                final message = e.toString().replaceFirst('Exception: ', '');
                debugPrint('Logout failed: $message');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $message')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

void showAuthOverlay(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder:
        (context) => Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AuthDialogContent(onClose: () => overlayEntry.remove()),
            ),
          ),
        ),
  );

  overlay.insert(overlayEntry);
}

void showAuthDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AuthDialogContent(), // You'll define this
          ),
        ),
  );
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500, fontSize: 15),),
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        onTap();
      },
    );
  }
}
