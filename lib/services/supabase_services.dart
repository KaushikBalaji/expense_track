import 'dart:async';
import 'dart:io';

import 'package:expense_track/models/category_item.dart';
import 'package:expense_track/pages/dashboard_page.dart';
import 'package:expense_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../utils/predefined_categories.dart';
import '../models/entry.dart';

final supabase = Supabase.instance.client;
final categoryStatus = Hive.box<List>('categorystatus');

class AuthResult {
  final bool success;
  final String? message;

  AuthResult({required this.success, this.message});
}

class SupabaseService {
  static final supabase = Supabase.instance.client;

  static const entryTable = 'entries';
  static String? get userId => supabase.auth.currentUser?.id;
  static final Box<Entry> entryBox = Hive.box<Entry>('entriesBox');

  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final response = await http
            .get(Uri.parse('https://example.com'))
            .timeout(const Duration(seconds: 3));
        return response.statusCode == 200;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> handleAuth({
    required String email,
    required String password,
    String? name,
    required bool isLogin,
  }) async {
    final emailError = InputValidators.Validate(email, 'email');
    final passwordError = InputValidators.Validate(password, 'password');
    final nameError =
        isLogin ? null : InputValidators.Validate(name ?? '', 'name');

    if (emailError != null || passwordError != null || nameError != null) {
      throw Exception(
        [
          if (emailError != null) emailError,
          if (passwordError != null) passwordError,
          if (nameError != null) nameError,
        ].join('\n'),
      );
    }

    if (!await hasInternetConnection()) {
      throw Exception('No internet connection.');
    }

    try {
      if (isLogin) {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        await supabase.auth.signUp(email: email, password: password);
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials')) {
        throw Exception('Incorrect email or password.');
      } else if (msg.contains('email not confirmed')) {
        throw Exception('Confirm your email before logging in');
      } else if (msg.contains('user already registered')) {
        throw Exception('Account with this email already exists');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('An unexpected error occurred during authentication.');
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    final service = SupabaseService();

    try {
      await service.signOut();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logged out successfully")));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) async {
    await supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (_) {}
  }

  static Future<void> deleteEntry(Entry entry) async {
    debugPrint('EntryBox open status: ${entryBox.isOpen}');
    final deletedBox = Hive.box<List>('deletedEntries');
    final deletedIds =
        deletedBox.get('deletedIds', defaultValue: <String>[])!.toSet();
    deletedIds.add(entry.id.toString());
    await deletedBox.put('deletedIds', deletedIds.toList());
    debugPrint('ID: $deletedIds added to deletedBox');

    // ❗ Get fresh reference from box before deleting
    final boxEntry = entryBox.get(entry.id);
    if (boxEntry != null) {
      await boxEntry.delete();
      debugPrint('Entry ${entry.id} deleted from entryBox');
    } else {
      debugPrint('Entry ${entry.id} not found in entryBox');
    }
  }

  static Future<void> syncHiveToSupabase(Box box) async {
    if (userId == null) {
      debugPrint('⚠️ User not authenticated');
      return;
    }

    await syncDeletedEntries();

    final entries = box.values.toList();
    debugPrint('⬆️ Uploading ${entries.length} entries to Supabase...');

    for (final entry in entries) {
      debugPrint('🔄 Uploading entry: ${entry.id}');
      final data = {
        'id': entry.id.toString(),
        'user_id': userId,
        'type': entry.type.toString(),
        'amount': entry.amount,
        'note': entry.title,
        'date': entry.date.toIso8601String(),
        'tag': entry.tag,
        'last_modified':entry.lastModified.toIso8601String(),
        
      };
      debugPrint('📦 Data to upload: $data');

      try {
        await supabase.from(entryTable).upsert(data);
        debugPrint('✅ Sync success: ${entry.id}');
      } catch (e) {
        debugPrint('❌ Error syncing entry ${entry.id}: $e');
      }
    }
  }

  static Future<void> markEntryAsDeleted(String entryId) async {
    final box = Hive.box<List>('deletedEntries');
    final deletedIds = box.get('deletedIds', defaultValue: <String>[])!.toSet();
    deletedIds.add(entryId);
    await box.put('deletedIds', deletedIds.toList());
    await entryBox.delete(entryId);
  }

  static Future<void> syncDeletedEntries() async {
    if (userId == null) {
      debugPrint('⚠️ User not authenticated');
      return;
    }
    final deletedBox = Hive.box<List>('deletedEntries');
    final deletedIds =
        deletedBox.get('deletedIds', defaultValue: <String>[])!.toList();

    if (deletedIds.isEmpty) {
      debugPrint('No deleted entries to sync.');
      return;
    }

    debugPrint('🗑️ Deleting ${deletedIds.length} entries from Supabase...');

    try {
      for (final id in deletedIds) {
        debugPrint('Attempting to delete entry $id for user $userId');
        final response = await supabase
            .from(entryTable)
            .delete()
            .eq('id', id.toString())
            .eq('user_id', userId!);
        debugPrint('🗑️ Deletion response for $id: $response');
      }

      await deletedBox.put('deletedIds', []);
    } catch (e) {
      debugPrint('❌ Error deleting entries from Supabase: $e');
    }
  }

  static void printAllHiveEntries() {
    final box = Hive.box<Entry>('entriesBox');

    debugPrint('📦 Hive contains ${box.length} entries:');

    for (final key in box.keys) {
      final entry = box.get(key);

      if (entry == null) continue;

      debugPrint(
        '🔑 Hive Key: $key | 🆔 Entry ID: ${entry.id} | 💰 Amount: ${entry.amount} | 📝 Note: ${entry.title} | 📅 Date: ${entry.date}',
      );
    }
  }

  static Future<void> syncSupabaseToHive(Box box) async {
    if (userId == null) {
      debugPrint('⚠️ User not authenticated');
      return;
    }

    debugPrint('⬇️ Fetching entries from Supabase...');

    try {
      final response = await supabase
          .from(entryTable)
          .select()
          .eq('user_id', userId!);

      final List<dynamic> data = response;
      debugPrint('📥 Fetched ${data.length} entries from Supabase.');

      for (final entry in data) {
        final id = entry['id'].toString();
        debugPrint('🧾 Entry from Supabase: $entry');

        final hiveEntry = Entry.fromMap(entry);

        if (box.containsKey(id)) {
          // Update existing entry in Hive with latest data from Supabase
          await box.put(id, hiveEntry);
          debugPrint('🔄 Updated existing entry in Hive: $id');
        } else {
          final localEntry = box.get(id) as Entry;
          if (hiveEntry.lastModified.isAfter(localEntry.lastModified)) {
            box.put(id, hiveEntry);
            debugPrint('🔄 Updated entry $id (newer from Supabase)');
          } else {
            debugPrint('✅ Local entry $id is up to date');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching entries from Supabase: $e');
    }
  }

  static Future<void> clearAndSyncCategoriesFromSupabase(String userId) async {
    final categoryBox = Hive.box<CategoryItem>('categories');
    await categoryBox.clear();

    final response = await supabase
        .from('categories')
        .select('id, is_active')
        .eq('user_id', userId);

    final activeIds = <String>[
      for (var item in response)
        if (item['is_active'] == true) item['id'] as String,
    ];

    for (final id in activeIds) {
      CategoryItem? predefined;
      try {
        predefined = predefinedCategories.firstWhere((cat) => cat.id == id);
      } catch (_) {
        predefined = null;
      }

      if (predefined != null) {
        final newItem = CategoryItem(
          id: predefined.id,
          name: predefined.name,
          type: predefined.type,
          iconCodePoint: predefined.iconCodePoint,
          fontFamily: predefined.fontFamily,
          fontPackage: predefined.fontPackage,
          isActive: true,
        );
        await categoryBox.put(id, newItem);
      } else {
        debugPrint('⚠️ Unknown category ID from Supabase: $id');
      }
    }
  }

  // Upload all categories with their active status to Supabase
  static Future<void> uploadAllCategoriesStatus(String userId) async {
    final categoryBox = Hive.box<CategoryItem>('categories');
    final uploads =
        categoryBox.values.map((item) {
          return {
            'id': item.id,
            'user_id': userId,
            //'name': item.name,
            //'type': item.type,
            //'icon_code_point': item.iconCodePoint,
            //'font_family': item.fontFamily,
            //'font_package': item.fontPackage,
            'is_active': item.isActive,
          };
        }).toList();

    try {
      await supabase
          .from('categories')
          .upsert(uploads, onConflict: 'user_id,id');
      debugPrint(
        'Uploaded ${uploads.length} categories with status to Supabase.',
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    }
  }
}
