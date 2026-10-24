import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../data/expense_filter.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_text.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_choice_chip.dart';
import '../widgets/velvet_page.dart';
import '../widgets/velvet_text_field.dart';

/// Экран «Фильтры». Возвращает выбранный [ExpenseFilter] через Navigator.pop.
class ExpenseFiltersScreen extends StatefulWidget {
  const ExpenseFiltersScreen({super.key, required this.initial});

  final ExpenseFilter initial;

  @override
  State<ExpenseFiltersScreen> createState() => _ExpenseFiltersScreenState();
}

class _ExpenseFiltersScreenState extends State<ExpenseFiltersScreen> {
  static const _anyTrip = '__any__';

  final _fromText = TextEditingController();
  final _toText = TextEditingController();
  final _threshold = TextEditingController();
  final _tripText = TextEditingController();

  late Set<String> _categories;
  late Set<String> _methods;
  late AmountMode _mode;
  DateTime? _from;
  DateTime? _to;
  String? _tripId;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _categories = {...f.categories};
    _methods = {...f.methods};
    _mode = f.amountMode;
    _from = f.from;
    _to = f.to;
    _tripId = f.tripId;
    final threshold = f.amountKopecks;
    if (threshold != null) _threshold.text = kopecksToInput(threshold);
    _syncDateTexts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTripText();
  }

  @override
  void dispose() {
    _fromText.dispose();
    _toText.dispose();
    _threshold.dispose();
    _tripText.dispose();
    super.dispose();
  }

  void _syncDateTexts() {
    _fromText.text = _from == null ? '' : formatDate(_from!);
    _toText.text = _to == null ? '' : formatDate(_to!);
  }

  void _syncTripText() {
    final id = _tripId;
    if (id == null) {
      _tripText.text = '';
    } else if (id == kNoTripFilter) {
      _tripText.text = 'Без командировки';
    } else {
      _tripText.text = ExpenseScope.read(context).tripById(id)?.name ?? '';
    }
  }

  ExpenseFilter _draft() => ExpenseFilter(
        categories: _categories,
        from: _from,
        to: _to,
        amountMode: _mode,
        amountKopecks: parseAmountToKopecks(_threshold.text),
        methods: _methods,
        tripId: _tripId,
      );

  void _toggle(Set<String> set, String value) {
    setState(() {
      if (!set.remove(value)) set.add(value);
    });
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final current = isFrom ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
      _syncDateTexts();
    });
  }

  Future<void> _pickTrip() async {
    final trips = ExpenseScope.read(context).trips;
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('Любая'),
              onTap: () => Navigator.of(sheetContext).pop(_anyTrip),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Без командировки'),
              onTap: () => Navigator.of(sheetContext).pop(kNoTripFilter),
            ),
            for (final trip in trips)
              ListTile(
                leading: const Icon(Icons.work_outline),
                title: Text(trip.name),
                subtitle: Text(formatDateRange(trip.start, trip.end)),
                onTap: () => Navigator.of(sheetContext).pop(trip.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      _tripId = picked == _anyTrip ? null : picked;
      _syncTripText();
    });
  }

  void _reset() {
    setState(() {
      _categories = {};
      _methods = {};
      _mode = AmountMode.greater;
      _from = null;
      _to = null;
      _tripId = null;
      _threshold.clear();
      _syncDateTexts();
      _syncTripText();
    });
  }

  void _apply() {
    final from = _from;
    final to = _to;
    if (from != null && to != null && from.isAfter(to)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дата «С» не может быть позже даты «По»')),
      );
      return;
    }
    Navigator.of(context).pop(_draft());
  }

  @override
  Widget build(BuildContext context) {
    final repository = ExpenseScope.of(context);
    final categories = repository.allCategories;
    final count = _draft().activeCount;

    return VelvetPage(
      title: 'Фильтры',
      trailing: TextButton(onPressed: _reset, child: const Text('Сбросить')),
      bottom: PrimaryButton(label: 'Применить', onPressed: _apply),
      children: [
        const Text(
          'Все условия применяются вместе. Поиск в списке сохраняется.',
          style: AppText.label,
        ),
        const SizedBox(height: 20),
        const Text('Категория', style: AppText.section),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              VelvetChoiceChip(
                label: category.name,
                selected: _categories.contains(category.name),
                onTap: () => _toggle(_categories, category.name),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Дата расхода', style: AppText.section),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: VelvetTextField(
                label: 'С',
                hint: 'Любая',
                controller: _fromText,
                readOnly: true,
                onTap: () => _pickDate(isFrom: true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: VelvetTextField(
                label: 'По',
                hint: 'Любая',
                controller: _toText,
                readOnly: true,
                onTap: () => _pickDate(isFrom: false),
              ),
            ),
          ],
        ),
        if (_from != null || _to != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() {
                _from = null;
                _to = null;
                _syncDateTexts();
              }),
              child: const Text('Очистить даты'),
            ),
          ),
        const SizedBox(height: 20),
        const Text('Сумма, ₽', style: AppText.section),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            VelvetChoiceChip(
              label: 'Больше',
              selected: _mode == AmountMode.greater,
              onTap: () => setState(() => _mode = AmountMode.greater),
            ),
            VelvetChoiceChip(
              label: 'Меньше',
              selected: _mode == AmountMode.less,
              onTap: () => setState(() => _mode = AmountMode.less),
            ),
          ],
        ),
        const SizedBox(height: 12),
        VelvetTextField(
          label: 'Порог суммы',
          hint: 'Не задан',
          controller: _threshold,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d{0,9}([.,]\d{0,2})?'),
            ),
          ],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        const Text('Способ оплаты', style: AppText.section),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final method in kPaymentMethods)
              VelvetChoiceChip(
                label: method,
                selected: _methods.contains(method),
                onTap: () => _toggle(_methods, method),
              ),
          ],
        ),
        const SizedBox(height: 20),
        VelvetTextField(
          label: 'Командировка',
          hint: 'Любая',
          controller: _tripText,
          readOnly: true,
          onTap: _pickTrip,
          suffixIcon: Icons.arrow_drop_down,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              count == 0
                  ? 'Условия не заданы'
                  : 'Активно $count '
                      '${pluralRu(count, 'условие', 'условия', 'условий')}',
              style: AppText.caption,
            ),
            if (count > 0) ...[
              const Text(' · ', style: AppText.caption),
              GestureDetector(
                onTap: _reset,
                child: const Text('Сбросить все', style: AppText.link),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
