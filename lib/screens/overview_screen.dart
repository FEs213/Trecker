import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/section_title.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';

/// Вкладка «Обзор»: итог за выбранный месяц и разбивка по категориям.
/// Кольцевая диаграмма и столбики по месяцам - следующий шаг.
class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ExpenseScope.of(context);
    final total = repo.totalForMonth(_month);
    final byCategory = repo.categoryTotalsForMonth(_month);

    return VelvetPage(
      title: 'Траты',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _shiftMonth(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(formatMonthYear(_month), style: AppText.body),
            IconButton(
              onPressed: () => _shiftMonth(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Все расходы за месяц', style: AppText.caption),
        const SizedBox(height: 4),
        Text(formatKopecks(total), style: AppText.amountLarge),
        const SizedBox(height: 24),
        const SectionTitle(title: 'По категориям'),
        const SizedBox(height: 12),
        if (byCategory.isEmpty)
          const VelvetCard(
            child: Text(
              'В этом месяце расходов пока нет. '
              'Добавьте первый на вкладке «Расходы».',
              style: AppText.label,
            ),
          )
        else
          VelvetCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (var i = 0; i < byCategory.length; i++) ...[
                  if (i > 0) const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          categoryByName(byCategory[i].key).icon,
                          color: AppColors.highlight,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            byCategory[i].key,
                            style: AppText.body,
                          ),
                        ),
                        Text(
                          formatKopecks(byCategory[i].value),
                          style: AppText.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
