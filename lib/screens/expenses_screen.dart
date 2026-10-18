import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/demo_data.dart';
import '../theme/app_text.dart';
import '../widgets/expense_tile.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_page.dart';
import '../widgets/velvet_text_field.dart';
import 'new_expense_screen.dart';

/// Вкладка «Расходы»: поиск и список расходов за месяц.
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = demoExpenses.fold<int>(0, (sum, e) => sum + e.amount);

    return VelvetPage(
      title: 'Расходы',
      bottom: PrimaryButton(
        label: 'Новый расход',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const NewExpenseScreen()),
          );
        },
      ),
      children: [
        const VelvetTextField(
          hint: 'Поиск',
          prefixIcon: Icons.search,
        ),
        const SizedBox(height: 4),
        const Text('По получателю или комментарию', style: AppText.caption),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('За октябрь', style: AppText.section),
            Text(formatRub(total), style: AppText.label),
          ],
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < demoExpenses.length; i++) ...[
          if (i > 0) const Divider(),
          ExpenseTile(expense: demoExpenses[i]),
        ],
      ],
    );
  }
}
