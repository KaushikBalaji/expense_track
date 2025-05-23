import 'package:expense_track/widgets/dashboard_charts.dart';
import 'package:expense_track/widgets/date_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
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
  final bool _isSynced = true;

  late Box<Entry> _box;
  double _totalIncome = 0;
  double _totalExpenses = 0;
  List<ChartData> _incomeChartData = [];
  List<ChartData> _expenseChartData = [];

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                entries.isEmpty
                    ? const Center(child: Text("No entries found"))
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$category (${entries.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    normalizedType == 'income'
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: entries.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
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
                                          DateFormat.yMMMd().format(entry.date),
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
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          ),
    );
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
                        Icon(
                          _isSynced ? Icons.cloud_done : Icons.cloud_off,
                          color: _isSynced ? Colors.green : Colors.red,
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
