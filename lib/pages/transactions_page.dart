import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../services/hive_service.dart';
import '../widgets/CustomAppbar.dart';
import '../widgets/CustomSidebar.dart';
import '../widgets/AddExpensesDialog.dart';
import '../widgets/entry_list.dart';
import '../widgets/transactions_details.dart';

class TransactionsPage extends StatefulWidget {
  final String title;
  const TransactionsPage({super.key, required this.title});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Entry> _entries = [];
  Entry? _selectedEntry;
  bool _isPanelVisible = false;

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

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddExpenseDialog(
        onAdd: (title, amount, tag, date, type) async {
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

  void _openTransactionDetails(Entry entry) {
    setState(() {
      _selectedEntry = entry;
      _isPanelVisible = true;
    });
  }

  void _closeTransactionDetails() {
    setState(() {
      _selectedEntry = null;
      _isPanelVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomSidebar(),
      body: Builder(
        builder: (scaffoldContext) {
          return Stack(
            children: [
              Column(
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
                          // Add settings logic
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
                      onTap: _openTransactionDetails,
                    ),
                  ),
                ],
              ),
              // Side panel (flat design for PC)
              _selectedEntry != null
                  ? AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: _isPanelVisible ? 0 : -400,
                top: 0,
                bottom: 0,

                    child: TransactionDetailsPanel(
                      entry: _selectedEntry!,
                      onClose: _closeTransactionDetails,
                    ),

              )
                  : const SizedBox.shrink(),
            ],
          );
        },
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _openAddDialog(context);
            },
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            //backgroundColor: Colors.transparent,
            tooltip: 'Add Entry',
            elevation: 0,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
