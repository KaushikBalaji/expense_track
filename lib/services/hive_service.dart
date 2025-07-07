import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';
import '../models/category_item.dart';

class HiveService {
  // Make sure box is opened before use
  static late Box<Entry> _entryBox;
  static late Box<CategoryItem> _categoryBox;

  // Initialize box in this static method
  static Future<void> initialize() async {
    // _box = await Hive.openBox<Entry>('entriesBox');
    // debugPrint('Hivebox open');
    try {
      _entryBox = await Hive.openBox<Entry>('entriesBox');
      _categoryBox = await Hive.openBox<CategoryItem>('categories');

      debugPrint('Hivebox open');
    } catch (e) {
      debugPrint('Error opening Hive box: $e');
    }
  }

  static List<Entry> getAllExpenses() {
    return _entryBox.values.toList();
  }

  static Future<void> addExpense(Entry expense) async {
    debugPrint('Adding expense: $expense');
    await _entryBox.put(expense.id, expense);
  }

  static Future<void> clearAllExpenses() async {
    await _entryBox.clear();
  }

  // ---------------------------
  // 🚀 CATEGORY methods
  // ---------------------------

  static List<CategoryItem> getAllCategories() => _categoryBox.values.toList();

  static Future<void> uploadCategoriesToCloud(
    Future<void> Function(CategoryItem item) uploadFn,
  ) async {
    final categories = getAllCategories();
    for (final cat in categories) {
      try {
        await uploadFn(cat);
      } catch (e) {
        debugPrint('Failed to upload ${cat.name}: $e');
      }
    }
  }
}
