// import 'dart:io';
// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart';
// import '../models/entry.dart';

// class ExcelOperationsSyncfusion {
//   static const String sheetName = 'Entries';

//   static Future<void> exportToExcel() async {
//     final box = await Hive.openBox<Entry>('entriesbox');
//     final entries = box.values.toList();

//     final Workbook workbook = Workbook();
//     final Worksheet sheet = workbook.worksheets[0];
//     sheet.name = sheetName;

//     // Add header
//     final headers = ['ID', 'Title', 'Amount', 'Tag', 'Date', 'Type'];
//     for (int i = 0; i < headers.length; i++) {
//       sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
//     }

//     // Add data rows
//     for (int i = 0; i < entries.length; i++) {
//       final entry = entries[i];
//       final rowIndex = i + 2; // data starts from row 2

//       sheet.getRangeByIndex(rowIndex, 1).setText(entry.id);
//       sheet.getRangeByIndex(rowIndex, 2).setText(entry.title);
//       sheet.getRangeByIndex(rowIndex, 3).setNumber(entry.amount);
//       sheet.getRangeByIndex(rowIndex, 4).setText(entry.tag);
//       sheet.getRangeByIndex(rowIndex, 5).dateTime = entry.date;
//       sheet.getRangeByIndex(rowIndex, 5).numberFormat = 'mm/dd/yyyy hh:mm:ss';
//       sheet.getRangeByIndex(rowIndex, 6).setText(entry.type);
//     }

//     final List<int> bytes = workbook.saveAsStream();
//     workbook.dispose();

//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/exported_entries_syncfusion.xlsx');
//     await file.writeAsBytes(bytes);

//     print('Excel exported to ${file.path}');
//   }

//   static Future<void> importFromExcel(File file) async {
//     final bytes = await file.readAsBytes();

//     // Importing Excel is currently limited with this package.
//     // For reading, consider `excel` package or convert XLSX to CSV first.
//     // As a workaround, here you can parse XLSX using 'excel' package, then use Syncfusion for export only.
//     throw UnimplementedError('Importing from Excel is not implemented with Syncfusion. Use the "excel" package or CSV parsing for reading.');
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import '../models/entry.dart';

class ExcelOperationsSyncfusion {
  static const String sheetName = 'Entries';

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

    print('Excel exported to ${file.path}');
  }

  /// Placeholder – Syncfusion doesn't support reading XLSX directly
  static Future<void> importFromExcel(File file) async {
    final categoriesBox = Hive.box<String>('categories');
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) return;

    final box = await Hive.openBox<Entry>('entriesbox');

    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      final tag = row[3]?.value.toString() ?? '';

      if (tag.isNotEmpty && !categoriesBox.values.contains(tag)) {
        categoriesBox.add(tag);
      }

      final entry = Entry(
        id: row[0]?.value.toString(),
        title: row[1]?.value.toString() ?? '',
        amount: double.tryParse(row[2]?.value.toString() ?? '0') ?? 0.0,
        tag: row[3]?.value.toString() ?? '',
        date:
            DateTime.tryParse(row[4]?.value.toString() ?? '') ?? DateTime.now(),
        type: row[5]?.value.toString() ?? '',
      );

      await box.put(entry.id, entry);
    }

    print('Imported ${sheet.rows.length - 1} entries from Excel.');
  }

  /// Export Hive entries to a JSON file
  static Future<void> exportToJson({required String userId}) async {
    final box = await Hive.openBox<Entry>('entriesbox');
    final entries = box.values.toList();

    final jsonList = entries.map((e) => e.toMap(userId)).toList();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/exported_entries.json');
    await file.writeAsString(jsonEncode(jsonList));

    print('JSON exported to ${file.path}');
  }

  /// Import entries from a JSON file into Hive
  static Future<void> importFromJson(File file) async {
    if (!await file.exists()) {
      print('JSON file not found: ${file.path}');
      return;
    }

    final contents = await file.readAsString();
    final List<dynamic> jsonData = jsonDecode(contents);

    final box = await Hive.openBox<Entry>('entriesbox');

    for (var item in jsonData) {
      final entry = Entry.fromMap(item);
      await box.put(entry.id, entry); // or add(entry) if you want auto keys
    }

    print('Imported ${jsonData.length} entries from JSON.');
  }
}
