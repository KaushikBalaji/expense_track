import 'package:expense_track/widgets/CustomSidebar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> fetchCounts() async {
    try {
      final box = await Hive.openBox<Entry>('entriesbox');
      final userId = Supabase.instance.client.auth.currentUser?.id;
      localCount = box.length;

      final response =
          await Supabase.instance.client
              .from('entries')
              .select('id')
              .eq('user_id', userId!)
              .count();

      cloudCount = response.count ?? 0;
    } catch (e) {
      print('Error fetching counts: $e');
    }

    setState(() => loading = false);
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
                                      setState(() => loading = true);
                                      final box = Hive.box<Entry>('entriesbox');
                                      await SupabaseService.syncHiveToSupabase(
                                        box,
                                      );
                                      await fetchCounts();
                                    },
                                    icon: const Icon(Icons.sync),
                                    label: const Text('Sync to DB'),
                                  ),
                                  SizedBox(width: 15),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      setState(() => loading = true);
                                      final box = Hive.box<Entry>('entriesbox');
                                      await SupabaseService.syncSupabaseToHive(
                                        box,
                                      );
                                      await fetchCounts();
                                    },
                                    icon: const Icon(Icons.sync),
                                    label: const Text('Sync from DB'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

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
                                      setState(() => loading = true);
                                      final userId =
                                          Supabase
                                              .instance
                                              .client
                                              .auth
                                              .currentUser
                                              ?.id;
                                      await Supabase.instance.client
                                          .from('entries')
                                          .delete()
                                          .eq('user_id', userId!);
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
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
