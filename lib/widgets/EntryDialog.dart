import 'package:expense_track/models/category_item.dart';
import 'package:expense_track/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/entry.dart';
// import 'category_selector_sheet.dart';
import 'hive_category_selector.dart';

enum EntryDialogMode { add, edit, view }

class EntryDialog extends StatefulWidget {
  final Entry? initialEntry;
  final EntryDialogMode mode;
  final VoidCallback? onSuccess;
  final DateTime? initialDate;

  const EntryDialog({
    super.key,
    this.initialEntry,
    this.mode = EntryDialogMode.add,
    this.onSuccess,
    this.initialDate,
  });

  @override
  State<EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  late DateTime _selectedDate = DateTime.now();
  String type = 'Income';
  String _selectedTag = 'Salary';

  late EntryDialogMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;

    if (widget.initialEntry != null) {
      final entry = widget.initialEntry!;
      _titleController.text = entry.title;
      _amountController.text = entry.amount.toString();
      _selectedDate = entry.date;
      _selectedTag = entry.tag;
      type = _getTagType(entry.tag);
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text.trim());
      final box = Hive.box<Entry>('entriesBox');

      if (_currentMode == EntryDialogMode.edit && widget.initialEntry != null) {
        final updatedEntry =
            widget.initialEntry!
              ..title = title
              ..amount = amount
              ..date = _selectedDate
              ..tag = _selectedTag
              ..type = type;

        await updatedEntry.save();
      } else {
        final newEntry = Entry(
          title: title,
          amount: amount,
          date: _selectedDate,
          tag: _selectedTag,
          type: type,
        );
        await box.add(newEntry);
      }

      if (widget.onSuccess != null) widget.onSuccess!();
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isViewMode = _currentMode == EntryDialogMode.view;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_getDialogTitle()),
          if (isViewMode) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                setState(() {
                  _currentMode = EntryDialogMode.edit;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: const Text("Delete this transaction?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                );
                if (confirm == true && widget.initialEntry != null) {
                  await SupabaseService.deleteEntry(widget.initialEntry!);
                  widget.onSuccess?.call();
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
            ),
          ],
        ],
      ),
      content: isViewMode ? _buildViewContent() : _buildFormContent(),
      actions:
          isViewMode
              ? [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ]
              : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    _currentMode == EntryDialogMode.edit ? 'Save' : 'Add',
                  ),
                ),
              ],
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Please enter a title'
                          : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                try {
                  final selected = await showModalBottomSheet<UICategoryItem>(
                    context: context,
                    builder: (_) {
                      return Builder(
                        builder: (context) {
                          ErrorWidget.builder = (FlutterErrorDetails details) {
                            debugPrint(
                              'Flutter build error: ${details.exception}',
                            );
                            return Center(
                              child: Text(
                                'Oops! Something went wrong.\n${details.exception}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          };
                          print(
                            'Inside Modalsheet before categorysheet line with selected tag: $_selectedTag',
                          );
                          return CategorySelectorSheet(
                            selectedCategory: _selectedTag,
                          );
                        },
                      );
                    },
                  );

                  print('Selected tag which i returned is: $_selectedTag');

                  if (selected != null) {
                    setState(() {
                      _selectedTag = selected.name;
                      type = selected.type;
                    });
                  }
                } catch (e, stackTrace) {
                  debugPrint('Caught error outside build: $e');
                  debugPrintStack(stackTrace: stackTrace);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Category'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTag.isNotEmpty
                          ? _selectedTag
                          : 'Select Category',
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ['Income', 'Expense'].map((value) {
                    final selected = type == value;
                    return GestureDetector(
                      onTap:
                          () => setState(() {
                            type = value;
                            if (_getTagType(_selectedTag) != type)
                              _selectedTag = '';
                          }),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selected
                                  ? (value == 'Income'
                                      ? Colors.green
                                      : Colors.red)
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          value,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              readOnly: true,
              enabled: false, // disable focus and editing
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              readOnly: true,
              enabled: false,
            ),
            const SizedBox(height: 10),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Category'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTag.isNotEmpty ? _selectedTag : 'Select Category',
                  ),
                  const Icon(Icons.category),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ['Income', 'Expense'].map((value) {
                    final selected = type == value;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color:
                            selected
                                ? (value == 'Income'
                                    ? Colors.green
                                    : Colors.red)
                                : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getTagType(String tagName) {
    const incomeTags = ['Salary', 'Gift', 'Award', 'Investment'];
    return incomeTags.contains(tagName) ? 'Income' : 'Expense';
  }

  String _getDialogTitle() {
    switch (_currentMode) {
      case EntryDialogMode.view:
        return 'Transaction Details';
      case EntryDialogMode.edit:
        return 'Edit Transaction';
      case EntryDialogMode.add:
      default:
        return 'Add Transaction';
    }
  }
}
