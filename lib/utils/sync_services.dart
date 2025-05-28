import 'package:expense_track/models/entry.dart';
import 'package:expense_track/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

int parseSyncFrequency(String freq) {
  switch (freq) {
    case 'Daily':
      return 1;
    case 'Weekly':
      return 7;
    case 'Monthly':
      return 30;
    default:
      final days = int.tryParse(freq);
      return days != null && days > 0 ? days : 1;
  }
}

Future<Map<String, dynamic>> trySyncData({bool force = false}) async {
  final prefs = await SharedPreferences.getInstance();

  final syncFrequency = prefs.getString('syncFrequency') ?? 'Daily';
  final intervalDays = parseSyncFrequency(syncFrequency);

  final lastSyncMillis = prefs.getInt('lastSyncTimestamp') ?? 0;
  final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
  final now = DateTime.now();

  final daysPassed = now.difference(lastSyncDate).inDays;

  if (force || daysPassed >= intervalDays) {
    await performSync();
    await prefs.setInt('lastSyncTimestamp', now.millisecondsSinceEpoch);
    return {
      'lastSync': now,
      'nextSyncInDays': intervalDays,
      'message': 'Sync performed just now.'
    };
  } else {
    final nextSyncInDays = intervalDays - daysPassed;
    return {
      'lastSync': lastSyncDate,
      'nextSyncInDays': nextSyncInDays,
      'message': 'Sync skipped. Next sync in $nextSyncInDays day(s).'
    };
  }
}


Future<void> performSync() async {
  final userId = SupabaseService.userId; // get logged-in user ID appropriately
  if (userId == null) {
    debugPrint('User not authenticated; skipping sync');
    return;
  }

  await SupabaseService.uploadAllActiveCategories(userId);
  debugPrint('Categories sync done ✅');
  final entriesBox = Hive.box<Entry>('entriesBox');
  await SupabaseService.syncHiveToSupabase(entriesBox);
  debugPrint('Entries sync done ✅');


  debugPrint('Sync complete.');
}
