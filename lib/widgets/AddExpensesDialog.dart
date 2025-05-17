import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  final void Function(
    String title,
    double amount,
    String tag,
    DateTime date,
    String type,
  )
  onAdd;

  const AddExpenseDialog({super.key, required this.onAdd});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  //final List<String> _tags = ['Food', 'Transport', 'Bills', 'Entertainment'];
  DateTime _selectedDate = DateTime.now();
  String type = 'Income';
  final tags = Hive.box<String>('categories').values.toList().cast<String>();
  String _selectedTag = Hive.box<String>('categories').values.toList().cast<String>().first ;
  
  //final allOptions = [...tags, '+ Add Category'];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text;
      final amount = double.parse(_amountController.text);

      widget.onAdd(title, amount, _selectedTag, _selectedDate, type);
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
              items: tags
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
            // ValueListenableBuilder(
            //   valueListenable: Hive.box<String>('categories').listenable(),
            //   builder: (context, Box<String> box, _) {
            //     final categories = box.values.toList().cast<String>();

            //     if (categories.isEmpty) {
            //       return const Text('No categories available');
            //     }

            //     return DropdownButtonFormField<String>(
            //       value:
            //           _selectedTag != '' && categories.contains(_selectedTag)
            //               ? _selectedTag
            //               : null,
            //       items:
            //           categories
            //               .map(
            //                 (tag) =>
            //                     DropdownMenuItem(value: tag, child: Text(tag)),
            //               )
            //               .toList(),
            //       onChanged: (value) {
            //         if (value != null) {
            //           setState(() {
            //             _selectedTag = value;
            //           });
            //         }
            //       },
            //       decoration: const InputDecoration(labelText: 'Tag'),
            //     );
            //   },
            // ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ['Income', 'Expense'].map((value) {
                    final selected = type == value;
                    return GestureDetector(
                      onTap: () => setState(() => type = value),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
