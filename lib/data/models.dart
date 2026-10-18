import 'package:flutter/material.dart';

class ExpenseCategory {
  const ExpenseCategory(this.name, this.icon);

  final String name;
  final IconData icon;
}

const kCategories = <ExpenseCategory>[
  ExpenseCategory('Продукты', Icons.shopping_basket_outlined),
  ExpenseCategory('Кафе', Icons.local_cafe_outlined),
  ExpenseCategory('Коммунальные платежи', Icons.home_outlined),
  ExpenseCategory('Транспорт', Icons.directions_bus_outlined),
  ExpenseCategory('Одежда', Icons.checkroom_outlined),
  ExpenseCategory('Здоровье', Icons.favorite_border),
  ExpenseCategory('Развлечение', Icons.confirmation_number_outlined),
  ExpenseCategory('Обучение', Icons.school_outlined),
];

const kPaymentMethods = <String>['Карта', 'Наличные', 'QR-код', 'Иной'];

const _fallbackCategory = ExpenseCategory('Другое', Icons.category_outlined);

ExpenseCategory categoryByName(String name) {
  for (final category in kCategories) {
    if (category.name == name) return category;
  }
  return _fallbackCategory;
}

/// Один расход. Сумма хранится в копейках, чтобы не копить ошибки округления.
class Expense {
  const Expense({
    required this.id,
    required this.amountKopecks,
    required this.categoryName,
    required this.date,
    required this.method,
    this.payee = '',
    this.comment = '',
    this.trip = '',
  });

  final String id;
  final int amountKopecks;
  final String categoryName;
  final DateTime date;
  final String method;
  final String payee;
  final String comment;
  final String trip;

  /// Получатель, а если он не указан - название категории.
  String get title => payee.isEmpty ? categoryName : payee;

  ExpenseCategory get category => categoryByName(categoryName);

  Map<String, dynamic> toJson() => {
        'id': id,
        'amountKopecks': amountKopecks,
        'category': categoryName,
        'date': date.toIso8601String(),
        'method': method,
        'payee': payee,
        'comment': comment,
        'trip': trip,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        amountKopecks: json['amountKopecks'] as int,
        categoryName: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        method: json['method'] as String,
        payee: (json['payee'] as String?) ?? '',
        comment: (json['comment'] as String?) ?? '',
        trip: (json['trip'] as String?) ?? '',
      );
}
