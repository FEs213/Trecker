import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Хранилище расходов: держит список в памяти, сохраняет его на устройстве
/// (shared_preferences) и сообщает экранам об изменениях.
class ExpenseRepository extends ChangeNotifier {
  static const _storageKey = 'expenses_v1';

  final List<Expense> _items = [];

  /// Все расходы: сначала новые.
  List<Expense> get expenses => List.unmodifiable(_items);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _items
        ..clear()
        ..addAll(
          list.map((e) => Expense.fromJson(e as Map<String, dynamic>)),
        );
      _sort();
      notifyListeners();
    } catch (error) {
      debugPrint('Не удалось загрузить расходы: $error');
    }
  }

  Future<void> add(Expense expense) async {
    _items.add(expense);
    _sort();
    notifyListeners();
    await _persist();
  }

  List<Expense> forMonth(DateTime month) => _items
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();

  /// Итог за месяц в копейках.
  int totalForMonth(DateTime month) =>
      forMonth(month).fold(0, (sum, e) => sum + e.amountKopecks);

  /// Итоги по категориям за месяц: сначала самые большие.
  List<MapEntry<String, int>> categoryTotalsForMonth(DateTime month) {
    final totals = <String, int>{};
    for (final expense in forMonth(month)) {
      totals.update(
        expense.categoryName,
        (value) => value + expense.amountKopecks,
        ifAbsent: () => expense.amountKopecks,
      );
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  void _sort() {
    _items.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, json);
    } catch (error) {
      debugPrint('Не удалось сохранить расходы: $error');
    }
  }
}

/// Даёт экранам доступ к [ExpenseRepository] и перестраивает их при изменениях.
class ExpenseScope extends InheritedNotifier<ExpenseRepository> {
  const ExpenseScope({
    super.key,
    required ExpenseRepository repository,
    required super.child,
  }) : super(notifier: repository);

  /// Для build(): подписывает виджет на изменения.
  static ExpenseRepository of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ExpenseScope>();
    assert(scope != null, 'ExpenseScope не найден выше по дереву виджетов');
    return scope!.notifier!;
  }

  /// Для обработчиков нажатий: без подписки на изменения.
  static ExpenseRepository read(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<ExpenseScope>();
    assert(scope != null, 'ExpenseScope не найден выше по дереву виджетов');
    return scope!.notifier!;
  }
}
