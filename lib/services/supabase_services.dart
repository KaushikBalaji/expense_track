import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
// ignore: unused_import
import 'package:uuid/uuid.dart';

import '../models/entry.dart';

final supabase = Supabase.instance.client;

class SupabaseService {

  static final SupabaseClient client = SupabaseClient('https://qjjooylsjtrdvmnnvnhx.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqam9veWxzanRyZHZtbm52bmh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMzcyMDQsImV4cCI6MjA2MjgxMzIwNH0.npHvRdDTqudBWJiLpFVjPTsdy3pZ_z7yDpHqmdBe0FM');
  static const entryTable = 'entries';

  static String? get userId => supabase.auth.currentUser?.id;

  /// Upload all Hive entries to Supabase
  static Future<void> syncHiveToSupabase(Box box) async {
    if (userId == null) return;

    final entries = box.values.toList();

    for (final entry in entries) {
      try {

        await supabase.from(entryTable).upsert({
          'type': entry.type.toString().toLowerCase(),
          'amount': entry.amount,
          'note': entry.title,
          'date': entry.date.toIso8601String(),
          'tag': entry.tag,
          'user_id': userId,
          'id': entry.id
        });

        print('Sync success');
      } catch (e) {
        print('Error syncing entry ${entry.id}: $e');
      }
    }
  }

  /// Download Supabase entries for this user and insert into Hive
  static Future<void> syncSupabaseToHive(Box box) async {
    if (userId == null) return;

    final response = await supabase
        .from(entryTable)
        .select()
        .eq('user_id', userId.toString());

    final List data = response;

    for (final entry in data) {
      final id = entry['id'];
      if (!box.containsKey(id)) {
        box.put(id, Entry.fromMap(entry));
      }
    }
  }
}
