import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/icon_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_title.dart';
import '../widgets/share_bar.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';
import 'trip_details_screen.dart';
import 'trip_form_screen.dart';

/// Вкладка «Поездки»: итоги командировок за месяц и список поездок.
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
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
    final monthTotal = repo.totalForMonth(_month);
    final tripTotal = repo.tripTotalForMonth(_month);
    final share = monthTotal == 0 ? 0.0 : tripTotal / monthTotal;
    final trips = repo.tripsForMonth(_month);
    final monthExpenses = repo.forMonth(_month);

    return VelvetPage(
      title: 'Командировки',
      bottom: PrimaryButton(
        label: 'Новая командировка',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const TripFormScreen()),
          );
        },
      ),
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
        const Text('В командировках за месяц', style: AppText.caption),
        const SizedBox(height: 4),
        Text(formatKopecks(tripTotal), style: AppText.amountLarge),
        const SizedBox(height: 12),
        ShareBar(value: share),
        const SizedBox(height: 6),
        Text(
          '${(share * 100).round()}% всех расходов · '
          'без поездок ${formatKopecks(monthTotal - tripTotal)}',
          style: AppText.caption,
        ),
        const SizedBox(height: 24),
        SectionTitle(
          title: 'Поездки за месяц',
          trailing: Text('${trips.length}', style: AppText.label),
        ),
        const SizedBox(height: 12),
        if (trips.isEmpty)
          const VelvetCard(
            child: Text(
              'В этом месяце поездок нет. '
              'Нажмите «Новая командировка», чтобы добавить первую.',
              style: AppText.label,
            ),
          )
        else
          for (final trip in trips) ...[
            _TripCard(
              trip: trip,
              expenses: monthExpenses.where((e) => e.tripId == trip.id).toList(),
              monthTripTotal: tripTotal,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TripDetailsScreen(trip: trip),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 4),
        const Text(
          'Чтобы добавить расход в поездку, выберите её при создании '
          'или изменении расхода.',
          style: AppText.caption,
        ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.expenses,
    required this.monthTripTotal,
    required this.onTap,
  });

  final Trip trip;
  final List<Expense> expenses;
  final int monthTripTotal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amount = expenses.fold<int>(0, (sum, e) => sum + e.amountKopecks);
    final percent =
        monthTripTotal == 0 ? 0 : (amount * 100 / monthTripTotal).round();

    return VelvetCard(
      onTap: onTap,
      child: Row(
        children: [
          const IconBadge(icon: Icons.work_outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.name,
                  style: AppText.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  formatDateRange(trip.start, trip.end),
                  style: AppText.caption,
                ),
                const SizedBox(height: 10),
                Text(formatKopecks(amount), style: AppText.section),
                const SizedBox(height: 2),
                Text(
                  '${formatExpenseCount(expenses.length)} · $percent%',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.secondary),
        ],
      ),
    );
  }
}
