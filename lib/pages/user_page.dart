import 'package:expense_track/models/entry.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _categoryController = TextEditingController();
  late final Box<String> _categoryBox;

  @override
  void initState() {
    super.initState();
    _categoryBox = Hive.box<String>('categories');
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty && !_categoryBox.values.contains(newCategory)) {
      _categoryBox.add(newCategory);
      _categoryController.clear();
    }
  }

  void _removeCategory(int index) {
    final categoriesBox = Hive.box<String>('categories');
    final entriesBox = Hive.box<Entry>('entriesBox');
    final categoryToDelete = categoriesBox.getAt(index);

    final isUsed = entriesBox.values.any(
      (entry) => entry.tag == categoryToDelete,
    );

    if (isUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete "$categoryToDelete" — it is used in entries.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (categoriesBox.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to have at least 2 categories'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    categoriesBox.deleteAt(index);
  }

  Widget _buildUserInfo(User user) {
    final userInfoItems = [
      {
        'icon': Icons.email_outlined,
        'label': 'Email',
        'value': user.email ?? 'N/A',
      },
      
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Created At',
        'value': _formatDateTime(user.createdAt),
      },
      {
        'icon': Icons.login_outlined,
        'label': 'Last Sign-in',
        'value': _formatDateTime(user.lastSignInAt),
      },
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Divider(),
            ...userInfoItems.map(
              (item) => ListTile(
                leading: Icon(
                  item['icon'] as IconData,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(item['label'] as String),
                subtitle: Text(
                  item['value'] as String,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      return dateTime.toString();
    } catch (e) {
      return dateTimeStr; // fallback, if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(user),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Account'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await Supabase.instance.client.auth.admin.deleteUser(user.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Manage Categories',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'New Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addCategory,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: _categoryBox.listenable(),
              builder: (context, Box<String> box, _) {
                final categories = box.values.toList();
                if (categories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No categories added yet.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 10),
                  itemBuilder: (context, index) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      title: Text(
                        categories[index],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeCategory(index),
                        tooltip: 'Delete Category',
                      ),
                      
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
