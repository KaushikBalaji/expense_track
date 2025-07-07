import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'recurring_entry.g.dart';

@HiveType(typeId: 5)
class RecurringEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String tag;

  @HiveField(4)
  String type; // 'Income' or 'Expense'

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  String frequency; // 'daily', 'weekly', 'monthly', 'yearly'

  @HiveField(7)
  int interval; // every n days/weeks/months

  @HiveField(8)
  DateTime? endDate;

  @HiveField(9)
  String? note;

  @HiveField(10)
  DateTime lastModified;

  @HiveField(11)
  DateTime? lastGenerated;

  @HiveField(12)
  List<int>? weekdays; // 0 = Sunday, 6 = Saturday (for weekly rules)

  RecurringEntry({
    String? id,
    required this.title,
    required this.amount,
    required this.tag,
    required this.type,
    required this.startDate,
    required this.frequency,
    required this.interval,
    this.endDate,
    this.note,
    DateTime? lastModified,
    this.lastGenerated,
    this.weekdays,
  })  : id = id ?? const Uuid().v4(),
        lastModified = lastModified ?? DateTime.now() {
    debugPrint(
      'RecurringEntry created: $title - $frequency every $interval unit(s), starts $startDate',
    );
  }

  Map<String, dynamic> toMap(String userId) => {
    'id': id,
    'user_id': userId,
    'title': title,
    'amount': amount,
    'tag': tag,
    'type': type,
    'start_date': startDate.toIso8601String(),
    'frequency': frequency,
    'interval': interval,
    'end_date': endDate?.toIso8601String(),
    'note': note,
    'last_modified': lastModified.toIso8601String(),
    'weekdays': weekdays,
  };

  factory RecurringEntry.fromMap(Map<String, dynamic> map) => RecurringEntry(
    id: map['id'],
    title: map['title'],
    amount: (map['amount'] as num).toDouble(),
    tag: map['tag'],
    type: map['type'],
    startDate: DateTime.parse(map['start_date']),
    frequency: map['frequency'],
    interval: map['interval'],
    endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
    note: map['note'],
    lastModified: map['last_modified'] != null
        ? DateTime.parse(map['last_modified'])
        : DateTime.now(),
    weekdays: (map['weekdays'] as List?)?.map((e) => e as int).toList(),
  );
}
