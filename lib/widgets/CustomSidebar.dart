import 'package:flutter/material.dart';
import '../pages/transactions_page.dart';
import '../pages/dashboard_page.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SidebarItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            onTap: (){
              print('Dashboard tapped');
              Navigator.of(context).pop(); // close the drawer
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DashboardPage())
              );
            },
          ),
          SidebarItem(
            icon: Icons.list,
            label: "Transactions",
            onTap: (){
              Navigator.of(context).pop(); // close the drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransactionsPage(title: 'All Transactions',)),
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
          const Spacer(),
          const Divider(),
          SidebarItem(
            icon: Icons.logout,
            label: "Logout",
            onTap: () => print("Logout tapped"),
          ),
        ],
      ),
    );
  }
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
