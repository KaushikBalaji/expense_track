import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import '../models/entry.dart';
import 'category_selector_sheet.dart';

class EntryDialog extends StatefulWidget {
  final Entry? initialEntry;
  final bool isEditing;
  final VoidCallback? onSuccess;

  final DateTime? initialDate;

  const EntryDialog({
    super.key,
    this.initialEntry,
    this.isEditing = false,
    this.onSuccess,
    this.initialDate, // <-- new optional param
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

  @override
  void initState() {
    super.initState();

    // If editing, load from initialEntry
    if (widget.isEditing && widget.initialEntry != null) {
      final entry = widget.initialEntry!;
      _titleController.text = entry.title;
      _amountController.text = entry.amount.toString();
      _selectedDate = entry.date;
      _selectedTag = entry.tag;
      type = _getTagType(entry.tag);
    } else {
      // Use initialDate if provided, else fallback to now
      _selectedDate = widget.initialDate ?? DateTime.now();
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text.trim());

      final box = Hive.box<Entry>('entriesBox');

      if (widget.isEditing && widget.initialEntry != null) {
        // Update existing entry
        final updatedEntry = widget.initialEntry!
          ..title = title
          ..amount = amount
          ..date = _selectedDate
          ..tag = _selectedTag
          ..type = type;

        await updatedEntry.save();
      } else {
        // Add new entry
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a title' : null,
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
                  final selected = await showModalBottomSheet<CategoryItem>(
                    context: context,
                    builder: (_) => CategorySelectorSheet(selectedCategory: _selectedTag),
                  );

                  if (selected != null) {
                    setState(() {
                      _selectedTag = selected.name;
                      type = selected.type;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Category'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTag.isNotEmpty ? _selectedTag : 'Select Category',
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
                children: ['Income', 'Expense'].map((value) {
                  final selected = type == value;
                  return GestureDetector(
                    onTap: () => setState(() {
                      type = value;
                      final tagType = _getTagType(_selectedTag);
                      if (tagType != type) _selectedTag = '';
                    }),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      decoration: BoxDecoration(
                        color: selected
                            ? (value == 'Income' ? Colors.green : Colors.red)
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
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  String _getTagType(String tagName) {
    const incomeTags = ['Salary', 'Gift', 'Award', 'Investment'];
    return incomeTags.contains(tagName) ? 'Income' : 'Expense';
  }
}
