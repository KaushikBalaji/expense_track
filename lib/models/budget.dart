import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 3) // make sure this typeId is unique in your app
class Budget extends HiveObject {
  @HiveField(0)
  String id; // UUID string

  @HiveField(1)
  String userId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime month;

  @HiveField(5)
  String? note;

  @HiveField(6)
  DateTime createdAt;

  Budget({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.month,
    this.note,
    required this.createdAt,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      amount: double.parse(map['amount'].toString()),
      category: map['category'] as String,
      month: DateTime.parse(map['month']),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'category': category,
      'month': month.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
