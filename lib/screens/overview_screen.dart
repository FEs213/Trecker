import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/demo_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/section_title.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';

/// Вкладка «Обзор». Пока статичная: итог за месяц и разбивка по категориям.
/// Кольцевая диаграмма и столбики по месяцам — следующий шаг.
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VelvetPage(
      title: 'Траты',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chevron_left),
            ),
            const Text('Октябрь 2026', style: AppText.body),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Все расходы за месяц', style: AppText.caption),
        const SizedBox(height: 4),
        Text(formatRub(demoMonthTotal), style: AppText.amountLarge),
        const SizedBox(height: 24),
        const SectionTitle(title: 'По категориям'),
        const SizedBox(height: 12),
        VelvetCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (var i = 0; i < demoCategories.length; i++) ...[
                if (i > 0) const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        demoCategories[i].icon,
                        color: AppColors.highlight,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          demoCategories[i].name,
                          style: AppText.body,
                        ),
                      ),
                      Text(
                        formatRub(demoCategories[i].demoTotal),
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
