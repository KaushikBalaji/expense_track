import 'package:expense_track/models/category_item.dart';
import 'package:expense_track/models/recurring_entry.dart';
import 'package:expense_track/models/recurring_rule.dart';
import 'package:expense_track/services/supabase_services.dart';
import 'package:expense_track/widgets/recurrence_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/entry.dart';
// import 'category_selector_sheet.dart';
import 'hive_category_selector.dart';

enum EntryDialogMode { add, edit, view, editRecurring  }

enum EntryDialogAction { edited, deleted }

class EntryDialog extends StatefulWidget {
  final Entry? initialEntry;
  final EntryDialogMode mode;
  final void Function(EntryDialogAction)? onSuccess;
  final DateTime? initialDate;
  final VoidCallback? onDelete;

  const EntryDialog({
    super.key,
    this.initialEntry,
    this.mode = EntryDialogMode.add,
    this.onSuccess,
    this.initialDate,
    this.onDelete,
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

  RecurringRule? _recurrenceRule;

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
      type = entry.type;
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
    }
  }

  void _confirmDelete() async {
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
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
    );
    if (confirm == true && widget.initialEntry != null) {
      await SupabaseService.deleteEntry(widget.initialEntry!);
      widget.onSuccess?.call(EntryDialogAction.deleted);
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTag.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text.trim());

      final isRecurring =
          _recurrenceRule != null &&
          _recurrenceRule!.type != RecurrenceType.none;

      if (isRecurring) {
        // ✅ Save recurring entry template
        final recurringBox = Hive.box<RecurringEntry>('recurring_entries_box');
        final newRecurring = RecurringEntry(
          title: title,
          amount: amount,
          tag: _selectedTag,
          type: type,
          startDate: _selectedDate,
          frequency: _recurrenceRule!.type.name,
          interval: _recurrenceRule!.interval,
          endDate: _recurrenceRule!.endDate,
          weekdays: _recurrenceRule!.weekdays,
        );
        await recurringBox.put(newRecurring.id, newRecurring);
      } else {
        // ✅ Save regular entry
        final box = Hive.box<Entry>('entriesBox');

        if (_currentMode == EntryDialogMode.edit &&
            widget.initialEntry != null) {
          final updatedEntry =
              widget.initialEntry!
                ..title = title
                ..amount = amount
                ..date = _selectedDate
                ..tag = _selectedTag
                ..type = type
                ..lastModified = DateTime.now();
          await updatedEntry.save();
        } else {
          final newEntry = Entry(
            title: title,
            amount: amount,
            date: _selectedDate,
            tag: _selectedTag,
            type: type,
          );
          await box.put(newEntry.id, newEntry);
        }
      }

      widget.onSuccess?.call(EntryDialogAction.edited);
      if (context.mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (pickedTime == null) return;

    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedDate = combinedDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isViewMode = _currentMode == EntryDialogMode.view;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final dialogWidth = isWide ? 500.0 : double.infinity;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getDialogTitle(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isViewMode)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: "Edit",
                              onPressed: () {
                                setState(
                                  () => _currentMode = EntryDialogMode.edit,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: "Delete",
                              onPressed: _confirmDelete,
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  isViewMode ? _buildViewContent() : _buildFormContent(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      if (!isViewMode)
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _currentMode == EntryDialogMode.edit
                                ? 'Save'
                                : 'Add',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void _showRecurrenceOptions() async {
    final result = await showModalBottomSheet<RecurringRule>(
      context: context,
      isScrollControlled: true,
      builder: (context) => RecurringOptionsSheet(initialRule: _recurrenceRule),
    );

    if (result != null) {
      setState(() => _recurrenceRule = result);
    }
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
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Please enter a title'
                          : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                try {
                  final selected = await showModalBottomSheet<CategoryItem>(
                    context: context,
                    builder:
                        (_) => CategorySelectorSheet(
                          selectedCategory: _selectedTag,
                        ),
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedTag = selected.name;
                      type = selected.type;
                    });
                  }
                } catch (e) {
                  debugPrint('Error: $e');
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTag.isNotEmpty
                          ? _selectedTag
                          : 'Select Category',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.date_range, size: 20),
                const SizedBox(width: 8),
                Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  onPressed: _pickDateTime,
                ),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  tooltip: "Set recurrence",
                  onPressed: _showRecurrenceOptions,
                ),
              ],
            ),

            if (_recurrenceRule != null &&
                _recurrenceRule!.type != RecurrenceType.none)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _recurrenceRule!.type == RecurrenceType.daily
                      ? 'Every ${_recurrenceRule!.interval} day(s)'
                      : 'Every ${_recurrenceRule!.interval} week(s) on '
                          '${_recurrenceRule!.weekdays?.map((d) => DateFormat.E().format(DateTime(2024, 1, d + 1))).join(", ")}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ['Income', 'Expense'].map((value) {
                    final selected = type == value;
                    final color = value == 'Income' ? Colors.green : Colors.red;
                    return GestureDetector(
                      onTap:
                          () => setState(() {
                            type = value;
                            final tagType = _getTagType(_selectedTag);
                            if (_selectedTag.isNotEmpty && tagType != type) {
                              _selectedTag = ''; // clear invalid tag
                            }
                          }),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? color : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              value == 'Income'
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: selected ? Colors.white : Colors.black54,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              value,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            prefixIcon: Icon(Icons.title),
          ),
          readOnly: true,
          enabled: false,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixIcon: Icon(Icons.attach_money),
          ),
          readOnly: true,
          enabled: false,
        ),
        const SizedBox(height: 16),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.category),
          ),
          child: Text(
            _selectedTag,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.date_range, size: 20),
            const SizedBox(width: 8),
            Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              ['Income', 'Expense'].map((value) {
                final selected = type == value;
                final color = value == 'Income' ? Colors.green : Colors.red;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        value == 'Income'
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: selected ? Colors.white : Colors.black54,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        value,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  String _getTagType(String tagName) {
    const incomeTags = [
      'Salary',
      'Gift',
      'Award',
      'Investment',
      'Freelance',
      'Rental Income',
      'Business',
      'Lottery',
      'Refund',
    ];
    return incomeTags.contains(tagName) ? 'Income' : 'Expense';
  }

  String _getDialogTitle() {
    switch (_currentMode) {
      case EntryDialogMode.view:
        return 'Transaction';
      case EntryDialogMode.edit:
        return 'Edit Transaction';
      case EntryDialogMode.add:
        return 'Add Transaction';
      case EntryDialogMode.editRecurring:
        return 'Recurring Entry';
    }
  }
}
