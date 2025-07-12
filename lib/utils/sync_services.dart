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
      if (freq.startsWith('custom:')) {
        final customDays = int.tryParse(freq.split(':').last);
        return (customDays != null && customDays > 0) ? customDays : 1;
      }
      final days = int.tryParse(freq);
      return days != null && days > 0 ? days : 1;
  }
}

Future<Map<String, dynamic>> trySyncData({bool force = false}) async {
  final prefs = await SharedPreferences.getInstance();

  final syncMode = prefs.getString('syncMode') ?? 'auto'; // default
  final syncFrequency = prefs.getString('syncFrequency') ?? 'Daily';
  final intervalDays = parseSyncFrequency(syncFrequency);

  final lastSyncMillis = prefs.getInt('lastSyncTimestamp') ?? 0;
  final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
  final today = DateTime.now();
  final lastDate = DateTime(
    lastSyncDate.year,
    lastSyncDate.month,
    lastSyncDate.day,
  );
  final daysPassed = today.difference(lastDate).inDays;

  debugPrint('Sync Mode: $syncMode');
  debugPrint('Sync Frequency: $syncFrequency');
  debugPrint('Last Sync: $lastSyncDate');

  if (syncMode == 'paused') {
    debugPrint('Sync is paused');
    return {
      'lastSync': lastSyncDate,
      'nextSyncInDays': null,
      'message': 'Sync is paused.',
    };
  }

  if (syncMode == 'offline') {
    debugPrint('Offline mode enabled — no sync allowed');
    return {
      'lastSync': null,
      'nextSyncInDays': null,
      'message': 'Offline mode: local-only usage',
    };
  }

  if (syncMode == 'manual' && !force) {
    debugPrint('Manual sync only. Skipping auto sync.');
    return {
      'lastSync': lastSyncDate,
      'nextSyncInDays': null,
      'message': 'Manual mode: waiting for user to sync manually.',
    };
  }

  if (syncFrequency == 'Never') {
    debugPrint('Sync disabled by frequency setting');
    return {
      'lastSync': null,
      'nextSyncInDays': null,
      'message': 'Sync disabled (Never)',
    };
  }

  // Auto sync logic
  if (force || daysPassed >= intervalDays) {
    await performSync();
    await prefs.setInt(
      'lastSyncTimestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
    return {
      'lastSync': DateTime.now(),
      'nextSyncInDays': intervalDays,
      'message': 'Sync performed successfully.',
    };
  } else {
    final nextSyncInDays = intervalDays - daysPassed;
    return {
      'lastSync': lastSyncDate,
      'nextSyncInDays': nextSyncInDays,
      'message': 'Sync skipped. $nextSyncInDays day(s) until next sync.',
    };
  }
}

Future<void> performSync() async {
  final userId = SupabaseService.userId; // get logged-in user ID appropriately
  if (userId == null) {
    debugPrint('User not authenticated; skipping sync');
    return;
  }

  await SupabaseService.uploadAllCategoriesStatus(userId);
  debugPrint('Categories sync done ✅');
  final entriesBox = Hive.box<Entry>('entriesBox');
  await SupabaseService.syncHiveToSupabase(entriesBox);
  debugPrint('Entries sync done ✅');

  debugPrint('Sync complete.');
}
