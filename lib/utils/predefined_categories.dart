import 'package:expense_track/models/category_item.dart';
import 'package:flutter/material.dart';

final List<CategoryItem> predefinedCategories = [
  // Income Categories
  CategoryItem(
    id: 'salary',
    name: 'Salary',
    type: 'Income',
    iconCodePoint: Icons.attach_money.codePoint,
    fontFamily: Icons.attach_money.fontFamily,
    fontPackage: Icons.attach_money.fontPackage,
  ),
  CategoryItem(
    id: 'gift',
    name: 'Gift',
    type: 'Income',
    iconCodePoint: Icons.card_giftcard.codePoint,
    fontFamily: Icons.card_giftcard.fontFamily,
    fontPackage: Icons.card_giftcard.fontPackage,
  ),
  CategoryItem(
    id: 'award',
    name: 'Award',
    type: 'Income',
    iconCodePoint: Icons.emoji_events.codePoint,
    fontFamily: Icons.emoji_events.fontFamily,
    fontPackage: Icons.emoji_events.fontPackage,
  ),
  CategoryItem(
    id: 'investment',
    name: 'Investment',
    type: 'Income',
    iconCodePoint: Icons.trending_up.codePoint,
    fontFamily: Icons.trending_up.fontFamily,
    fontPackage: Icons.trending_up.fontPackage,
  ),
  CategoryItem(
    id: 'freelance',
    name: 'Freelance',
    type: 'Income',
    iconCodePoint: Icons.work.codePoint,
    fontFamily: Icons.work.fontFamily,
    fontPackage: Icons.work.fontPackage,
  ),
  CategoryItem(
    id: 'rental',
    name: 'Rental Income',
    type: 'Income',
    iconCodePoint: Icons.home_work.codePoint,
    fontFamily: Icons.home_work.fontFamily,
    fontPackage: Icons.home_work.fontPackage,
  ),
  CategoryItem(
    id: 'business',
    name: 'Business',
    type: 'Income',
    iconCodePoint: Icons.business_center.codePoint,
    fontFamily: Icons.business_center.fontFamily,
    fontPackage: Icons.business_center.fontPackage,
  ),
  CategoryItem(
    id: 'refund',
    name: 'Refund',
    type: 'Income',
    iconCodePoint: Icons.replay.codePoint,
    fontFamily: Icons.replay.fontFamily,
    fontPackage: Icons.replay.fontPackage,
  ),
  CategoryItem(
    id: 'lottery',
    name: 'Lottery',
    type: 'Income',
    iconCodePoint: Icons.casino.codePoint,
    fontFamily: Icons.casino.fontFamily,
    fontPackage: Icons.casino.fontPackage,
  ),
  CategoryItem(
    id: 'interest',
    name: 'Interest Income',
    type: 'Income',
    iconCodePoint: Icons.percent.codePoint,
    fontFamily: Icons.percent.fontFamily,
    fontPackage: Icons.percent.fontPackage,
  ),
  CategoryItem(
    id: 'dividends',
    name: 'Dividends',
    type: 'Income',
    iconCodePoint: Icons.bar_chart.codePoint,
    fontFamily: Icons.bar_chart.fontFamily,
    fontPackage: Icons.bar_chart.fontPackage,
  ),
  CategoryItem(
    id: 'royalty',
    name: 'Royalties',
    type: 'Income',
    iconCodePoint: Icons.music_note.codePoint,
    fontFamily: Icons.music_note.fontFamily,
    fontPackage: Icons.music_note.fontPackage,
  ),
  CategoryItem(
    id: 'grants',
    name: 'Grants / Fellowship',
    type: 'Income',
    iconCodePoint: Icons.volunteer_activism.codePoint,
    fontFamily: Icons.volunteer_activism.fontFamily,
    fontPackage: Icons.volunteer_activism.fontPackage,
  ),
  CategoryItem(
    id: 'bonus',
    name: 'Bonus',
    type: 'Income',
    iconCodePoint: Icons.card_membership.codePoint,
    fontFamily: Icons.card_membership.fontFamily,
    fontPackage: Icons.card_membership.fontPackage,
  ),
  CategoryItem(
    id: 'cashback',
    name: 'Cashback / Rewards',
    type: 'Income',
    iconCodePoint: Icons.redeem.codePoint,
    fontFamily: Icons.redeem.fontFamily,
    fontPackage: Icons.redeem.fontPackage,
  ),
  CategoryItem(
    id: 'resale',
    name: 'Resale Income',
    type: 'Income',
    iconCodePoint: Icons.swap_horizontal_circle.codePoint,
    fontFamily: Icons.swap_horizontal_circle.fontFamily,
    fontPackage: Icons.swap_horizontal_circle.fontPackage,
  ),

  // Expense Categories
  CategoryItem(
    id: 'food',
    name: 'Food',
    type: 'Expense',
    iconCodePoint: Icons.fastfood.codePoint,
    fontFamily: Icons.fastfood.fontFamily,
    fontPackage: Icons.fastfood.fontPackage,
  ),
  CategoryItem(
    id: 'house',
    name: 'House',
    type: 'Expense',
    iconCodePoint: Icons.house.codePoint,
    fontFamily: Icons.house.fontFamily,
    fontPackage: Icons.house.fontPackage,
  ),
  CategoryItem(
    id: 'clothing',
    name: 'Clothing',
    type: 'Expense',
    iconCodePoint: Icons.checkroom.codePoint,
    fontFamily: Icons.checkroom.fontFamily,
    fontPackage: Icons.checkroom.fontPackage,
  ),
  CategoryItem(
    id: 'transport',
    name: 'Transport',
    type: 'Expense',
    iconCodePoint: Icons.directions_car.codePoint,
    fontFamily: Icons.directions_car.fontFamily,
    fontPackage: Icons.directions_car.fontPackage,
  ),
  CategoryItem(
    id: 'shopping',
    name: 'Shopping',
    type: 'Expense',
    iconCodePoint: Icons.shopping_bag.codePoint,
    fontFamily: Icons.shopping_bag.fontFamily,
    fontPackage: Icons.shopping_bag.fontPackage,
  ),
  CategoryItem(
    id: 'medical',
    name: 'Medical',
    type: 'Expense',
    iconCodePoint: Icons.medical_services.codePoint,
    fontFamily: Icons.medical_services.fontFamily,
    fontPackage: Icons.medical_services.fontPackage,
  ),
  CategoryItem(
    id: 'present',
    name: 'Gift',
    type: 'Expense',
    iconCodePoint: Icons.card_giftcard.codePoint,
    fontFamily: Icons.card_giftcard.fontFamily,
    fontPackage: Icons.card_giftcard.fontPackage,
  ),
  CategoryItem(
    id: 'entertainment',
    name: 'Entertainment',
    type: 'Expense',
    iconCodePoint: Icons.movie.codePoint,
    fontFamily: Icons.movie.fontFamily,
    fontPackage: Icons.movie.fontPackage,
  ),
  CategoryItem(
    id: 'bills',
    name: 'Bills',
    type: 'Expense',
    iconCodePoint: Icons.receipt.codePoint,
    fontFamily: Icons.receipt.fontFamily,
    fontPackage: Icons.receipt.fontPackage,
  ),
  CategoryItem(
    id: 'education',
    name: 'Education',
    type: 'Expense',
    iconCodePoint: Icons.school.codePoint,
    fontFamily: Icons.school.fontFamily,
    fontPackage: Icons.school.fontPackage,
  ),
  CategoryItem(
    id: 'travel',
    name: 'Travel',
    type: 'Expense',
    iconCodePoint: Icons.flight_takeoff.codePoint,
    fontFamily: Icons.flight_takeoff.fontFamily,
    fontPackage: Icons.flight_takeoff.fontPackage,
  ),
  CategoryItem(
    id: 'subscription',
    name: 'Subscription',
    type: 'Expense',
    iconCodePoint: Icons.subscriptions.codePoint,
    fontFamily: Icons.subscriptions.fontFamily,
    fontPackage: Icons.subscriptions.fontPackage,
  ),
  CategoryItem(
    id: 'groceries',
    name: 'Groceries',
    type: 'Expense',
    iconCodePoint: Icons.local_grocery_store.codePoint,
    fontFamily: Icons.local_grocery_store.fontFamily,
    fontPackage: Icons.local_grocery_store.fontPackage,
  ),
  CategoryItem(
    id: 'insurance',
    name: 'Insurance',
    type: 'Expense',
    iconCodePoint: Icons.security.codePoint,
    fontFamily: Icons.security.fontFamily,
    fontPackage: Icons.security.fontPackage,
  ),
  CategoryItem(
    id: 'pets',
    name: 'Pets',
    type: 'Expense',
    iconCodePoint: Icons.pets.codePoint,
    fontFamily: Icons.pets.fontFamily,
    fontPackage: Icons.pets.fontPackage,
  ),
  CategoryItem(
    id: 'loan',
    name: 'Loan Repayment',
    type: 'Expense',
    iconCodePoint: Icons.money_off.codePoint,
    fontFamily: Icons.money_off.fontFamily,
    fontPackage: Icons.money_off.fontPackage,
  ),
  CategoryItem(
    id: 'emergency',
    name: 'Emergency',
    type: 'Expense',
    iconCodePoint: Icons.warning.codePoint,
    fontFamily: Icons.warning.fontFamily,
    fontPackage: Icons.warning.fontPackage,
  ),
  CategoryItem(
    id: 'kids',
    name: 'Kids',
    type: 'Expense',
    iconCodePoint: Icons.child_friendly.codePoint,
    fontFamily: Icons.child_friendly.fontFamily,
    fontPackage: Icons.child_friendly.fontPackage,
  ),
  CategoryItem(
    id: 'donation',
    name: 'Donations',
    type: 'Expense',
    iconCodePoint: Icons.favorite.codePoint,
    fontFamily: Icons.favorite.fontFamily,
    fontPackage: Icons.favorite.fontPackage,
  ),
  CategoryItem(
    id: 'alcohol',
    name: 'Alcohol & Tobacco',
    type: 'Expense',
    iconCodePoint: Icons.local_bar.codePoint,
    fontFamily: Icons.local_bar.fontFamily,
    fontPackage: Icons.local_bar.fontPackage,
  ),
  CategoryItem(
    id: 'personal_care',
    name: 'Personal Care',
    type: 'Expense',
    iconCodePoint: Icons.spa.codePoint,
    fontFamily: Icons.spa.fontFamily,
    fontPackage: Icons.spa.fontPackage,
  ),
  CategoryItem(
    id: 'furniture',
    name: 'Furniture / Appliances',
    type: 'Expense',
    iconCodePoint: Icons.chair.codePoint,
    fontFamily: Icons.chair.fontFamily,
    fontPackage: Icons.chair.fontPackage,
  ),
  CategoryItem(
    id: 'software',
    name: 'Apps / Software',
    type: 'Expense',
    iconCodePoint: Icons.apps.codePoint,
    fontFamily: Icons.apps.fontFamily,
    fontPackage: Icons.apps.fontPackage,
  ),
  CategoryItem(
    id: 'repair',
    name: 'Repairs & Maintenance',
    type: 'Expense',
    iconCodePoint: Icons.build.codePoint,
    fontFamily: Icons.build.fontFamily,
    fontPackage: Icons.build.fontPackage,
  ),
  CategoryItem(
    id: 'legal',
    name: 'Legal / Documentation',
    type: 'Expense',
    iconCodePoint: Icons.gavel.codePoint,
    fontFamily: Icons.gavel.fontFamily,
    fontPackage: Icons.gavel.fontPackage,
  ),
  CategoryItem(
    id: 'parking',
    name: 'Parking / Tolls',
    type: 'Expense',
    iconCodePoint: Icons.local_parking.codePoint,
    fontFamily: Icons.local_parking.fontFamily,
    fontPackage: Icons.local_parking.fontPackage,
  ),
  CategoryItem(
    id: 'festivals',
    name: 'Festivals / Celebrations',
    type: 'Expense',
    iconCodePoint: Icons.celebration.codePoint,
    fontFamily: Icons.celebration.fontFamily,
    fontPackage: Icons.celebration.fontPackage,
  ),
  CategoryItem(
    id: 'debt',
    name: 'Debt Payment',
    type: 'Expense',
    iconCodePoint: Icons.credit_card_off.codePoint,
    fontFamily: Icons.credit_card_off.fontFamily,
    fontPackage: Icons.credit_card_off.fontPackage,
  ),
  CategoryItem(
    id: 'subscriptions_business',
    name: 'Business Subscriptions',
    type: 'Expense',
    iconCodePoint: Icons.business.codePoint,
    fontFamily: Icons.business.fontFamily,
    fontPackage: Icons.business.fontPackage,
  ),
  CategoryItem(
    id: 'misc',
    name: 'Miscellaneous',
    type: 'Expense',
    iconCodePoint: Icons.blur_circular.codePoint,
    fontFamily: Icons.blur_circular.fontFamily,
    fontPackage: Icons.blur_circular.fontPackage,
  ),
];
