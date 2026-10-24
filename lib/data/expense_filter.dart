import 'models.dart';

enum AmountMode { greater, less }

/// Особое значение [ExpenseFilter.tripId]: только расходы без командировки.
const kNoTripFilter = '__none__';

/// Набор условий отбора расходов. Все условия применяются вместе (И).
class ExpenseFilter {
  const ExpenseFilter({
    this.categories = const {},
    this.from,
    this.to,
    this.amountMode = AmountMode.greater,
    this.amountKopecks,
    this.methods = const {},
    this.tripId,
  });

  static const empty = ExpenseFilter();

  final Set<String> categories;
  final DateTime? from;
  final DateTime? to;
  final AmountMode amountMode;

  /// Порог суммы в копейках; null - условие по сумме не задано.
  final int? amountKopecks;
  final Set<String> methods;

  /// null - любая; [kNoTripFilter] - без командировки; иначе id поездки.
  final String? tripId;

  /// Сколько групп условий задано (категория, дата, сумма, оплата, поездка).
  int get activeCount =>
      (categories.isNotEmpty ? 1 : 0) +
      (from != null || to != null ? 1 : 0) +
      (amountKopecks != null ? 1 : 0) +
      (methods.isNotEmpty ? 1 : 0) +
      (tripId != null ? 1 : 0);

  bool get isActive => activeCount > 0;

  bool matches(Expense expense) {
    if (categories.isNotEmpty && !categories.contains(expense.categoryName)) {
      return false;
    }

    final day = DateTime(
      expense.date.year,
      expense.date.month,
      expense.date.day,
    );
    final start = from;
    if (start != null && day.isBefore(DateTime(start.year, start.month, start.day))) {
      return false;
    }
    final end = to;
    if (end != null && day.isAfter(DateTime(end.year, end.month, end.day))) {
      return false;
    }

    final threshold = amountKopecks;
    if (threshold != null) {
      final passes = amountMode == AmountMode.greater
          ? expense.amountKopecks > threshold
          : expense.amountKopecks < threshold;
      if (!passes) return false;
    }

    if (methods.isNotEmpty && !methods.contains(expense.method)) return false;

    final trip = tripId;
    if (trip != null) {
      final ok = trip == kNoTripFilter
          ? expense.tripId.isEmpty
          : expense.tripId == trip;
      if (!ok) return false;
    }

    return true;
  }
}
