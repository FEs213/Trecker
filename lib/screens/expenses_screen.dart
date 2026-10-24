import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_filter.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_text.dart';
import '../widgets/expense_tile.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_choice_chip.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';
import '../widgets/velvet_text_field.dart';
import 'expense_details_screen.dart';
import 'expense_filters_screen.dart';
import 'expense_form_screen.dart';

/// Вкладка «Расходы»: поиск и список расходов, сгруппированный по месяцам.
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ExpenseFilter _filter = ExpenseFilter.empty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final result = await Navigator.of(context).push<ExpenseFilter>(
      MaterialPageRoute<ExpenseFilter>(
        builder: (_) => ExpenseFiltersScreen(initial: _filter),
      ),
    );
    if (result != null) setState(() => _filter = result);
  }

  bool _matches(Expense expense) {
    if (!_filter.matches(expense)) return false;
    if (_query.isEmpty) return true;
    return expense.payee.toLowerCase().contains(_query) ||
        expense.comment.toLowerCase().contains(_query) ||
        expense.categoryName.toLowerCase().contains(_query);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ExpenseScope.of(context);
    final all = repo.expenses;
    final filtered = all.where(_matches).toList();

    // Сгруппировать по месяцам (список уже отсортирован: сначала новые).
    final groups = <int, List<Expense>>{};
    for (final expense in filtered) {
      final key = expense.date.year * 100 + expense.date.month;
      groups.putIfAbsent(key, () => []).add(expense);
    }

    return VelvetPage(
      title: 'Расходы',
      bottom: PrimaryButton(
        label: 'Новый расход',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ExpenseFormScreen()),
          );
        },
      ),
      children: [
        VelvetTextField(
          hint: 'Поиск',
          prefixIcon: Icons.search,
          controller: _searchController,
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
        ),
        const SizedBox(height: 4),
        const Text('По получателю или комментарию', style: AppText.caption),
        const SizedBox(height: 12),
        Row(
          children: [
            VelvetChoiceChip(
              label: _filter.isActive
                  ? 'Фильтры · ${_filter.activeCount}'
                  : 'Фильтры',
              selected: _filter.isActive,
              onTap: _openFilters,
            ),
            if (_filter.isActive)
              TextButton(
                onPressed: () => setState(() => _filter = ExpenseFilter.empty),
                child: const Text('Сбросить'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          VelvetCard(
            child: Text(
              all.isEmpty
                  ? 'Расходов пока нет. Нажмите «Новый расход», '
                      'чтобы добавить первый.'
                  : _filter.isActive
                      ? 'Ничего не найдено. Измените или сбросьте фильтры.'
                      : 'Ничего не найдено.',
              style: AppText.label,
            ),
          )
        else
          for (final group in groups.values) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatMonthYear(group.first.date), style: AppText.section),
                Text(
                  formatKopecks(
                    group.fold<int>(0, (sum, e) => sum + e.amountKopecks),
                  ),
                  style: AppText.label,
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < group.length; i++) ...[
              if (i > 0) const Divider(),
              ExpenseTile(
                expense: group[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ExpenseDetailsScreen(expense: group[i]),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
      ],
    );
  }
}
