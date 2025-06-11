import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

enum DateRangeType { daily, weekly, monthly, yearly, custom }

class DateSelector extends StatelessWidget {
  final DateRangeType selectedRange;
  final DateTime selectedDate;
  final DateTimeRange? customRange;
  final void Function({
    required DateRangeType rangeType,
    required DateTime date,
    DateTimeRange? customRange,
  }) onChanged;

  const DateSelector({
    super.key,
    required this.selectedRange,
    required this.selectedDate,
    required this.onChanged,
    this.customRange,
  });

  String get label {
    switch (selectedRange) {
      case DateRangeType.daily:
        return DateFormat.yMMMd().format(selectedDate);
      case DateRangeType.weekly:
        final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final startStr = DateFormat.MMMd().format(startOfWeek);
        final endStr = DateFormat.MMMd().format(endOfWeek);
        return "$startStr - $endStr";
      case DateRangeType.monthly:
        return DateFormat.yMMMM().format(selectedDate);
      case DateRangeType.yearly:
        return DateFormat.y().format(selectedDate);
      case DateRangeType.custom:
        if (customRange == null) return "Custom Range";
        final start = DateFormat.yMMMd().format(customRange!.start);
        final end = DateFormat.yMMMd().format(customRange!.end);
        return "$start - $end";
    }
  }

  DateTime _getNavigatedDate(bool isNext) {
    switch (selectedRange) {
      case DateRangeType.daily:
        return selectedDate.add(Duration(days: isNext ? 1 : -1));
      case DateRangeType.weekly:
        return selectedDate.add(Duration(days: isNext ? 7 : -7));
      case DateRangeType.monthly:
        return DateTime(selectedDate.year, selectedDate.month + (isNext ? 1 : -1));
      case DateRangeType.yearly:
        return DateTime(selectedDate.year + (isNext ? 1 : -1), selectedDate.month);
      case DateRangeType.custom:
        return selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton2<DateRangeType>(
              value: selectedRange,
              onChanged: (newRange) async {
                if (newRange == null) return;

                switch (newRange) {
                  case DateRangeType.monthly:
                  case DateRangeType.yearly:
                    final picked = await showMonthYearPicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      onChanged(rangeType: newRange, date: picked);
                    }
                    break;

                  case DateRangeType.custom:
                    final pickedRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (pickedRange != null) {
                      onChanged(
                        rangeType: newRange,
                        date: pickedRange.start,
                        customRange: pickedRange,
                      );
                    }
                    break;

                  case DateRangeType.daily:
                  case DateRangeType.weekly:
                    final today = DateTime.now();
                    onChanged(rangeType: newRange, date: today);
                    break;
                }
              },
              items: const [
                DropdownMenuItem(
                  value: DateRangeType.daily,
                  child: Text("Daily"),
                ),
                DropdownMenuItem(
                  value: DateRangeType.weekly,
                  child: Text("Weekly"),
                ),
                DropdownMenuItem(
                  value: DateRangeType.monthly,
                  child: Text("Monthly"),
                ),
                DropdownMenuItem(
                  value: DateRangeType.yearly,
                  child: Text("Yearly"),
                ),
                DropdownMenuItem(
                  value: DateRangeType.custom,
                  child: Text("Custom Range"),
                ),
              ],
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedRange != DateRangeType.custom)
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () {
                    final newDate = _getNavigatedDate(false);
                    onChanged(
                      rangeType: selectedRange,
                      date: newDate,
                      customRange: customRange,
                    );
                  },
                ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              if (selectedRange != DateRangeType.custom)
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {
                    final newDate = _getNavigatedDate(true);
                    onChanged(
                      rangeType: selectedRange,
                      date: newDate,
                      customRange: customRange,
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
