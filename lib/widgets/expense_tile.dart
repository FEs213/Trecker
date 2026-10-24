import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_text.dart';
import 'icon_badge.dart';

/// Строка списка расходов: иконка категории, получатель, дата · способ, сумма.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, this.onTap});

  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category =
        ExpenseScope.of(context).categoryByName(expense.categoryName);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            IconBadge(icon: category.icon, color: category.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: AppText.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatDayMonth(expense.date)} · ${expense.method}',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(formatKopecks(expense.amountKopecks), style: AppText.bodyMedium),
          ],
        ),
      ),
    );
  }
}
