import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/demo_data.dart';
import '../theme/app_text.dart';
import 'icon_badge.dart';

/// Строка списка расходов: иконка категории, получатель, дата · способ, сумма.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, this.onTap});

  final DemoExpense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            IconBadge(icon: expense.category.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title, style: AppText.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${formatDayMonth(expense.date)} · ${expense.method}',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            Text(formatRub(expense.amount), style: AppText.bodyMedium),
          ],
        ),
      ),
    );
  }
}
