import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'entry.g.dart';

@HiveType(typeId: 2)
class Entry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String tag;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String type;

  Entry({
    String? id,
    required this.title,
    required this.amount,
    required this.tag,
    required this.date,
    required this.type,
  }) : id = id ?? const Uuid().v4() {
    print('Entry created: $title, $amount, $tag, $date, $type, id: $id');
  }

  /// For uploading to Supabase
  Map<String, dynamic> toMap(String userId) => {
    'id': id,
    'title': title,
    'amount': amount,
    'tag': tag,
    'date': date.toIso8601String(),
    'type': type,
    'user_id': userId,
  };

  /// For downloading from Supabase
  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'].toString(),
      title: map['note'], // or map['title'], if that's the actual column name
      amount: (map['amount'] as num).toDouble(),
      tag: map['tag'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }
}
