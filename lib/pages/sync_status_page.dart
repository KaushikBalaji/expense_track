import '../services/excel_operations.dart';
import 'package:expense_track/widgets/CustomSidebar.dart';
import 'package:expense_track/widgets/auth_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../models/entry.dart';
import '../services/supabase_services.dart';
import '../widgets/CustomAppBar.dart';

import '../services/hive_service.dart';

class SyncStatusPage extends StatefulWidget {
  const SyncStatusPage({super.key});

  @override
  State<SyncStatusPage> createState() => _SyncStatusPageState();
}

class _SyncStatusPageState extends State<SyncStatusPage> {
  int localCount = 0;
  int cloudCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  // Future<void> fetchCounts() async {
  //   try {
  //     final box = await Hive.openBox<Entry>('entriesbox');
  //     final userId = Supabase.instance.client.auth.currentUser?.id;
  //     localCount = box.length;

  //     final response =
  //         await Supabase.instance.client
  //             .from('entries')
  //             .select('id')
  //             .eq('user_id', userId!)
  //             .count();

  //     cloudCount = response.count ?? 0;
  //   } catch (e) {
  //     print('Error fetching counts: $e');
  //   }

  //   setState(() => loading = false);
  // }

  Future<void> fetchCounts() async {
    try {
      final box = await Hive.openBox<Entry>('entriesbox');
      final userId = Supabase.instance.client.auth.currentUser?.id;

      localCount = box.length;

      if (userId != null) {
        final response =
            await Supabase.instance.client
                .from('entries')
                .select('id')
                .eq('user_id', userId)
                .count();

        cloudCount = response.count ?? 0;
      } else {
        cloudCount = 0; // Or: null, or skip updating, as needed
        print('User not logged in; skipping cloud count');
      }
    } catch (e) {
      print('Error fetching counts: $e');
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    final result =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Prevent dismissing by tapping outside
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Warning!'),
              content: const Text(
                'Are you sure you want to delete all existing entries and import new ones from Excel? This action cannot be undone.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User cancels
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirms
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomSidebar(),
      body: Builder(
        builder: (scaffoldContext) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomAppBar(
                title: 'Sync Status',
                showBackButton: false,
                leading: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(scaffoldContext).openDrawer();
                  },
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

              Expanded(
                child:
                    loading
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '📦 Local entries: $localCount',
                                //style: Theme.of(context).textTheme.headline6,
                              ),
                              Text(
                                '☁️ Cloud entries: $cloudCount',
                                //style: Theme.of(context).textTheme.headline6,
                              ),
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final user =
                                          Supabase
                                              .instance
                                              .client
                                              .auth
                                              .currentUser;

                                      if (user == null) {
                                        if (Navigator.canPop(context)) {
                                          Navigator.of(
                                            context,
                                          ).pop(); // Close the drawer
                                        }
                                        showDialog(
                                          context: context,
                                          builder:
                                              (_) => AlertDialog(
                                                contentPadding:
                                                    const EdgeInsets.all(24),
                                                content:
                                                    const AuthDialogContent(),
                                              ),
                                        );
                                      } else {
                                        setState(() => loading = true);
                                        final box = Hive.box<Entry>(
                                          'entriesbox',
                                        );
                                        await SupabaseService.syncHiveToSupabase(
                                          box,
                                        );
                                        await fetchCounts();
                                      }
                                    },
                                    icon: const Icon(Icons.sync),
                                    label: const Text('Sync to DB'),
                                  ),
                                  SizedBox(width: 15),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final user =
                                          Supabase
                                              .instance
                                              .client
                                              .auth
                                              .currentUser;
                                      //print(user);
                                      if (user == null) {
                                        if (Navigator.canPop(context)) {
                                          Navigator.of(
                                            context,
                                          ).pop(); // Close the drawer
                                        }
                                        showDialog(
                                          context: context,
                                          builder:
                                              (_) => AlertDialog(
                                                contentPadding:
                                                    const EdgeInsets.all(24),
                                                content:
                                                    const AuthDialogContent(),
                                              ),
                                        );
                                      } else {
                                        setState(() => loading = true);
                                        final box = Hive.box<Entry>(
                                          'entriesbox',
                                        );
                                        await SupabaseService.syncSupabaseToHive(
                                          box,
                                        );
                                        await fetchCounts();
                                      }
                                    },
                                    icon: const Icon(Icons.sync),
                                    label: const Text('Sync from DB'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              // Clear entries part
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      setState(() => loading = true);
                                      final box = Hive.box<Entry>('entriesbox');
                                      await box.clear();
                                      await fetchCounts();
                                    },
                                    icon: const Icon(Icons.delete_forever),
                                    label: const Text('Clear Local'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 15),

                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final userId =
                                          Supabase
                                              .instance
                                              .client
                                              .auth
                                              .currentUser!
                                              .id;

                                      setState(() => loading = true);
                                      await Supabase.instance.client
                                          .from('entries')
                                          .delete()
                                          .eq('user_id', userId);
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
                              const SizedBox(height: 15),

                              // Excel ops part
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await ExcelOperationsSyncfusion.exportToExcel();
                                    },
                                    icon: const Icon(Icons.download),
                                    label: const Text('Export Local to Excel'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  ElevatedButton.icon(
                                    // onPressed: () {
                                    //   print('Excel to Local pressed');
                                    // },
                                    onPressed: () async {
                                      // Show confirmation dialog before importing
                                      bool shouldDelete =
                                          await _showConfirmationDialog(
                                            context,
                                          );
                                      if (shouldDelete) {
                                        // If user confirms, delete all existing entries in Hive
                                        final box = await Hive.openBox<Entry>(
                                          'entriesbox',
                                        );
                                        await box
                                            .clear(); // This deletes all entries in the box

                                        // Now proceed with file picking and import
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: ['xlsx'],
                                            );

                                        if (result != null) {
                                          final path = result.files.single.path;
                                          if (path != null) {
                                            File excelFile = File(path);
                                            try {
                                              await ExcelOperationsSyncfusion.importFromExcel(
                                                excelFile,
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Excel import completed successfully.',
                                                  ),
                                                ),
                                              );
                                              Navigator.pushNamed(context, '/syncstatus');
                                            } catch (e) {
                                              print('Error during import: $e');
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to import: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      } else {
                                        print('Import cancelled by user.');
                                      }
                                    },
                                    icon: const Icon(Icons.cloud_download),
                                    label: const Text('Excel to LOcal'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orangeAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
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
