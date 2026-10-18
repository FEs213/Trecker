import 'package:flutter/material.dart';

/// Демо-данные из макета. Позже будут заменены настоящим хранилищем.
class ExpenseCategory {
  const ExpenseCategory(this.name, this.icon, this.demoTotal);

  final String name;
  final IconData icon;
  final int demoTotal;
}

class DemoExpense {
  const DemoExpense({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.method,
  });

  final String title;
  final ExpenseCategory category;
  final int amount;
  final DateTime date;
  final String method;
}

const demoCategories = <ExpenseCategory>[
  ExpenseCategory('Продукты', Icons.shopping_basket_outlined, 12460),
  ExpenseCategory('Кафе', Icons.local_cafe_outlined, 4800),
  ExpenseCategory('Коммунальные платежи', Icons.home_outlined, 8200),
  ExpenseCategory('Транспорт', Icons.directions_bus_outlined, 5400),
  ExpenseCategory('Одежда', Icons.checkroom_outlined, 4500),
  ExpenseCategory('Здоровье', Icons.favorite_border, 2100),
  ExpenseCategory('Развлечение', Icons.confirmation_number_outlined, 900),
  ExpenseCategory('Обучение', Icons.school_outlined, 4500),
];

final demoExpenses = <DemoExpense>[
  DemoExpense(
    title: 'ВкусВилл',
    category: demoCategories[0],
    amount: 2460,
    date: DateTime(2026, 10, 16),
    method: 'Карта',
  ),
  DemoExpense(
    title: 'Яндекс Go',
    category: demoCategories[3],
    amount: 1400,
    date: DateTime(2026, 10, 15),
    method: 'Карта',
  ),
  DemoExpense(
    title: 'Дом чая',
    category: demoCategories[1],
    amount: 2200,
    date: DateTime(2026, 10, 13),
    method: 'Наличные',
  ),
  DemoExpense(
    title: 'РЖД',
    category: demoCategories[3],
    amount: 4000,
    date: DateTime(2026, 10, 12),
    method: 'Карта',
  ),
];

int get demoMonthTotal =>
    demoCategories.fold(0, (sum, category) => sum + category.demoTotal);
