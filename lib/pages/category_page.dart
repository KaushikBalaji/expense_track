import 'package:expense_track/models/category_item.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/supabase_services.dart';
import '../utils/predefined_categories.dart';

class CategoryManagementPage extends StatefulWidget {
  @override
  _CategoryManagementPageState createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
    //static String? get userId => supabase.auth.currentUser?.id;
  late Box<CategoryItem> categoryBox;
  String selectedType = 'Income'; // Default selected type
  final Box<List> categoryStatus = Hive.box('categoryStatus');

  final Set<String> protectedCategoryNames = {'Food', 'House', 'Clothing'};

  @override
  void initState() {
    super.initState();
    categoryBox = Hive.box<CategoryItem>('categories');
  }

  bool isCategorySaved(CategoryItem item) {
    return categoryBox.values.any(
      (c) => c.name == item.name && c.type == item.type,
    );
  }

  void setCategoryActive(String categoryId, bool isActive) {
    final activeIds =
        categoryStatus
            .get('activeCategories', defaultValue: <String>[])!
            .toSet();

    if (isActive) {
      activeIds.add(categoryId);
    } else {
      activeIds.remove(categoryId);
    }

    categoryStatus.put('activeCategories', activeIds.toList());
  }

  bool isCategoryActive(String categoryId) {
    final activeIds =
        categoryStatus.get('activeCategories', defaultValue: <String>[])!;
    return activeIds.contains(categoryId);
  }

  Future<void> toggleCategory(CategoryItem item, bool newValue) async {
    final exists = isCategorySaved(item);

    if (protectedCategoryNames.contains(item.name) && !newValue) {
      // Show fun message and block removal
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text("Basic Needs Alert!"),
              content: Text(
                '"${item.name}" is one of life’s essentials.\n\nYou can’t live without it — and you can’t remove it either! 😄',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("OK, I need it!"),
                ),
              ],
            ),
      );
      return;
    }

    if (newValue && !exists) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Add Category'),
              content: Text(
                'Do you want to add "${item.name}" to your categories?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Add'),
                ),
              ],
            ),
      );

      if (confirmed == true) {
        await categoryBox.add(item);
        setCategoryActive(item.id, true); // ✅ Track activation
      }
    } else if (!newValue && exists) {
      final keyToRemove = categoryBox.keys.firstWhere((k) {
        final c = categoryBox.get(k);
        return c?.name == item.name && c?.type == item.type;
      }, orElse: () => null);
      if (keyToRemove != null) {
        await categoryBox.delete(keyToRemove);
        setCategoryActive(item.id, false); // ✅ Track deactivation
      }
    }

    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories =
        predefinedCategories
            .where((item) => item.type == selectedType)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final userId =
                            supabase.auth.currentUser?.id; // Replace with actual user ID logic
                        await SupabaseService.uploadAllCategoriesStatus(userId!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Uploaded all active categories!"),
                          ),
                        );
                      },
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("Upload All"),
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        final userId =
                            supabase.auth.currentUser?.id; // Replace with actual user ID logic
                        await SupabaseService.downloadAndSaveCategoryStatus(userId!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Downloaded all active categories!"),
                          ),
                        );
                      },
                      icon: const Icon(Icons.cloud_download),
                      label: const Text("Download All"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ToggleButtons(
                  isSelected: [
                    selectedType == 'Income',
                    selectedType == 'Expense',
                  ],
                  onPressed: (index) {
                    setState(() {
                      selectedType = index == 0 ? 'Income' : 'Expense';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Income'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Expense'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCategories.length,
                    itemBuilder: (_, index) {
                      final item = filteredCategories[index];
                      final isSelected = isCategoryActive(item.id);

                      return ListTile(
                        leading: Icon(
                          IconData(
                            item.iconCodePoint,
                            fontFamily: item.fontFamily,
                            fontPackage: item.fontPackage,
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.type),
                        trailing: Switch(
                          value: isSelected,
                          onChanged:
                              (newValue) => toggleCategory(item, newValue),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
