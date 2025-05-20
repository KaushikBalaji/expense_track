import 'package:expense_track/models/budget.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';

class HiveService {

  // Make sure box is opened before use
  static late Box<Entry> _entryBox;
  static late Box<Budget> _budgetBox;


  // Initialize box in this static method
  static Future<void> initialize() async {
    // _box = await Hive.openBox<Entry>('entriesBox');
    // print('Hivebox open');
    try {
      
      _entryBox = await Hive.openBox<Entry>('entriesBox');
      _budgetBox = await Hive.openBox<Budget>('budgetsBox');

      print('Hivebox open');
    } catch (e) {
      print('Error opening Hive box: $e');
    }
  }

  static List<Entry> getAllExpenses() {
    return _entryBox.values.toList();
  }

  static Future<void> addExpense(Entry expense) async {
    print('Adding expense: $expense');
    await _entryBox.put(expense.id, expense);
  }

  static Future<void> deleteExpense(Entry expense) async {
    final key = _entryBox.keys.firstWhere((k) => _entryBox.get(k) == expense, orElse: () => null);
    if (key != null) {
      await _entryBox.delete(key);
    }
  }

  static Future<void> clearAllExpenses() async {
    await _entryBox.clear();
  }
}
