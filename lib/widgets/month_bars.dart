import 'package:flutter/material.dart';

import '../core/format.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class MonthBar {
  const MonthBar({required this.month, required this.total});

  final DateTime month;
  final int total;
}

/// Столбики расходов по месяцам; выбранный месяц подсвечен розовым.
class MonthBars extends StatelessWidget {
  const MonthBars({
    super.key,
    required this.bars,
    required this.selected,
    required this.onSelect,
    this.height = 110,
  });

  final List<MonthBar> bars;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxTotal = bars.fold<int>(0, (m, b) => b.total > m ? b.total : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final bar in bars)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(bar.month),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: height,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: maxTotal == 0 || bar.total == 0
                              ? 4
                              : 4 + (height - 4) * bar.total / maxTotal,
                          decoration: BoxDecoration(
                            color: _isSelected(bar)
                                ? AppColors.highlight
                                : AppColors.highlight40,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatMonthShort(bar.month),
                      style: _isSelected(bar)
                          ? AppText.caption.copyWith(color: AppColors.highlight)
                          : AppText.caption,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _isSelected(MonthBar bar) =>
      bar.month.year == selected.year && bar.month.month == selected.month;
}
