import 'dart:io';

import 'package:expense_track/services/supabase_services.dart';
import 'package:expense_track/widgets/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class CustomSidebar extends StatefulWidget {
  const CustomSidebar({super.key});

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final hasConnection = await hasInternetConnection();
    if (mounted) {
      setState(() {
        _hasInternet = hasConnection;
      });
      debugPrint('Network status: $hasConnection');
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final response = await http
            .get(Uri.parse('https://example.com'))
            .timeout(const Duration(seconds: 3));
        return response.statusCode == 200;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? username = Supabase.instance.client.auth.currentUser?.email
        ?.substring(
          0,
          Supabase.instance.client.auth.currentUser?.email?.lastIndexOf('@') ??
              0,
        );
    final _dispName = username ?? 'Guest User';

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  tooltip: '',
                  offset: const Offset(50, 50),
                  iconSize: 56,
                  icon: CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    child: Icon(
                      Icons.account_circle,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onSelected: (value) async {
                    final service = SupabaseService();
                    switch (value) {
                      case 'user':
                        Navigator.pushNamed(context, '/user');
                        break;
                      case 'signin':
                        if (!_hasInternet) {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('No Internet Connection'),
                                  content: const Text(
                                    'Please check your connection and try again.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                          );
                          break;
                        }
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
                        Navigator.pushNamed(context, '/settings');
                        break;
                      case 'logout':
                        try {
                          await service.handleLogout(context);
                        } catch (e) {
                          final message = e.toString().replaceFirst(
                            'Exception: ',
                            '',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout failed: $message')),
                          );
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      if (Supabase.instance.client.auth.currentUser == null)
                        const PopupMenuItem(
                          value: 'signin',
                          child: Text('Sign In / Sign Up'),
                        ),
                      if (Supabase.instance.client.auth.currentUser !=
                          null) ...[
                        const PopupMenuItem(
                          value: 'user',
                          child: Text('User Profile'),
                        ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: Text('Settings'),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Text('Logout'),
                        ),
                      ],
                    ];
                  },
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dispName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expense Tracker',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).colorScheme.inversePrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SidebarItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          SidebarItem(
            icon: Icons.list,
            label: "Transactions",
            onTap: () {
              if (Platform.isWindows) {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/win_transactions');
              } else {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/transactions');
              }
            },
          ),
          SidebarItem(
            icon: Icons.label,
            label: "Tags",
            onTap: () => debugPrint("Tags tapped"),
          ),
          SidebarItem(
            icon: Icons.settings,
            label: "Settings",
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          SidebarItem(
            icon: Icons.account_balance_wallet,
            label: "Budgets",
            onTap: () {
              Navigator.pushNamed(context, '/budgets');
            },
          ),
          const SizedBox(height: 20),

          SidebarItem(
            icon: Icons.sync,
            label: "Sync to cloud",
            onTap: () async {
              Navigator.of(context).pop();
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
              try {
                await service.handleLogout(context);
              } catch (e) {
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
      title: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}
