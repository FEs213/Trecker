import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_text.dart';
import '../widgets/donut_chart.dart';
import '../widgets/month_bars.dart';
import '../widgets/section_title.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';

/// Вкладка «Обзор»: итог за месяц, кольцевая диаграмма по категориям
/// и столбики по месяцам.
class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  /// Выбранный месяц.
  late DateTime _month;

  /// Последний месяц в окне из шести столбиков.
  late DateTime _windowEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _windowEnd = _month;
  }

  void _setMonth(DateTime month) {
    setState(() {
      _month = DateTime(month.year, month.month);
      final windowStart = DateTime(_windowEnd.year, _windowEnd.month - 5);
      if (_month.isAfter(_windowEnd)) {
        _windowEnd = _month;
      } else if (_month.isBefore(windowStart)) {
        _windowEnd = DateTime(_month.year, _month.month + 5);
      }
    });
  }

  void _shiftMonth(int delta) =>
      _setMonth(DateTime(_month.year, _month.month + delta));

  /// Цвет сегмента: у своей категории - её цвет, у стандартной - по палитре.
  Color _segmentColor(ExpenseCategory category) {
    if (category.isCustom) return category.color;
    final index = kCategories.indexWhere((c) => c.name == category.name);
    return index < 0
        ? kChartPalette.last
        : kChartPalette[index % kChartPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final repo = ExpenseScope.of(context);
    final total = repo.totalForMonth(_month);
    final byCategory = repo.categoryTotalsForMonth(_month);

    final bars = [
      for (var i = 5; i >= 0; i--)
        MonthBar(
          month: DateTime(_windowEnd.year, _windowEnd.month - i),
          total: repo.totalForMonth(
            DateTime(_windowEnd.year, _windowEnd.month - i),
          ),
        ),
    ];
    final hasAnyBars = bars.any((b) => b.total > 0);

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
        const SizedBox(height: 16),
        if (byCategory.isEmpty)
          const VelvetCard(
            child: Text(
              'В этом месяце расходов пока нет. '
              'Добавьте первый на вкладке «Расходы».',
              style: AppText.label,
            ),
          )
        else ...[
          Center(
            child: DonutChart(
              segments: [
                for (final entry in byCategory)
                  DonutSegment(
                    value: entry.value,
                    color: _segmentColor(repo.categoryByName(entry.key)),
                  ),
              ],
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${byCategory.length}',
                    style: AppText.title.copyWith(fontSize: 34),
                  ),
                  Text(
                    pluralRu(
                      byCategory.length,
                      'категория',
                      'категории',
                      'категорий',
                    ),
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          VelvetCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (var i = 0; i < byCategory.length; i++) ...[
                  if (i > 0) const Divider(),
                  _LegendRow(
                    color: _segmentColor(repo.categoryByName(byCategory[i].key)),
                    name: byCategory[i].key,
                    amount: byCategory[i].value,
                    percent: total == 0
                        ? 0
                        : (byCategory[i].value * 100 / total).round(),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (hasAnyBars) ...[
          const SizedBox(height: 24),
          SectionTitle(
            title: 'По месяцам',
            trailing: Text(
              '${_month.year}',
              style: AppText.link.copyWith(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          MonthBars(bars: bars, selected: _month, onSelect: _setMonth),
        ],
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.name,
    required this.amount,
    required this.percent,
  });

  final Color color;
  final String name;
  final int amount;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppText.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatKopecks(amount), style: AppText.bodyMedium),
              Text('$percent%', style: AppText.caption),
            ],
          ),
        ],
      ),
    );
  }
}
