import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 2)
class Entry {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String tag;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String type;

  Entry({
    required this.title,
    required this.amount,
    required this.tag,
    required this.date,
    required this.type,
  })
  {
    print('Entry created: $title, $amount, $tag, $date, $type');
  }
}
