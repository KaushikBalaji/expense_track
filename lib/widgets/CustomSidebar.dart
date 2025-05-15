import 'package:expense_track/widgets/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/entry.dart';
import '../pages/sync_status_page.dart';
import '../pages/transactions_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/supabase_auth_page.dart';
import '../services/supabase_services.dart';

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
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Logged in as:\n${username ?? 'Unknown'}"),
          ),

          SidebarItem(
            icon: Icons.login,
            label: "User Auth",
            onTap: () {
              if (username == null) {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop(); // Close the drawer
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder:
                      (context) => Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 24,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                        ),
                        child: const AuthDialogContent(),
                      ),
                );
              } else {
                print('Already logged in as $username');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              }
            },
            // onTap: () {
            //   if(Navigator.canPop(context))
            //     Navigator.of(context).pop(); // close drawer
            //   showAuthOverlay(context);
            // },
          ),

          SidebarItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            onTap: () {
              print('Dashboard tapped');
              Navigator.of(context).pop(); // close the drawer
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DashboardPage()));
            },
          ),
          SidebarItem(
            icon: Icons.list,
            label: "Transactions",
            onTap: () {
              Navigator.of(context).pop(); // close the drawer
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => const TransactionsPage(title: 'All Transactions'),
                ),
              );
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
          SizedBox(height: 20),

          SidebarItem(
            icon: Icons.sync,
            label: "Sync to cloud",
            onTap: () async {
              // final contextRef = context; // cache the context safely
              //
              // final box = Hive.isBoxOpen('entriesbox')
              //     ? Hive.box<Entry>('entriesbox')
              //     : await Hive.openBox<Entry>('entriesbox');
              //
              // await SupabaseService.syncHiveToSupabase(box);
              //
              // if (!contextRef.mounted) return; // safely exit if widget is gone

              Navigator.of(context).pop(); // close drawer
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SyncStatusPage()));
            },
          ),

          const Spacer(),
          const Divider(),
          SidebarItem(
            icon: Icons.logout,
            label: "Logout",
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
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
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        onTap();
      },
    );
  }
}
