import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

enum DateRangeType { monthly, yearly, custom }

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
              }
            },
            items: const [
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
        
        // 👇 Add arrows around the label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedRange != DateRangeType.custom)
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () {
                  final newDate = selectedRange == DateRangeType.monthly
                      ? DateTime(selectedDate.year, selectedDate.month - 1)
                      : DateTime(selectedDate.year - 1, selectedDate.month);
                  onChanged(
                    rangeType: selectedRange,
                    date: newDate,
                    customRange: customRange,
                  );
                },
              ),
              SizedBox(width: 10,),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 10,),
            if (selectedRange != DateRangeType.custom)
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () {
                  final newDate = selectedRange == DateRangeType.monthly
                      ? DateTime(selectedDate.year, selectedDate.month + 1)
                      : DateTime(selectedDate.year + 1, selectedDate.month);
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
