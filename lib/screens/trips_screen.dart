import 'package:flutter/material.dart';

import '../core/format.dart';
import '../theme/app_text.dart';
import '../widgets/icon_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';

/// Вкладка «Поездки» (командировки). Пока демо-карточки из макета.
class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VelvetPage(
      title: 'Командировки',
      bottom: PrimaryButton(
        label: 'Новая командировка',
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Экран появится на следующем шаге')),
        ),
      ),
      children: [
        const Text('В командировках за месяц', style: AppText.caption),
        const SizedBox(height: 4),
        Text(formatRub(10400), style: AppText.amountLarge),
        const SizedBox(height: 24),
        const Text('Поездки в октябре', style: AppText.section),
        const SizedBox(height: 12),
        const _TripCard(
          title: 'Казань · встреча с клиентом',
          dates: '12–15 октября 2026',
          amount: 7600,
          note: '3 расхода · 73%',
        ),
        const SizedBox(height: 12),
        const _TripCard(
          title: 'Санкт-Петербург · форум',
          dates: '5–7 октября 2026',
          amount: 2800,
          note: '3 расхода · 27%',
        ),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.title,
    required this.dates,
    required this.amount,
    required this.note,
  });

  final String title;
  final String dates;
  final int amount;
  final String note;

  @override
  Widget build(BuildContext context) {
    return VelvetCard(
      child: Row(
        children: [
          const IconBadge(icon: Icons.work_outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodyMedium),
                const SizedBox(height: 2),
                Text(dates, style: AppText.caption),
                const SizedBox(height: 10),
                Text(formatRub(amount), style: AppText.section),
                const SizedBox(height: 2),
                Text(note, style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
