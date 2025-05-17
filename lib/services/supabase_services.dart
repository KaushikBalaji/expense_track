import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
// ignore: unused_import
import 'package:uuid/uuid.dart';

import '../models/entry.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  static final SupabaseClient client = SupabaseClient(
    'https://qjjooylsjtrdvmnnvnhx.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqam9veWxzanRyZHZtbm52bmh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMzcyMDQsImV4cCI6MjA2MjgxMzIwNH0.npHvRdDTqudBWJiLpFVjPTsdy3pZ_z7yDpHqmdBe0FM',
  );

  static const entryTable = 'entries';
  static String? get userId => supabase.auth.currentUser?.id;

  /// Upload all Hive entries to Supabase
  static Future<void> syncHiveToSupabase(Box box) async {
    if (userId == null) {
      print('⚠️ User not authenticated');
      return;
    }

    final entries = box.values.toList();

    print('⬆️ Uploading ${entries.length} entries to Supabase...');

    for (final entry in entries) {
      print('🔄 Uploading entry: ${entry.id}');

      final data = {
        'id': entry.id.toString(),
        'user_id': userId,
        'type': entry.type.toString(),
        'amount': entry.amount,
        'note': entry.title,
        'date': entry.date.toIso8601String(),
        'tag': entry.tag,
      };

      print('📦 Data to upload: $data');

      try {
        await supabase.from(entryTable).upsert(data);
        print('✅ Sync success: ${entry.id}');
      } catch (e) {
        print('❌ Error syncing entry ${entry.id}: $e');
      }
    }
  }

  /// Download Supabase entries for this user and insert into Hive
  static Future<void> syncSupabaseToHive(Box box) async {
    if (userId == null) {
      print('⚠️ User not authenticated');
      return;
    }

    final categoriesBox = Hive.box<String>('categories');

    print('⬇️ Fetching entries from Supabase...');

    final response = await supabase
        .from(entryTable)
        .select()
        .eq('user_id', userId!);

    final List<dynamic> data = response;

    print('📥 Fetched ${data.length} entries from Supabase.');

    for (final entry in data) {
      final id = entry['id'].toString();
      final tag = entry['tag']?.toString() ?? '';

      print('🧾 Entry from Supabase: $entry');
      print('🔍 Hive containsKey($id)? ${box.containsKey(id)}');

      if (tag.isNotEmpty && !categoriesBox.values.contains(tag)) {
        print('➕ Adding new tag to categories: $tag');
        categoriesBox.add(tag);
      }

      if (!box.containsKey(id)) {
        final hiveEntry = Entry.fromMap(entry);
        box.put(id, hiveEntry);
        print('💾 Saved entry to Hive: ${hiveEntry.id}');
      } else {
        print('⏩ Entry already exists in Hive. Skipping: $id');
      }
    }
  }
}
