import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_text.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/expense_tile.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_title.dart';
import '../widgets/share_bar.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';
import 'expense_details_screen.dart';

/// Экран поездки: период, итог, разбивка по категориям и список расходов.
class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late Trip _trip = widget.trip;

  Future<void> _delete() async {
    final repository = ExpenseScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDeleteConfirm(
      context,
      title: 'Удалить поездку?',
      summary: '${_trip.name} · ${formatDateRange(_trip.start, _trip.end)}',
      message: 'Расходы останутся в списке, но перестанут быть привязаны '
          'к поездке. Восстановить поездку нельзя.',
    );
    if (!confirmed) return;

    await repository.deleteTrip(_trip.id);
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Поездка удалена')));
  }

  @override
  Widget build(BuildContext context) {
    final repository = ExpenseScope.of(context);
    _trip = repository.tripById(widget.trip.id) ?? _trip;
    final trip = _trip;

    final expenses = repository.expensesForTrip(trip.id);
    final total = repository.totalForTrip(trip.id);
    final byCategory = repository.categoryTotals(expenses);

    return VelvetPage(
      title: trip.name,
      bottom: PrimaryButton(
        label: 'Удалить поездку',
        danger: true,
        onPressed: _delete,
      ),
      children: [
        Text(formatDateRange(trip.start, trip.end), style: AppText.body),
        const SizedBox(height: 2),
        Text(
          '${formatDays(trip.days)} · ${trip.statusOn(DateTime.now())}',
          style: AppText.caption,
        ),
        const SizedBox(height: 20),
        const Text('Расходы за весь период', style: AppText.caption),
        const SizedBox(height: 4),
        Text(formatKopecks(total), style: AppText.amountLarge),
        const SizedBox(height: 24),
        const SectionTitle(title: 'По категориям'),
        const SizedBox(height: 12),
        if (byCategory.isEmpty)
          const VelvetCard(
            child: Text(
              'К поездке пока не привязано ни одного расхода. '
              'Выберите её при создании или изменении расхода.',
              style: AppText.label,
            ),
          )
        else
          for (final entry in byCategory) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(entry.key, style: AppText.body)),
                Text(
                  '${formatKopecks(entry.value)} · '
                  '${(entry.value * 100 / total).round()}%',
                  style: AppText.label,
                ),
              ],
            ),
            const SizedBox(height: 6),
            ShareBar(value: entry.value / total),
            const SizedBox(height: 14),
          ],
        if (expenses.isNotEmpty) ...[
          const SizedBox(height: 10),
          SectionTitle(
            title: 'Расходы',
            trailing: Text('${expenses.length}', style: AppText.label),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < expenses.length; i++) ...[
            if (i > 0) const Divider(),
            ExpenseTile(
              expense: expenses[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ExpenseDetailsScreen(expense: expenses[i]),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
