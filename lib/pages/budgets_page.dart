
import 'package:dotted_border/dotted_border.dart';
import 'package:expense_track/models/category_item.dart';
import 'package:expense_track/widgets/CustomAppbar.dart';
import 'package:expense_track/widgets/CustomSidebar.dart';
// import 'package:expense_track/widgets/category_selector_sheet.dart';
import '../widgets/hive_category_selector.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/entry.dart';

import '../models/budget.dart'; // Adjust path based on your structure

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  final _amountController = TextEditingController();
  String _selectedTag = '';

  late Box<Budget> _budgetBox;

  @override
  void initState() {
    super.initState();
    _budgetBox = Hive.box<Budget>('budgetsBox');
  }

  Future<void> _addBudgetDialog() async {
    _amountController.clear();
    _selectedTag = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Add Budget'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final selected =
                            await showModalBottomSheet<CategoryItem>(
                              context: context,
                              builder:
                                  (_) => CategorySelectorSheet(
                                    selectedCategory: _selectedTag,
                                    allowedType: 'Expense',
                                  ),
                            );

                        if (selected != null && selected.type == 'Expense') {
                          setLocalState(() => _selectedTag = selected.name);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedTag.isNotEmpty
                                  ? _selectedTag
                                  : 'Select Category',
                              style: TextStyle(
                                color:
                                    _selectedTag.isNotEmpty
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.onSurface
                                        : Colors.grey,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(
                      _amountController.text.trim(),
                    );
                    try {
                      if (amount != null && _selectedTag.isNotEmpty) {
                        final now = DateTime.now();
                        final newBudget = Budget(
                          id: const Uuid().v4(),
                          userId:
                              'local_user', // Replace with real userId if needed
                          amount: amount,
                          category: _selectedTag,
                          month: DateTime(now.year, now.month),
                          note: null,
                          createdAt: now,
                        );
                        print(
                          'Budget created: ${newBudget.id}    ${newBudget.userId}    ${newBudget.amount}    ${newBudget.category}    ${newBudget.month}    ${newBudget.createdAt}    ',
                        );
                        _budgetBox.add(newBudget);
                        print(
                          'Budget Added: ${newBudget.id}    ${newBudget.userId}    ${newBudget.amount}    ${newBudget.category}    ${newBudget.month}    ${newBudget.createdAt}    ',
                        );
                        setState(() {}); // Refresh UI
                        print(context);
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      print('Exception: $e');
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Access transactions
    final transactionBox = Hive.box<Entry>('entriesBox');
    final transactions =
        transactionBox.values.where((tx) {
          return tx.tag == budget.category &&
              tx.date.year == currentMonth.year &&
              tx.date.month == currentMonth.month &&
              tx.type.toLowerCase() == 'expense'; // Only expenses
        }).toList();

    final spent = transactions.fold<double>(
      0.0,
      (sum, tx) => sum + tx.amount.abs(),
    );

    print('Spent: $spent');
    (budget.amount - spent).clamp(0, budget.amount);
    final usagePercent = (spent / budget.amount).clamp(0, 1).toDouble();
    print('Remaining: $usagePercent');

    final isOverBudget = spent > budget.amount;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_down, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    budget.category,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await budget.delete();
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Spent: ₹${spent.toStringAsFixed(0)} / ₹${budget.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color:
                    isOverBudget
                        ? Colors.red
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: usagePercent,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgets = _budgetBox.values.toList().reversed.toList();

    return Scaffold(
      appBar: CustomAppBar(title: 'Budgets'),
      drawer: CustomSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _addBudgetDialog,
              child: DottedBorder(
                options: const RectDottedBorderOptions(
                  strokeWidth: 1,
                  color: Colors.grey,
                  dashPattern: [6, 3],
                ),
                // borderType: BorderType.RRect,
                // radius: const Radius.circular(12),
                // dashPattern: const [6, 3],
                // color: Theme.of(context).colorScheme.primary,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: const Text(
                    '+ Add Budget',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  budgets.isEmpty
                      ? const Center(child: Text('No budgets found.'))
                      : ListView.builder(
                        itemCount: budgets.length,
                        itemBuilder:
                            (context, index) =>
                                _buildBudgetCard(budgets[index]),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
