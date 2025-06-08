import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_item.g.dart';

@HiveType(typeId: 4)
class CategoryItem extends HiveObject {

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // 'Income' or 'Expense'

  @HiveField(3)
  int iconCodePoint;

  @HiveField(4)
  String? fontFamily;

  @HiveField(5)
  String? fontPackage;

  @HiveField(6)
  bool? isActive;

  CategoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCodePoint,
    this.fontFamily,
    this.fontPackage,
    this.isActive = false,
    
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: fontFamily, fontPackage: fontPackage);
  // bool isCategoryActive(CategoryItem item) => item.isActive ?? true;

}
