import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Хранилище расходов и поездок: держит данные в памяти, сохраняет их на
/// устройстве (shared_preferences) и сообщает экранам об изменениях.
class ExpenseRepository extends ChangeNotifier {
  static const _expensesKey = 'expenses_v1';
  static const _tripsKey = 'trips_v1';
  static const _categoriesKey = 'categories_v1';

  final List<Expense> _items = [];
  final List<Trip> _trips = [];
  final List<ExpenseCategory> _customCategories = [];

  /// Все расходы: сначала новые.
  List<Expense> get expenses => List.unmodifiable(_items);

  /// Все поездки: сначала новые.
  List<Trip> get trips => List.unmodifiable(_trips);

  /// Свои категории в порядке создания.
  List<ExpenseCategory> get customCategories =>
      List.unmodifiable(_customCategories);

  /// Стандартные категории, затем свои.
  List<ExpenseCategory> get allCategories =>
      [...kCategories, ..._customCategories];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawExpenses = prefs.getString(_expensesKey);
      if (rawExpenses != null) {
        final list = jsonDecode(rawExpenses) as List<dynamic>;
        _items
          ..clear()
          ..addAll(
            list.map((e) => Expense.fromJson(e as Map<String, dynamic>)),
          );
        _sortExpenses();
      }

      final rawTrips = prefs.getString(_tripsKey);
      if (rawTrips != null) {
        final list = jsonDecode(rawTrips) as List<dynamic>;
        _trips
          ..clear()
          ..addAll(list.map((e) => Trip.fromJson(e as Map<String, dynamic>)));
        _sortTrips();
      }

      final rawCategories = prefs.getString(_categoriesKey);
      if (rawCategories != null) {
        final list = jsonDecode(rawCategories) as List<dynamic>;
        _customCategories
          ..clear()
          ..addAll(
            list.map(
              (e) => ExpenseCategory.fromJson(e as Map<String, dynamic>),
            ),
          );
      }

