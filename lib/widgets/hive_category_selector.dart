import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:expense_track/models/category_item.dart'; // Hive model

class CategorySelectorSheet extends StatefulWidget {
  final String selectedCategory;
  final String? allowedType; // Optional filter: 'Income' or 'Expense'

  const CategorySelectorSheet({
    Key? key,
    required this.selectedCategory,
    this.allowedType,
  }) : super(key: key);

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  String? selected;
  List<CategoryItem> incomeCategories = [];
  List<CategoryItem> expenseCategories = [];

  @override
  void initState() {
    debugPrint('>>> initState START');
    super.initState();

    debugPrint('>>> widget.selectedCategory = ${widget.selectedCategory}');
    selected = widget.selectedCategory;

    _loadCategoriesFromHive();
    debugPrint('>>> initState END');
  }

  void _loadCategoriesFromHive() {
    debugPrint('>>> _loadCategoriesFromHive START');
    final box = Hive.box<CategoryItem>('categories');

    final allCategories = box.values.toList();
    debugPrint('>>> Retrieved ${allCategories.length} items from Hive');

    for (var c in allCategories) {
      debugPrint(
        '>>> Raw Hive CategoryItem: '
        'name=${c.name}, type=${c.type}, iconCode=${c.iconCodePoint}, '
        'fontFamily=${c.fontFamily}, fontPackage=${c.fontPackage}',
      );
    }

    try {
      setState(() {
        incomeCategories =
            allCategories.where((c) => c.type == 'Income').toList();

        expenseCategories =
            allCategories.where((c) => c.type == 'Expense').toList();
      });

      debugPrint('>>> Final incomeCategories: $incomeCategories');
      debugPrint('>>> Final expenseCategories: $expenseCategories');
    } catch (e, stack) {
      debugPrint('>>> ERROR in _loadCategoriesFromHive: $e');
      debugPrintStack(stackTrace: stack);
    }

    debugPrint('>>> _loadCategoriesFromHive END');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('>>> build() START');
    final showOnlyType = widget.allowedType;

    debugPrint('>>> showOnlyType = $showOnlyType');
    debugPrint('>>> selected = $selected');

    return SizedBox(
      height: 400,
      child:
          showOnlyType != null
              ? _buildRadioGrid(
                context,
                showOnlyType == 'Income' ? incomeCategories : expenseCategories,
              )
              : DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Select Category",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/categories');
                              _loadCategoriesFromHive();
                            },
                            icon: const Icon(Icons.settings),
                            tooltip: "Manage categories",
                          ),
                        ],
                      ),
                    ),
                    const TabBar(
                      tabs: [Tab(text: 'Income'), Tab(text: 'Expense')],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildRadioGrid(context, incomeCategories),
                          _buildRadioGrid(context, expenseCategories),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildRadioGrid(BuildContext context, List<CategoryItem> categories) {
    debugPrint('>>> _buildRadioGrid with ${categories.length} items');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: GridView.builder(
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3.5,
        ),
        itemBuilder: (_, index) {
          try {
            debugPrint('>>> Building item at index $index');

            final item = categories[index];
            debugPrint('>>> UICategoryItem: $item');

            final isSelected = selected == item.name;
            debugPrint('>>> isSelected = $isSelected for ${item.name}');

            return GestureDetector(
              onTap: () {
                try {
                  debugPrint('>>> onTap triggered for ${item.name}');
                  setState(() {
                    selected = item.name;
                    debugPrint('>>> setState updated selected = $selected');
                  });

                  debugPrint('>>> Scheduling Navigator.pop for ${item.name}');
                  // Future.delayed(const Duration(milliseconds: 200), () {
                  //   debugPrint('>>> Navigator.pop(${item.name})');
                  //   Navigator.of(context).pop(item);
                  // });

                  debugPrint('>>> Navigator.pop(${item.name})');
                  Navigator.of(context).pop(item);
                } catch (e, stack) {
                  debugPrint('>>> ERROR in onTap for ${item.name}: $e');
                  debugPrintStack(stackTrace: stack);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).highlightColor
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (_) {
                        try {
                          debugPrint('>>> Rendering Icon for ${item.name}');
                          return Icon(item.icon, size: 20);
                        } catch (e, stack) {
                          debugPrint('>>> ERROR in Icon(${item.name}): $e');
                          debugPrintStack(stackTrace: stack);
                          return const Icon(Icons.help_outline, size: 20);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.name, overflow: TextOverflow.ellipsis),
                    ),
                    Radio<String>(
                      value: item.name,
                      groupValue: selected,
                      onChanged: (_) {
                        try {
                          debugPrint(
                            '>>> Radio.onChanged triggered for ${item.name}',
                          );
                          setState(() {
                            selected = item.name;
                            debugPrint('>>> setState (radio) = $selected');
                          });

                          if (Navigator.of(context).canPop()) {
                            debugPrint(
                              '>>> Navigator.pop (onTap) ${item.name}',
                            );
                            Navigator.of(context).pop(item);
                          } else {
                            debugPrint(
                              '>>> WARNING: Cannot pop context for ${item.name}',
                            );
                          }
                        } catch (e, stack) {
                          debugPrint('>>> ERROR in Radio.onChanged: $e');
                          debugPrintStack(stackTrace: stack);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          } catch (e, stackTrace) {
            debugPrint('>>> ERROR in itemBuilder index $index: $e');
            debugPrintStack(stackTrace: stackTrace);
            return const SizedBox();
          }
        },
      ),
    );
  }
}
