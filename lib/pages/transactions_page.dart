import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../services/hive_service.dart';
import '../widgets/CustomAppbar.dart';
import '../widgets/CustomSidebar.dart';
import '../widgets/AddExpensesDialog.dart';
import '../widgets/entry_list.dart';
import '../widgets/transactions_overlay.dart';
import '../widgets/transactions_details.dart';

class TransactionsPage extends StatefulWidget {
  final String title;
  const TransactionsPage({super.key, required this.title});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  List<Entry> _entries = [];
  Entry? _selectedEntry;
  bool _showOverlay = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadEntries();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _openTransactionDetails(Entry entry) {
    setState(() {
      _selectedEntry = entry;
      _showOverlay = true;
    });
    _animationController.forward();
  }

  void _closeTransactionDetails() {
    _animationController.reverse().then((_) {
      setState(() {
        _selectedEntry = null;
        _showOverlay = false;
      });
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
                      onTap: _openTransactionDetails,
                    ),
                  ),
                ],
              ),
              if (_showOverlay && _selectedEntry != null)
                TransactionDetailsOverlay(
                  entry: _selectedEntry!,
                  onClose: _closeTransactionDetails,
                  slideAnimation: _slideAnimation,
                ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
            child: const Icon(Icons.remove, color: Colors.red),
          ),
          const SizedBox(width: 16),
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
            child: const Icon(Icons.add, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
