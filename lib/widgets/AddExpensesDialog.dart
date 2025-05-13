import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  final void Function(String title, double amount, String tag, DateTime date) onAdd;

  const AddExpenseDialog({super.key, required this.onAdd});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final List<String> _tags = ['Food', 'Transport', 'Bills', 'Entertainment'];
  String _selectedTag = 'Food';
  DateTime _selectedDate = DateTime.now();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final amount = double.parse(_amountController.text);

      widget.onAdd(title, amount, _selectedTag, _selectedDate);
      Navigator.of(context).pop();
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
      title: const Text('Add Expense'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
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
            DropdownButtonFormField<String>(
              value: _selectedTag,
              items: _tags
                  .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTag = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Tag'),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
