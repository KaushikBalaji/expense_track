import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting months
import '../widgets/CustomAppbar.dart';
import '../widgets/CustomSidebar.dart';
import 'package:hive/hive.dart';
import '../models/entry.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Month selection
  DateTime _selectedMonth = DateTime.now();

  // Example sync status
  bool _isSynced = true;

  //Hive connection
  late Box<Entry> _box;
  double _totalIncome = 0;
  double _totalExpenses = 0;

  // Dummy summary values (replace with actual logic)
  double totalExpenses = 1234.56;
  double totalIncome = 5000.00;

  String get formattedMonth => DateFormat.yMMMM().format(_selectedMonth);
  double get balance => totalIncome - totalExpenses;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Entry>('entriesbox');
    _calculateSummary();
  }

  void _calculateSummary() {
    final entries =
        _box.values.where((entry) {
          final isSameMonth =
              entry.date.month == _selectedMonth.month &&
              entry.date.year == _selectedMonth.year;
          return isSameMonth;
        }).toList();

    double income = 0;
    double expenses = 0;

    for (var e in entries) {
      if (e.type == 'income') {
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

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _calculateSummary();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _calculateSummary();
    });
  }

  String get curMonthLabel => DateFormat.yMMMM().format(_selectedMonth);
  double get getBalance => _totalIncome - _totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomSidebar(),
      body: Builder(
        builder: (scaffoldContext) {
          return SafeArea(
            child: Column(
              children: [
                // App Bar with Sync Status
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
                    Row(
                      children: [
                        Icon(
                          _isSynced ? Icons.cloud_done : Icons.cloud_off,
                          color: _isSynced ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),

                // Month Selector Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: const Icon(Icons.arrow_left),
                      ),
                      SizedBox(width: 10),
                      Text(
                        curMonthLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),

                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.arrow_right),
                      ),
                    ],
                  ),
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

                // // Placeholder for future Pie/Bar Charts
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Align(
                //     alignment: Alignment.centerLeft,
                //     child: Text(
                //       'Spending Insights (Coming Soon)',
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Card builder
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
