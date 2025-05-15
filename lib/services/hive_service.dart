import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';

class HiveService {

  // Make sure box is opened before use
  static late Box<Entry> _box;

  // Initialize box in this static method
  static Future<void> initialize() async {
    // _box = await Hive.openBox<Entry>('entriesBox');
    // print('Hivebox open');
    try {
      _box = await Hive.openBox<Entry>('entriesBox');
      print('Hivebox open');
    } catch (e) {
      print('Error opening Hive box: $e');
    }
  }

  static List<Entry> getAllExpenses() {
    return _box.values.toList();
  }

  static Future<void> addExpense(Entry expense) async {
    print('Adding expense: $expense');
    await _box.add(expense);
  }

  static Future<void> deleteExpense(Entry expense) async {
    final key = _box.keys.firstWhere((k) => _box.get(k) == expense, orElse: () => null);
    if (key != null) {
      await _box.delete(key);
    }
  }

  static Future<void> clearAllExpenses() async {
    await _box.clear();
  }
}
