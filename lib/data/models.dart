import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Категория расходов: стандартная (без [id]) или своя (с [id]).
class ExpenseCategory {
  const ExpenseCategory(
    this.name,
    this.icon, {
    this.id = '',
    this.iconKey = '',
    this.color = AppColors.highlight,
  });

  final String name;
  final IconData icon;

  /// Пусто у стандартных категорий.
  final String id;

  /// Ключ значка из [kIconOptions] (только у своих категорий).
  final String iconKey;
  final Color color;

  bool get isCustom => id.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': iconKey,
        'color': color.toARGB32(),
      };

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    final key = (json['icon'] as String?) ?? '';
    return ExpenseCategory(
      json['name'] as String,
      kIconOptions[key] ?? Icons.category_outlined,
      id: json['id'] as String,
      iconKey: key,
      color: Color((json['color'] as int?) ?? AppColors.highlight.toARGB32()),
    );
  }
}

/// Значки, из которых можно выбрать для своей категории.
const kIconOptions = <String, IconData>{
  'paw': Icons.pets_outlined,
  'gift': Icons.card_giftcard,
  'home': Icons.home_outlined,
  'flight': Icons.flight_outlined,
  'heart': Icons.favorite_border,
  'book': Icons.menu_book_outlined,
  'game': Icons.sports_esports_outlined,
  'fitness': Icons.fitness_center,
  'kids': Icons.child_care,
  'tools': Icons.build_outlined,
  'savings': Icons.savings_outlined,
  'car': Icons.directions_car_outlined,
};

/// Цвета для своих категорий (из палитры Red Velvet).
const kColorOptions = <Color>[
  Color(0xFFFF80AD),
  Color(0xFFE8639B),
  Color(0xFFC25A86),
  Color(0xFFA48BC9),
  Color(0xFFDDA58C),
  Color(0xFFB9B1E3),
];

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
    this.tripId = '',
  });

  final String id;
  final int amountKopecks;
  final String categoryName;
  final DateTime date;
  final String method;
  final String payee;
  final String comment;
  /// Id поездки (пусто - расход без командировки).
  final String tripId;

  /// Получатель, а если он не указан - название категории.
  String get title => payee.isEmpty ? categoryName : payee;

  Expense copyWith({String? tripId, String? categoryName}) => Expense(
        id: id,
        amountKopecks: amountKopecks,
        categoryName: categoryName ?? this.categoryName,
        date: date,
        method: method,
        payee: payee,
        comment: comment,
        tripId: tripId ?? this.tripId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amountKopecks': amountKopecks,
        'category': categoryName,
        'date': date.toIso8601String(),
        'method': method,
        'payee': payee,
        'comment': comment,
        'tripId': tripId,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        amountKopecks: json['amountKopecks'] as int,
        categoryName: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        method: json['method'] as String,
        payee: (json['payee'] as String?) ?? '',
        comment: (json['comment'] as String?) ?? '',
        tripId: (json['tripId'] as String?) ?? '',
      );
}

/// Командировка / поездка: название и период. Расходы привязываются по [id].
class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
  });

  final String id;
  final String name;
  final DateTime start;
  final DateTime end;

  /// Число дней включительно (считаем в UTC, чтобы не мешал переход на летнее время).
  int get days {
    final a = DateTime.utc(start.year, start.month, start.day);
    final b = DateTime.utc(end.year, end.month, end.day);
    return b.difference(a).inDays + 1;
  }

  /// Состояние относительно [today]: предстоящая, идёт сейчас, завершена.
  String statusOn(DateTime today) {
    final d = DateTime(today.year, today.month, today.day);
    if (start.isAfter(d)) return 'предстоящая поездка';
    if (end.isBefore(d)) return 'завершена';
    return 'идёт сейчас';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        name: json['name'] as String,
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
      );
}
