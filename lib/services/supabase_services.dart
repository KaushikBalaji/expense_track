import 'dart:async';
import 'dart:io';

import 'package:expense_track/pages/dashboard_page.dart';
import 'package:expense_track/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../models/entry.dart';

final supabase = Supabase.instance.client;

class AuthResult {
  final bool success;
  final String? message;

  AuthResult({required this.success, this.message});
}

class SupabaseService {
  static final supabase = Supabase.instance.client;

  static const entryTable = 'entries';
  static String? get userId => supabase.auth.currentUser?.id;

  /// ------------------------
  /// 📡 Connectivity Check
  /// ------------------------
  ///
  Future<bool> hasInternetConnection() async {
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

  /// ------------------------
  /// 🔐 AUTH METHODS
  /// ------------------------
  ///

  Future<void> handleAuth({
    required String email,
    required String password,
    String? name, // Only for signup
    required bool isLogin,
  }) async {
    // Input validation
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
      print(e);
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

  /// ------------------------
  /// 🔄 SYNC METHODS
  /// ------------------------

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

    print('⬇️ Fetching entries from Supabase...');

    try {
      final response = await supabase
          .from(entryTable)
          .select()
          .eq('user_id', userId!);

      final List<dynamic> data = response;

      print('📥 Fetched ${data.length} entries from Supabase.');

      for (final entry in data) {
        final id = entry['id'].toString();

        print('🧾 Entry from Supabase: $entry');
        print('🔍 Hive containsKey($id)? ${box.containsKey(id)}');

        if (!box.containsKey(id)) {
          final hiveEntry = Entry.fromMap(entry);
          box.put(id, hiveEntry);
          print('💾 Saved entry to Hive: ${hiveEntry.id}');
        } else {
          print('⏩ Entry already exists in Hive. Skipping: $id');
        }
      }
    } catch (e) {
      print('❌ Error fetching entries from Supabase: $e');
    }
  }
}
