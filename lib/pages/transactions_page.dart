import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../services/hive_service.dart';
import '../widgets/CustomAppbar.dart';
import '../widgets/CustomSidebar.dart';
import '../widgets/AddExpensesDialog.dart';
import '../widgets/entry_list.dart';

class TransactionsPage extends StatefulWidget {
  final String title;
  const TransactionsPage({super.key, required this.title});

  @override
  State<TransactionsPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TransactionsPage> {
  List<Entry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    List<Entry> entries = await HiveService.getAllExpenses();
    setState(() {
      _entries = entries;
    });
  }

  void _openAddDialog(BuildContext context, EntryType type) {
    showDialog(
      context: context,
      builder: (ctx) => AddExpenseDialog(
        onAdd: (title, amount, tag, date) async {
          final entry = Entry(
            title: title,
            amount: amount,
            tag: tag,
            date: date,
            type: type,
          );
          await HiveService.addExpense(entry);
          setState(() {
            _entries.add(entry);
          });
        },
      ),
    );
  }

  void _deleteEntry(Entry entry) async {
    await HiveService.deleteExpense(entry);
    setState(() {
      _entries.remove(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomSidebar(),
      body: Builder(
        builder: (scaffoldContext) {
          return Column(
            children: [
              CustomAppBar(
                title: widget.title,
                showBackButton: false,
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(scaffoldContext).openDrawer();
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // settings logic
                    },
                  ),
                ],
              ),
              Expanded(
                child: _entries.isEmpty
                    ? const Center(child: Text('No entries yet.'))
                    : EntryListSection(
                  entries: _entries,
                  onDelete: _deleteEntry,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Expense Button (-)
          FloatingActionButton(
            heroTag: 'expenseBtn',
            onPressed: () {
              _openAddDialog(context, EntryType.expense);
            },
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: Colors.transparent,
            tooltip: 'Add Expense',
            elevation: 0,
            highlightElevation: 0,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverElevation: 0,
            child: const Icon(Icons.remove, color: Colors.red),
          ),
          const SizedBox(width: 16),

          // Income Button (+)
          FloatingActionButton(
            heroTag: 'incomeBtn',
            onPressed: () {
              _openAddDialog(context, EntryType.income);
            },
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: Colors.transparent,
            tooltip: 'Add Income',
            elevation: 0,
            highlightElevation: 0,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverElevation: 0,
            child: const Icon(Icons.add, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
