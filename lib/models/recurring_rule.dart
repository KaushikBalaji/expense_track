import 'package:hive/hive.dart';

part 'recurring_rule.g.dart';

@HiveType(typeId: 4)
enum RecurrenceType {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  yearly,
}

@HiveType(typeId: 5)
class RecurringRule extends HiveObject {
  @HiveField(0)
  RecurrenceType type;

  @HiveField(1)
  int interval; // e.g., every 2 days, 3 weeks

  @HiveField(2)
  List<int>? weekdays; // 0=Sun, 1=Mon... Only for weekly

  @HiveField(3)
  DateTime? endDate;

  RecurringRule({
    this.type = RecurrenceType.none,
    this.interval = 1,
    this.weekdays,
    this.endDate,
  });
}
