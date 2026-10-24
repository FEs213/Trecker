import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_text.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';
import 'expense_form_screen.dart';

/// Экран «Расход»: подробности, изменение и удаление.
class ExpenseDetailsScreen extends StatefulWidget {
  const ExpenseDetailsScreen({super.key, required this.expense});

  final Expense expense;

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  late Expense _expense = widget.expense;

  void _edit() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExpenseFormScreen(expense: _expense),
      ),
    );
  }

  Future<void> _delete() async {
    final repository = ExpenseScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDeleteConfirm(
      context,
      title: 'Удалить расход?',
      summary: '${_expense.title} · ${formatKopecks(_expense.amountKopecks)} '
          '${formatDate(_expense.date)}',
      message: 'Расход будет удалён из данных приложения. '
          'Восстановить его нельзя.',
    );
    if (!confirmed) return;

    await repository.remove(_expense.id);
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Расход удалён')));
  }

  @override
  Widget build(BuildContext context) {
    // Берём свежую версию из хранилища (после изменения). Если расход уже
    // удалён, остаёмся с последней известной, пока экран закрывается.
    final repository = ExpenseScope.of(context);
    _expense = repository.byId(widget.expense.id) ?? _expense;
    final expense = _expense;
    final category = repository.categoryByName(expense.categoryName);

    return VelvetPage(
      title: 'Расход',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(label: 'Изменить', onPressed: _edit),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Удалить расход',
            danger: true,
            onPressed: _delete,
          ),
        ],
      ),
      children: [
        Row(
          children: [
            Icon(category.icon, color: category.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                expense.title,
                style: AppText.section,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(formatKopecks(expense.amountKopecks), style: AppText.amountLarge),
        const SizedBox(height: 4),
        Text(formatFullDate(expense.date), style: AppText.caption),
        const SizedBox(height: 20),
        VelvetCard(
          child: Column(
            children: [
              _InfoRow(label: 'Категория', value: expense.categoryName),
              _InfoRow(label: 'Оплата', value: expense.method),
              _InfoRow(
                label: 'Получатель',
                value: expense.payee.isEmpty ? '—' : expense.payee,
              ),
              _InfoRow(
                label: 'Поездка',
                value: repository.tripById(expense.tripId)?.name ??
                    'Без командировки',
              ),
            ],
          ),
        ),
        if (expense.comment.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Комментарий', style: AppText.label),
          const SizedBox(height: 4),
          Text(expense.comment, style: AppText.body),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: AppText.label)),
          Expanded(child: Text(value, style: AppText.body)),
        ],
      ),
    );
  }
}
