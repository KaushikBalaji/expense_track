import 'package:expense_track/services/supabase_services.dart';
import 'package:expense_track/utils/sync_services.dart';
import 'package:expense_track/widgets/dashboard_charts.dart';
import 'package:expense_track/widgets/date_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/entry.dart';
import '../widgets/CustomAppbar.dart';
import '../widgets/CustomSidebar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedMonth = DateTime.now();

  late Box<Entry> _box;
  double _totalIncome = 0;
  double _totalExpenses = 0;
  List<ChartData> _incomeChartData = [];
  List<ChartData> _expenseChartData = [];

  DateTime? _lastSync;
  int _nextSyncInDays = 0;
  bool _hasInternet = true;
  bool _isSynced = false;
  String _syncMessage = '';
  String _syncFrequency = 'Daily';

  double get getBalance => _totalIncome - _totalExpenses;
  String get curMonthLabel => DateFormat.yMMMM().format(_selectedMonth);

  DateRangeType _selectedRange = DateRangeType.monthly;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Entry>('entriesBox');
    _calculateSummary();
    _generateChartData();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final internet = await SupabaseService.hasInternetConnection();

    final lastMillis = prefs.getInt('lastSyncTimestamp') ?? 0;
    final lastSync =
        lastMillis > 0 ? DateTime.fromMillisecondsSinceEpoch(lastMillis) : null;

    final freq = prefs.getString('syncFrequency') ?? 'Daily';
    final days = parseSyncFrequency(freq);
    final now = DateTime.now();
    final nextSyncIn =
        lastSync != null ? days - now.difference(lastSync).inDays : 0;

    setState(() {
      _hasInternet = internet;
      _lastSync = lastSync;
      _syncFrequency = freq;
      _nextSyncInDays = nextSyncIn;
      _isSynced = nextSyncIn <= 0;
      _syncMessage =
          nextSyncIn <= 0
              ? 'Next sync happening now or soon.'
              : '$nextSyncIn day(s) left for next sync';
    });
  }

  void _calculateSummary() {
    final entries = _getFilteredEntries();

    double income = 0;
    double expenses = 0;

    for (var e in entries) {
      if (e.type.toLowerCase() == 'income') {
        income += e.amount;
      } else {
        expenses += e.amount;
      }
    }

    setState(() {
      _totalIncome = income;
      _totalExpenses = expenses;
    });
  }

  void _generateChartData() {
    final entries = _getFilteredEntries();

    if (entries.isEmpty) {
      setState(() {
        _incomeChartData = [];
        _expenseChartData = [];
      });
      return;
    }

    final Map<String, double> incomeSums = {};
    final Map<String, double> expenseSums = {};

    for (var entry in entries) {
      final tag = entry.tag;
      if (entry.type.toLowerCase() == 'income') {
        incomeSums[tag] = (incomeSums[tag] ?? 0) + entry.amount;
      } else {
        expenseSums[tag] = (expenseSums[tag] ?? 0) + entry.amount;
      }
    }

    final List<Color> defaultColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
    ];

    int colorIndex = 0;
    _incomeChartData =
        incomeSums.entries.map((e) {
          return ChartData(
            e.key,
            e.value,
            defaultColors[colorIndex++ % defaultColors.length],
          );
        }).toList();

    colorIndex = 0;
    _expenseChartData =
        expenseSums.entries.map((e) {
          return ChartData(
            e.key,
            e.value,
            defaultColors[colorIndex++ % defaultColors.length],
          );
        }).toList();

    setState(() {});
  }

  void _onCategoryTap(String type, String category) {
    String normalizedType = type.trim().toLowerCase();
    if (normalizedType == 'expenses') normalizedType = 'expense';
    if (normalizedType == 'incomes') normalizedType = 'income';

    final normalizedCategory = category.trim().toLowerCase();

    final entries =
        _getFilteredEntries().where((entry) {
          final entryType = entry.type.trim().toLowerCase();
          final entryTag = entry.tag.trim().toLowerCase();

          return entryType == normalizedType && entryTag == normalizedCategory;
        }).toList();

    double totalAmount = entries.fold(0, (sum, e) => sum + e.amount);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${_capitalize(category)} (${entries.length})',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                normalizedType == 'income'
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          entries.isEmpty
                              ? const Center(
                                child: Text(
                                  "No entries found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                              : ListView.separated(
                                controller: scrollController,
                                itemCount: entries.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final entry = entries[index];
                                  return Material(
                                    color: Theme.of(context).cardColor,
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat.yMMMd().format(
                                                  entry.date,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '₹${entry.amount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  normalizedType == 'income'
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Iterable<Entry> _getFilteredEntries() {
    if (_selectedRange == DateRangeType.custom && _customRange != null) {
      return _box.values.where(
        (entry) =>
            entry.date.isAfter(
              _customRange!.start.subtract(const Duration(days: 1)),
            ) &&
            entry.date.isBefore(_customRange!.end.add(const Duration(days: 1))),
      );
    }

    if (_selectedRange == DateRangeType.yearly) {
      return _box.values.where(
        (entry) => entry.date.year == _selectedMonth.year,
      );
    }

    // Monthly (default)
    return _box.values.where(
      (entry) =>
          entry.date.month == _selectedMonth.month &&
          entry.date.year == _selectedMonth.year,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomSidebar(),
      body: Builder(
        builder: (scaffoldContext) {
          return SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(), // Dismiss dropdown
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomAppBar(
                      title: 'Dashboard',
                      showBackButton: false,
                      leading: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(scaffoldContext).openDrawer();
                        },
                      ),
                      actions: [
                        const SizedBox(width: 8),
                        PopupMenuButton<int>(
                          offset: Offset(0, 40),
                          icon: Icon(
                            _hasInternet ? Icons.cloud_done : Icons.cloud_off,
                            color: _hasInternet ? Colors.green : Colors.orange,
                          ),
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  enabled: false,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '📶 Internet: ${_hasInternet ? "Connected" : "No Connection"}',
                                      ),
                                      Text(
                                        '🔄 Sync Info',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '📅 Last Sync: ${_lastSync != null ? _lastSync!.toLocal().toString().split('.')[0] : "Never"}',
                                      ),
                                      Text('⏳ Next Sync: $_syncMessage'),
                                      Text('🔁 Frequency: $_syncFrequency'),

                                      const Divider(),
                                      TextButton.icon(
                                        onPressed:
                                            _hasInternet
                                                ? () async {
                                                  await trySyncData(
                                                    force: true,
                                                  );
                                                  await _loadSyncStatus();
                                                  Navigator.pop(context);
                                                }
                                                : null, // disables button when false
                                        icon: const Icon(Icons.sync),
                                        label: const Text('Sync Now'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),

                    // Summary Cards
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildCard(
                            'Total Expenses',
                            '₹ ${_totalExpenses.toStringAsFixed(2)}',
                            Colors.red,
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            'Total Income',
                            '₹ ${_totalIncome.toStringAsFixed(2)}',
                            Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            'Balance',
                            '₹ ${getBalance.toStringAsFixed(2)}',
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),

                    // Date Selector moved here
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DateSelector(
                        selectedRange: _selectedRange,
                        selectedDate: _selectedMonth,
                        customRange: _customRange,
                        onChanged: ({
                          required DateRangeType rangeType,
                          required DateTime date,
                          DateTimeRange? customRange,
                        }) {
                          setState(() {
                            _selectedRange = rangeType;
                            _selectedMonth = date;
                            _customRange = customRange;
                            _calculateSummary();
                            _generateChartData();
                          });
                        },
                      ),
                    ),

                    // const SizedBox(height: 12),

                    // Chart
                    DashboardChart(
                      incomeChartData: _incomeChartData,
                      expenseChartData: _expenseChartData,
                      tooltipBehavior: TooltipBehavior(
                        enable: false,
                        shouldAlwaysShow: false,
                      ),
                      onCategoryTap: _onCategoryTap,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, String amount, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
