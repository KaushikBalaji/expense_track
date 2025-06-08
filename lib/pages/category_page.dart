import 'package:expense_track/models/category_item.dart';
import 'package:expense_track/models/entry.dart'; // ✅ Added
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/supabase_services.dart';
import '../utils/predefined_categories.dart';

class CategoryManagementPage extends StatefulWidget {
  @override
  _CategoryManagementPageState createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  late Box<CategoryItem> categoryBox;
  final Box<Entry> entriesBox = Hive.box<Entry>('entriesBox'); // ✅ Added
  String selectedType = 'Income';
  // final Box<List> categoryStatus = Hive.box('categoryStatus');
  final Set<String> protectedCategoryNames = {'Food', 'House', 'Clothing'};

  @override
  void initState() {
    super.initState();
    categoryBox = Hive.box<CategoryItem>('categories');
    // for (final item in categoryBox.values) {
    //   print(
    //     'ID: ${item.id}, Name: ${item.name}, Type: ${item.type}, isActive: ${item.isActive}, Icon: ${item.iconCodePoint}',
    //   );
    // }

    print("📦 Categories in Hive:");
    for (final c in categoryBox.values) {
      print(
        "ID: ${c.id}, Name: ${c.name}, Type: ${c.type}, Icon: ${c.iconCodePoint}, Active: ${c.isActive}",
      );
    }

    // migrateActiveStatusIntoCategoryItems();
  }

  Future<void> migrateActiveStatusIntoCategoryItems() async {
    final categoryBox = Hive.box<CategoryItem>('categories');
    final statusBox = Hive.box('categoryStatus');

    final activeIds =
        statusBox.get('activeCategories', defaultValue: <String>[])!;

    for (final item in categoryBox.values) {
      final shouldBeActive = activeIds.contains(item.id);
      if (item.isActive != shouldBeActive) {
        item.isActive = shouldBeActive;
        await item.save(); // 🔥 Persist the update
      }
    }

    await statusBox.delete('activeCategories');
    print("✅ Migrated active status into CategoryItem");
  }

  bool isCategorySaved(CategoryItem item) {
    return categoryBox.values.any((c) => c.id == item.id);
  }

  // void setCategoryActive(CategoryItem category, bool isActive) {
  //   category.isActive = isActive;
  // }

  // bool isCategoryActive(String categoryId) {
  //   final activeIds =
  //       categoryStatus.get('activeCategories', defaultValue: <String>[])!;
  //   return activeIds.contains(categoryId);
  // }

  bool isCategoryActive(CategoryItem item) {
    final saved = categoryBox.get(item.id);
    return saved?.isActive ?? false;
  }

  Future<void> toggleCategory(CategoryItem item, bool newValue) async {
    print('ToggleCategory called: ${item.name} -> $newValue');
    final exists = isCategorySaved(item);

    if (protectedCategoryNames.contains(item.name) && !newValue) {
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

    // ✅ Check if category is in use before allowing disable
    final isUsed = entriesBox.values.any(
      (entry) => entry.tag == item.name && entry.type == item.type,
    );
    if (!newValue && isUsed) {
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text("Category In Use"),
              content: const Text(
                "This category is linked to existing transactions. Please reassign or remove those entries before disabling this category.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("OK"),
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
        await categoryBox.put(item.id, item);
        // setCategoryActive(item, true);
        item.isActive = true;
        await item.save();
      }
    } 

    else if (!newValue && exists) {
      final keyToRemove = categoryBox.keys.firstWhere((k) {
        final c = categoryBox.get(k);
        return c?.id == item.id;
      }, orElse: () => null);
      if (keyToRemove != null) {
        await categoryBox.delete(keyToRemove);
        // setCategoryActive(item, false);
        item.isActive = false;
        // await item.save();
      }
    }

    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    // final filteredCategories =
    //     predefinedCategories.where((item) => item.type == selectedType).toList();

    final predefinedFiltered =
        predefinedCategories
            .where((item) => item.type == selectedType)
            .toList();

    final savedFiltered =
        categoryBox.values
            .where(
              (item) =>
                  item.type == selectedType &&
                  !predefinedFiltered.any((p) => p.id == item.id),
            )
            .toList();

    final filteredCategories = [...predefinedFiltered, ...savedFiltered];

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
                        final userId = supabase.auth.currentUser?.id;
                        await SupabaseService.uploadAllCategoriesStatus(
                          userId!,
                        );
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
                        final userId = supabase.auth.currentUser?.id;
                        await SupabaseService.clearAndSyncCategoriesFromSupabase(
                          userId!,
                        );
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
                      final isSelected = isCategoryActive(item);

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
