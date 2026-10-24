import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/icon_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';
import '../widgets/velvet_text_field.dart';

/// Экран «Новая командировка»: название и период.
class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _startText = TextEditingController();
  final _endText = TextEditingController();

  late DateTime _start;
  late DateTime _end;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, now.day);
    _end = _start;
    _startText.text = formatDate(_start);
    _endText.text = formatDate(_end);
  }

  @override
  void dispose() {
    _name.dispose();
    _startText.dispose();
    _endText.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _pickStart() async {
    final picked = await _pick(_start);
    if (picked == null) return;
    setState(() {
      _start = picked;
      _startText.text = formatDate(picked);
      if (_end.isBefore(_start)) {
        _end = _start;
        _endText.text = formatDate(_end);
      }
    });
  }

  Future<void> _pickEnd() async {
    final picked = await _pick(_end);
    if (picked == null) return;
    setState(() {
      _end = picked;
      _endText.text = formatDate(picked);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repository = ExpenseScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);

    await repository.addTrip(
      Trip(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        start: _start,
        end: _end,
      ),
    );

    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Поездка создана')));
  }

  @override
  Widget build(BuildContext context) {
    final trip = Trip(id: '', name: '', start: _start, end: _end);
    final summaryValid = !_end.isBefore(_start);

    return VelvetPage(
      title: 'Новая командировка',
      bottom: PrimaryButton(
        label: 'Создать',
        onPressed: _saving ? null : _save,
      ),
      children: [
        const VelvetCard(
          child: Row(
            children: [
              IconBadge(icon: Icons.work_outline),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Отдельный учёт расходов в рабочей поездке',
                  style: AppText.body,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VelvetTextField(
                label: 'Название *',
                hint: 'Например, Казань · встреча',
                controller: _name,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Введите название'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text('Период командировки', style: AppText.section),
              const SizedBox(height: 12),
              VelvetTextField(
                label: 'Дата начала *',
                controller: _startText,
                readOnly: true,
                onTap: _pickStart,
                suffixIcon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 12),
              VelvetTextField(
                label: 'Дата окончания *',
                controller: _endText,
                readOnly: true,
                onTap: _pickEnd,
                suffixIcon: Icons.calendar_today_outlined,
                validator: (_) => _end.isBefore(_start)
                    ? 'Дата окончания не может быть раньше начала'
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (summaryValid)
          VelvetCard(
            child: Row(
              children: [
                const Icon(Icons.event_outlined, color: AppColors.highlight),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDateRange(_start, _end),
                        style: AppText.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatDays(trip.days)} · '
                        '${trip.statusOn(DateTime.now())}',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const Text(
          'После создания привяжите расходы к командировке. '
          'Итоги и распределение по категориям появятся автоматически.',
          style: AppText.caption,
        ),
      ],
    );
  }
}
