import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:expense_track/models/category_item.dart';
import 'package:expense_track/utils/predefined_categories.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import '../models/entry.dart';

class ExcelOperationsSyncfusion {
  static const String sheetName = 'Entries';
  static late Box<CategoryItem> categoryBox;

  void initState() {}

  /// Export Hive entries to an Excel file
  static Future<void> exportToExcel() async {
    final box = await Hive.openBox<Entry>('entriesbox');
    final entries = box.values.toList();

    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = sheetName;

    // Add header
    final headers = ['ID', 'Title', 'Amount', 'Tag', 'Date', 'Type'];
    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    // Add data rows
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final rowIndex = i + 2;

      sheet.getRangeByIndex(rowIndex, 1).setText(entry.id);
      sheet.getRangeByIndex(rowIndex, 2).setText(entry.title);
      sheet.getRangeByIndex(rowIndex, 3).setNumber(entry.amount);
      sheet.getRangeByIndex(rowIndex, 4).setText(entry.tag);
      sheet.getRangeByIndex(rowIndex, 5).dateTime = entry.date;
      sheet.getRangeByIndex(rowIndex, 5).numberFormat = 'mm/dd/yyyy hh:mm:ss';
      sheet.getRangeByIndex(rowIndex, 6).setText(entry.type);
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/exported_entries_syncfusion.xlsx');
    await file.writeAsBytes(bytes);

    debugPrint('Excel exported to ${file.path}');
  }

  static Future<void> newimportFromExcel(File file) async {
    final categoryBox = Hive.box<CategoryItem>('categories');
    final box = await Hive.openBox<Entry>('entriesbox');

    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) return;

    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      final tag = row[3]?.value.toString() ?? '';
      final type = row[5]?.value.toString() ?? '';

      // Handle category
      if (tag.isNotEmpty) {
        final predefinedMatch = predefinedCategories.firstWhere(
          (cat) => cat.name == tag && cat.type == type,
          orElse:
              () => CategoryItem(
                id: UniqueKey().toString(),
                name: tag,
                type: type,
                iconCodePoint: Icons.category.codePoint,
                fontFamily: Icons.category.fontFamily,
                fontPackage: Icons.category.fontPackage,
                isActive: true,
              ),
        );

        // Check if same category already exists
        CategoryItem? existing;
        try {
          existing = categoryBox.values.firstWhere(
            (c) =>
                c.name == predefinedMatch.name &&
                c.type == predefinedMatch.type,
          );
        } catch (e) {
          existing = null;
        }

        if (existing == null) {
          await categoryBox.put(predefinedMatch.id, predefinedMatch);
        } else {
          final existingCategory = existing; // Now Dart knows it's non-null
          if (existingCategory.isActive != true) {
            existingCategory.isActive = true;
            await existingCategory.save();
          }
        }
      }

      // Create Entry object
      final entry = Entry(
        id: row[0]?.value.toString(),
        title: row[1]?.value.toString() ?? '',
        amount: double.tryParse(row[2]?.value.toString() ?? '0') ?? 0.0,
        tag: tag,
        date:
            DateTime.tryParse(row[4]?.value.toString() ?? '') ?? DateTime.now(),
        type: type,
        lastModified: DateTime.tryParse(row[4]?.value.toString() ?? '') ?? DateTime.now(),
      );

      await box.put(entry.id, entry);
    }

    debugPrint(
      '✅ Imported ${sheet.rows.length - 1} entries from Excel with category activation.',
    );
  }

  /// Export Hive entries to a JSON file
  static Future<void> exportToJson({required String userId}) async {
    final box = await Hive.openBox<Entry>('entriesbox');
    final entries = box.values.toList();

    final jsonList = entries.map((e) => e.toMap(userId)).toList();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/exported_entries.json');
    await file.writeAsString(jsonEncode(jsonList));

    debugPrint('✅ JSON exported to ${file.path}');
  }

  /// Import entries from a JSON file into Hive and activate their categories
  static Future<void> importFromJson(File file) async {
    if (!await file.exists()) {
      debugPrint('❌ JSON file not found: ${file.path}');
      return;
    }

    final contents = await file.readAsString();
    final List<dynamic> jsonData = jsonDecode(contents);

    final box = await Hive.openBox<Entry>('entriesbox');
    final categoryBox = Hive.box<CategoryItem>('categories');

    for (var item in jsonData) {
      final entry = Entry.fromMap(item);
      await box.put(entry.id, entry);

      // Handle category activation
      if (entry.tag.isNotEmpty) {
        final predefinedMatch = predefinedCategories.firstWhere(
          (cat) => cat.name == entry.tag && cat.type == entry.type,
          orElse:
              () => CategoryItem(
                id: UniqueKey().toString(),
                name: entry.tag,
                type: entry.type,
                iconCodePoint: Icons.category.codePoint,
                fontFamily: Icons.category.fontFamily,
                fontPackage: Icons.category.fontPackage,
                isActive: true,
              ),
        );

        CategoryItem? existing;
        try {
          existing = categoryBox.values.firstWhere(
            (c) =>
                c.name == predefinedMatch.name &&
                c.type == predefinedMatch.type,
          );
        } catch (_) {
          existing = null;
        }

        if (existing == null) {
          await categoryBox.put(predefinedMatch.id, predefinedMatch);
        } else if (existing.isActive != true) {
          existing.isActive = true;
          await existing.save();
        }
      }
    }

    debugPrint(
      '✅ Imported ${jsonData.length} entries from JSON with category activation.',
    );
  }
}
