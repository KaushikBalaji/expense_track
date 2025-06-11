import 'package:expense_track/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/entry.dart';
import '../widgets/CustomAppbar.dart';
import '../widgets/CustomSidebar.dart';
import '../widgets/EntryDialog.dart';
import '../widgets/entry_list.dart';

class TransactionsPage extends StatefulWidget {
  final String title;
  const TransactionsPage({super.key, required this.title});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Entry> _entries = [];
  static late Box<Entry> _entryBox;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    _entryBox = await Hive.openBox<Entry>('entriesBox');
    List<Entry> entries = _entryBox.values.toList();
    setState(() {
      _entries = entries;
    });
  }

  void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => EntryDialog(
            initialDate: DateTime.now(),
            mode: EntryDialogMode.add,
            onSuccess: (action) {
              if (action == EntryDialogAction.edited) {
                setState(() {
                  _entries = Hive.box<Entry>('entriesBox').values.toList();
                  _loadEntries();
                });
              }
            },
          ),
    );
  }

  void _deleteEntry(Entry entry) async {
    await SupabaseService.deleteEntry(entry);
    await _loadEntries();
  }

  void _openTransactionDetails(Entry entry) {
    showDialog(
      context: context,
      builder:
          (ctx) => EntryDialog(
            initialEntry: entry,
            initialDate: entry.date,
            mode: EntryDialogMode.view,
            onSuccess: (action) {
              if (action == EntryDialogAction.deleted ||
                  action == EntryDialogAction.edited) {
                setState(() {
                  _entries = Hive.box<Entry>('entriesBox').values.toList();
                  _loadEntries();
                });
              }
            },
          ),
    );
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
                  ),

                  Expanded(
                    child: EntryListSection(
                      entries: _entries,
                      onDelete: _deleteEntry,
                      onTap: _openTransactionDetails,
                    ),
                  ),
                ],
              ),
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
