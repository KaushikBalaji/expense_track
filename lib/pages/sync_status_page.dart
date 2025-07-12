import '../services/excel_operations.dart';
import 'package:expense_track/widgets/CustomSidebar.dart';
import 'package:expense_track/widgets/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../models/entry.dart';
import '../services/supabase_services.dart';
import '../widgets/CustomAppBar.dart';

class SyncStatusPage extends StatefulWidget {
  const SyncStatusPage({super.key});

  @override
  State<SyncStatusPage> createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends State<SyncStatusPage> {
  int localCount = 0;
  int cloudCount = 0;
  bool loading = true;
  DateTime? lastSynced;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      final box = await Hive.openBox<Entry>('entriesBox');
      final userId = Supabase.instance.client.auth.currentUser?.id;

      localCount = box.length;

      if (userId != null) {
        final response = await Supabase.instance.client
            .from('entries')
            .select('id')
            .eq('user_id', userId)
            .count();

        cloudCount = response.count;
      } else {
        cloudCount = 0;
      }
    } catch (e) {
      debugPrint('Error fetching counts: $e');
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<bool> ensureUserIsAuthenticated(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) return true;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
        content: AuthDialogContent(onClose: () => Navigator.of(context).pop()),
      ),
    );

    return Supabase.instance.client.auth.currentUser != null;
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Warning!'),
              content: const Text(
                'Are you sure you want to delete all existing entries and import new ones from Excel? This action cannot be undone.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;

    return result;
  }

  Widget buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    //   color: color ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildStatusCard() {
    return buildSectionCard(
      title: 'Sync Overview',
      icon: Icons.cloud_sync,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _infoBox('📦 Local entries', '$localCount'),
            _infoBox('☁️ Cloud entries', '$cloudCount'),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          localCount == cloudCount ? '✅ In Sync' : '⚠️ Not in Sync',
          style: TextStyle(
            color: localCount == cloudCount ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (lastSynced != null)
          Text(
            '🕒 Last synced: ${DateFormat('yyyy-MM-dd HH:mm').format(lastSynced!)}',
            style: const TextStyle(color: Colors.grey),
          ),
      ],
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _handleSyncToDB(BuildContext context) async {
    if (!await ensureUserIsAuthenticated(context)) return;
    setState(() => loading = true);
    final box = Hive.box<Entry>('entriesBox');
    await SupabaseService.syncHiveToSupabase(box);
    lastSynced = DateTime.now();
    await fetchCounts();
  }

  void _handleSyncFromDB(BuildContext context) async {
    if (!await ensureUserIsAuthenticated(context)) return;
    setState(() => loading = true);
    final box = Hive.box<Entry>('entriesBox');
    await SupabaseService.syncSupabaseToHive(box);
    SupabaseService.printAllHiveEntries();
    lastSynced = DateTime.now();
    await fetchCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomSidebar(),
      body: Builder(
        builder: (scaffoldContext) {
          return Column(
            children: [
              CustomAppBar(
                title: 'Export and Sync',
                showBackButton: false,
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      setState(() => loading = true);
                      await fetchCounts();
                    },
                  ),
                ],
              ),
              loading
                  ? const Expanded(child: Center(child: CircularProgressIndicator()))
                  : Expanded(
                      child: Container(
                        // decoration: BoxDecoration(
                        //   gradient: LinearGradient(
                        //     colors: [Colors.white, Colors.grey.shade100],
                        //     begin: Alignment.topCenter,
                        //     end: Alignment.bottomCenter,
                        //   ),
                        // ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildStatusCard(),
                              buildSectionCard(
                                title: 'Sync Actions',
                                icon: Icons.sync,
                                children: [
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _handleSyncToDB(context),
                                        icon: const Icon(Icons.sync),
                                        label: const Text('Sync to DB'),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _handleSyncFromDB(context),
                                        icon: const Icon(Icons.sync_alt),
                                        label: const Text('Sync from DB'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              buildSectionCard(
                                title: 'Clear Entries',
                                icon: Icons.delete_outline,
                                children: [
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final box = Hive.box<Entry>('entriesBox');
                                          await box.clear();
                                          await fetchCounts();
                                        },
                                        icon: const Icon(Icons.delete_forever),
                                        label: const Text('Clear Local'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (!await ensureUserIsAuthenticated(context))
                                            return;

                                          await Supabase.instance.client
                                              .from('entries')
                                              .delete()
                                              .eq(
                                                'user_id',
                                                Supabase.instance.client.auth.currentUser!.id,
                                              );
                                          await fetchCounts();
                                        },
                                        icon: const Icon(Icons.cloud_off),
                                        label: const Text('Clear Cloud'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orangeAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              buildSectionCard(
                                title: 'JSON Operations',
                                icon: Icons.code,
                                children: [
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          const userId = 'local_user';
                                          await ExcelOperationsSyncfusion.exportToJson(
                                            userId: userId,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('JSON export completed successfully.'),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.download),
                                        label: const Text('Export to JSON'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          bool shouldDelete =
                                              await _showConfirmationDialog(context);
                                          if (!shouldDelete) return;

                                          final box = await Hive.openBox<Entry>('entriesBox');
                                          await box.clear();

                                          FilePickerResult? result = await FilePicker.platform
                                              .pickFiles(
                                            type: FileType.custom,
                                            allowedExtensions: ['json'],
                                          );

                                          if (result != null && result.files.single.path != null) {
                                            File jsonFile = File(result.files.single.path!);
                                            try {
                                              await ExcelOperationsSyncfusion.importFromJson(
                                                jsonFile,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'JSON import completed successfully.'),
                                                ),
                                              );
                                              Navigator.pushNamed(context, '/syncstatus');
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to import JSON: $e'),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.cloud_upload),
                                        label: const Text('Import from JSON'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  void ShowBottomModalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: const AuthDialogContent(),
      ),
    );
  }
}
