import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final String type; // 'Income' or 'Expense'
  final IconData icon;

  CategoryItem({required this.name, required this.type, required this.icon});
}

class CategorySelectorSheet extends StatefulWidget {
  final String selectedCategory;
  final String? allowedType; // Optional filter: 'Income' or 'Expense'

  const CategorySelectorSheet({
    super.key,
    required this.selectedCategory,
    this.allowedType,
  });

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  String? selected;

  final List<CategoryItem> incomeCategories = [
    CategoryItem(name: 'Salary', type: 'Income', icon: Icons.attach_money),
    CategoryItem(name: 'Gift', type: 'Income', icon: Icons.card_giftcard),
    CategoryItem(name: 'Award', type: 'Income', icon: Icons.emoji_events),
    CategoryItem(name: 'Investment', type: 'Income', icon: Icons.trending_up),
  ];

  final List<CategoryItem> expenseCategories = [
    CategoryItem(name: 'Food', type: 'Expense', icon: Icons.fastfood),
    CategoryItem(name: 'Transport', type: 'Expense', icon: Icons.directions_car),
    CategoryItem(name: 'Bills', type: 'Expense', icon: Icons.receipt_long),
    CategoryItem(name: 'Shopping', type: 'Expense', icon: Icons.shopping_bag),
    CategoryItem(name: 'Subscriptions', type: 'Expense', icon: Icons.subscriptions),
    CategoryItem(name: 'Entertainment', type: 'Expense', icon: Icons.movie),
    CategoryItem(name: 'Gift', type: 'Expense', icon: Icons.card_giftcard),
  ];

  @override
  void initState() {
    super.initState();
    selected = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final showOnlyType = widget.allowedType;
    final isExpenseOnly = showOnlyType == 'Expense';
    final isIncomeOnly = showOnlyType == 'Income';

    return SizedBox(
      height: 400,
      child: showOnlyType != null
          ? _buildRadioGrid(
              context,
              showOnlyType == 'Income' ? incomeCategories : expenseCategories,
            )
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [Tab(text: 'Income'), Tab(text: 'Expense')],
                  ),
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
          final item = categories[index];
          final isSelected = selected == item.name;

          return GestureDetector(
            onTap: () {
              setState(() {
                selected = item.name;
              });
              Future.delayed(const Duration(milliseconds: 200), () {
                Navigator.of(context).pop(item);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).highlightColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.name)),
                  Radio<String>(
                    value: item.name,
                    groupValue: selected,
                    onChanged: (_) {
                      setState(() {
                        selected = item.name;
                      });
                      Future.delayed(const Duration(milliseconds: 200), () {
                        Navigator.of(context).pop(item);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