      notifyListeners();
    } catch (error) {
      debugPrint('Не удалось загрузить данные: $error');
    }
  }

  // ---------------------------------------------------------------- расходы

  Future<void> add(Expense expense) async {
    _items.add(expense);
    _sortExpenses();
    notifyListeners();
    await _persistExpenses();
  }

  Expense? byId(String id) {
    for (final expense in _items) {
      if (expense.id == id) return expense;
    }
    return null;
  }

  /// Заменяет расход с тем же id и сохраняет изменения.
  Future<void> update(Expense expense) async {
    final index = _items.indexWhere((e) => e.id == expense.id);
    if (index == -1) return;
    _items[index] = expense;
    _sortExpenses();
    notifyListeners();
    await _persistExpenses();
  }

  /// Удаляет расход по id и сохраняет изменения.
  Future<void> remove(String id) async {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    if (_items.length == before) return;
    notifyListeners();
    await _persistExpenses();
  }

  List<Expense> forMonth(DateTime month) => _items
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .toList();

  /// Итог за месяц в копейках.
  int totalForMonth(DateTime month) =>
      forMonth(month).fold(0, (sum, e) => sum + e.amountKopecks);

  /// Итоги по категориям за месяц: сначала самые большие.
  List<MapEntry<String, int>> categoryTotalsForMonth(DateTime month) =>
      categoryTotals(forMonth(month));

  /// Итоги по категориям для произвольного списка расходов.
  List<MapEntry<String, int>> categoryTotals(Iterable<Expense> expenses) {
    final totals = <String, int>{};
    for (final expense in expenses) {
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

  // ---------------------------------------------------------------- поездки

  Trip? tripById(String id) {
    if (id.isEmpty) return null;
    for (final trip in _trips) {
      if (trip.id == id) return trip;
    }
    return null;
  }

  Future<void> addTrip(Trip trip) async {
    _trips.add(trip);
    _sortTrips();
    notifyListeners();
    await _persistTrips();
  }

  /// Удаляет поездку. Расходы остаются, но отвязываются от неё.
  Future<void> deleteTrip(String id) async {
    final before = _trips.length;
    _trips.removeWhere((t) => t.id == id);
    if (_trips.length == before) return;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].tripId == id) {
        _items[i] = _items[i].copyWith(tripId: '');
      }
    }
    notifyListeners();
    await _persistTrips();
    await _persistExpenses();
  }

  List<Expense> expensesForTrip(String tripId) =>
      _items.where((e) => e.tripId == tripId).toList();

  int totalForTrip(String tripId) =>
      expensesForTrip(tripId).fold(0, (sum, e) => sum + e.amountKopecks);

  /// Поездки, период которых пересекается с месяцем.
  List<Trip> tripsForMonth(DateTime month) {
    final first = DateTime(month.year, month.month);
    final nextFirst = DateTime(month.year, month.month + 1);
    return _trips
        .where((t) => t.start.isBefore(nextFirst) && !t.end.isBefore(first))
        .toList();
  }

  /// Расходы месяца, привязанные к существующим поездкам.
  List<Expense> tripExpensesForMonth(DateTime month) => forMonth(month)
      .where((e) => tripById(e.tripId) != null)
      .toList();

  int tripTotalForMonth(DateTime month) => tripExpensesForMonth(month)
      .fold(0, (sum, e) => sum + e.amountKopecks);

  // ------------------------------------------------------------ категории

  /// Категория по названию: стандартная, своя или запасная «Другое».
  ExpenseCategory categoryByName(String name) {
    for (final category in allCategories) {
      if (category.name == name) return category;
    }
    return const ExpenseCategory('Другое', Icons.category_outlined);
  }

  /// Занято ли название (без учёта регистра). [exceptId] - своя категория,
  /// которую сейчас редактируют.
  bool categoryNameTaken(String name, {String exceptId = ''}) {
    final wanted = name.trim().toLowerCase();
    for (final category in allCategories) {
      if (exceptId.isNotEmpty && category.id == exceptId) continue;
      if (category.name.toLowerCase() == wanted) return true;
    }
    return false;
  }

  int expenseCountForCategory(String name) =>
      _items.where((e) => e.categoryName == name).length;

  Future<void> addCategory(ExpenseCategory category) async {
    _customCategories.add(category);
    notifyListeners();
    await _persistCategories();
  }

  /// Обновляет свою категорию. Если сменилось название, переименовывает её
  /// и в расходах.
  Future<void> updateCategory(ExpenseCategory category) async {
    final index = _customCategories.indexWhere((c) => c.id == category.id);
    if (index == -1) return;
    final oldName = _customCategories[index].name;
    _customCategories[index] = category;

    final renamed = oldName != category.name;
    if (renamed) {
      for (var i = 0; i < _items.length; i++) {
        if (_items[i].categoryName == oldName) {
          _items[i] = _items[i].copyWith(categoryName: category.name);
        }
      }
    }
    notifyListeners();
    await _persistCategories();
    if (renamed) await _persistExpenses();
  }

  /// Удаляет свою категорию, только если в ней нет расходов.
  /// Возвращает false, если удалить нельзя.
  Future<bool> deleteCategory(String id) async {
    final index = _customCategories.indexWhere((c) => c.id == id);
    if (index == -1) return false;
    if (expenseCountForCategory(_customCategories[index].name) > 0) {
      return false;
    }
    _customCategories.removeAt(index);
    notifyListeners();
    await _persistCategories();
    return true;
  }

  // ------------------------------------------------------------- служебное

  void _sortExpenses() {
    _items.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
  }

  void _sortTrips() {
    _trips.sort((a, b) {
      final byStart = b.start.compareTo(a.start);
      return byStart != 0 ? byStart : b.id.compareTo(a.id);
    });
  }

  Future<void> _persistExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_expensesKey, json);
    } catch (error) {
      debugPrint('Не удалось сохранить расходы: $error');
    }
  }

  Future<void> _persistCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json =
          jsonEncode(_customCategories.map((c) => c.toJson()).toList());
      await prefs.setString(_categoriesKey, json);
    } catch (error) {
      debugPrint('Не удалось сохранить категории: $error');
    }
  }

  Future<void> _persistTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_trips.map((t) => t.toJson()).toList());
      await prefs.setString(_tripsKey, json);
    } catch (error) {
      debugPrint('Не удалось сохранить поездки: $error');
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
    final scope = context.dependOnInheritedWidgetOfExactType<ExpenseScope>();
    assert(scope != null, 'ExpenseScope не найден выше по дереву виджетов');
    return scope!.notifier!;
  }

  /// Для обработчиков нажатий: без подписки на изменения.
  static ExpenseRepository read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ExpenseScope>();
    assert(scope != null, 'ExpenseScope не найден выше по дереву виджетов');
    return scope!.notifier!;
  }
}
