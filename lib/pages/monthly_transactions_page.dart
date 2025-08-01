import 'package:expense_track/services/supabase_services.dart';
import 'package:expense_track/widgets/daily_entry_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive/hive.dart';

import '../models/entry.dart';
import '../widgets/CustomAppBar.dart';
import '../widgets/CustomSideBar.dart';
import '../widgets/EntryDialog.dart';

/// Transactions page that shows a full‑month calendar.
///
/// * Each day‑cell displays **income**, **expense**, and **balance** mini‑totals.
/// * Tapping a date opens a bottom‑sheet with the list of transactions for that date.
class MonthlyTransactionsPage extends StatefulWidget {
  final String title;
  const MonthlyTransactionsPage({super.key, required this.title});

  @override
  State<MonthlyTransactionsPage> createState() =>
      _MonthlyTransactionsPageState();
}

class _MonthlyTransactionsPageState extends State<MonthlyTransactionsPage> {

  /// Maps a date (truncated to midnight) to its entries.
  late Map<DateTime, List<Entry>> _entriesByDate = {};

  /// Caches daily totals so the builder can be fast.
  late Map<DateTime, _DailyTotals> _dailyTotals = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntries();
    });
  }

  /// Loads entries from Hive and builds the grouped caches.
  Future<void> _loadEntries() async {
    final box = Hive.box<Entry>('entriesBox');
    final updatedEntries = box.values.toList();

    final grouped = _groupByDate(updatedEntries);
    final totals = _computeDailyTotals(grouped);

    if (mounted) {
      // Defer state update slightly after build is done
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _entriesByDate = grouped;
            _dailyTotals = totals;
          });
        }
      });
    }
  }

  //--------------------------------------------------
  // Grouping & totals helpers
  //--------------------------------------------------
  Map<DateTime, List<Entry>> _groupByDate(List<Entry> list) {
    final Map<DateTime, List<Entry>> map = {};
    for (final e in list) {
      final key = _dateKey(e.date);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  Map<DateTime, _DailyTotals> _computeDailyTotals(
    Map<DateTime, List<Entry>> grouped,
  ) {
    final Map<DateTime, _DailyTotals> map = {};
    grouped.forEach((day, entries) {
      double income = 0;
      double expense = 0;
      for (final e in entries) {
        if (e.type.toLowerCase() == 'income') {
          income += e.amount;
        } else {
          expense -= e.amount;
        }
      }
      map[day] = _DailyTotals(
        income: income,
        expense: expense,
        balance: income + expense,
      );
    });
    return map;
  }

  DateTime _dateKey(DateTime date) => DateTime(date.year, date.month, date.day);

  //--------------------------------------------------
  // Dialog helpers
  //--------------------------------------------------
  void _openAddDialog({DateTime? forDate}) {
    showDialog(
      context: context,
      builder:
          (ctx) => EntryDialog(
            initialDate: forDate,
            mode: EntryDialogMode.add,
            onSuccess: (action) {
              if (action == EntryDialogAction.edited) {
                setState(() {
                  _loadEntries();
                });
              }
            },
          ),
    );
  }

  void _openBottomSheetForDate(DateTime date) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final focusNode = FocusNode();
        return KeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent &&
                HardwareKeyboard.instance.isLogicalKeyPressed(
                  LogicalKeyboardKey.escape,
                )) {
              Navigator.of(ctx).maybePop();
            }
          },
          child: Padding(
            padding: MediaQuery.of(ctx).viewInsets,
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.6,
              width: MediaQuery.of(ctx).size.width * 0.5,
              child: Column(
                children: [
                  Expanded(
                    child: DailyEntryListPanel(
                      // allEntries: _entries,
                      initialDate: date,
                      onDelete: (entry) async {
                        SupabaseService.deleteEntry(entry);
                        Navigator.of(
                          ctx,
                        ).pop(); // Close and re-open bottom sheet
                        _openBottomSheetForDate(date); // <-- key part
                      },
                      onChanged: _loadEntries,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(_loadEntries);
  }

  //--------------------------------------------------
  // UI
  //--------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomSidebar(),
      body: Builder(
        builder:
            (scaffoldCtx) => Column(
              children: [
                CustomAppBar(
                  title: widget.title,
                  showBackButton: false,
                  leading: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(scaffoldCtx).openDrawer(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadEntries,
                    ),
                  ],
                ),
                Expanded(child: _buildCalendar()),
              ],
            ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddDialog(forDate: _selectedDay),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      //height: 800, // You can adjust this to fit better
      child: TableCalendar<Entry>(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        rowHeight: 80,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        eventLoader: (day) => _entriesByDate[_dateKey(day)] ?? [],
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
          _openBottomSheetForDate(selected);
        },
        calendarStyle: CalendarStyle(
          isTodayHighlighted: false,
          outsideDaysVisible: false,

          markersMaxCount: 0,
          cellAlignment: Alignment.center,
          cellMargin: EdgeInsets.zero, // Remove spacing between cells
          tablePadding: EdgeInsets.all(10),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder:
              (ctx, day, focused) =>
                  _DayCell(day: day, totals: _dailyTotals[_dateKey(day)]),
          todayBuilder:
              (ctx, day, focused) => _DayCell(
                day: day,
                totals: _dailyTotals[_dateKey(day)],
                highlight: true,
              ),
          selectedBuilder:
              (ctx, day, focused) => _DayCell(
                day: day,
                totals: _dailyTotals[_dateKey(day)],
                selected: true,
              ),
          outsideBuilder:
              (ctx, day, focusedDay) => Opacity(
                opacity: 0.3,
                child: _DayCell(day: day, totals: _dailyTotals[_dateKey(day)]),
              ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

//--------------------------------------------------
// Helper widgets & models
//--------------------------------------------------
class _DayCell extends StatelessWidget {
  final DateTime day;
  final _DailyTotals? totals;
  final bool highlight;
  final bool selected;

  const _DayCell({
    Key? key,
    required this.day,
    this.totals,
    this.highlight = false,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 90,
      decoration: BoxDecoration(
        //color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      //padding: const EdgeInsets.symmetric(vertical: 4),
      //margin: const EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '${day.day}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),

          if (totals != null) ...[
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _fmt(totals!.income),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _fmt(totals!.expense),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _fmt(totals!.balance),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(double v) => v == 0 ? '0' : v.toStringAsFixed(0);
}

class _DailyTotals {
  final double income;
  final double expense;
  final double balance;

  const _DailyTotals({
    required this.income,
    required this.expense,
    required this.balance,
  });
}
