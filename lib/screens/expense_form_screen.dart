import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_choice_chip.dart';
import '../widgets/velvet_page.dart';
import '../widgets/velvet_text_field.dart';

/// Форма расхода. Без [expense] - «Новый расход», с ним - «Изменить расход».
class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});

  final Expense? expense;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  bool get _isEditing => widget.expense != null;

  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _category = TextEditingController();
  final _date = TextEditingController();
  final _payee = TextEditingController();
  final _comment = TextEditingController();
  final _trip = TextEditingController();
  String _tripId = '';

  DateTime _dateValue = DateTime.now();
  String _method = kPaymentMethods.first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    if (expense != null) {
      _amount.text = kopecksToInput(expense.amountKopecks);
      _category.text = expense.categoryName;
      _dateValue = expense.date;
      _payee.text = expense.payee;
      _comment.text = expense.comment;
      _tripId = expense.tripId;
      _method = expense.method;
    }
    _date.text = formatDate(_dateValue);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _trip.text = ExpenseScope.of(context).tripById(_tripId)?.name ?? '';
  }

  @override
  void dispose() {
    _amount.dispose();
    _category.dispose();
    _date.dispose();
    _payee.dispose();
    _comment.dispose();
    _trip.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateValue,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateValue = picked;
        _date.text = formatDate(picked);
      });
    }
  }

  Future<void> _pickCategory() async {
    final categories = ExpenseScope.read(context).allCategories;
    final picked = await showModalBottomSheet<String>(
      isScrollControlled: true,
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final category in categories)
              ListTile(
                leading: Icon(category.icon, color: category.color),
                title: Text(category.name),
                onTap: () => Navigator.of(sheetContext).pop(category.name),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() => _category.text = picked);
    }
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
              leading: const Icon(Icons.block),
              title: const Text('Без командировки'),
              onTap: () => Navigator.of(sheetContext).pop(''),
            ),
            for (final trip in trips)
              ListTile(
                leading: const Icon(Icons.work_outline),
                title: Text(trip.name),
                subtitle: Text(formatDateRange(trip.start, trip.end)),
                onTap: () => Navigator.of(sheetContext).pop(trip.id),
              ),
            if (trips.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(
                  'Поездок пока нет. Создайте её на вкладке «Поездки».',
                  style: AppText.caption,
                ),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      final name = ExpenseScope.read(context).tripById(picked)?.name ?? '';
      setState(() {
        _tripId = picked;
        _trip.text = name;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final kopecks = parseAmountToKopecks(_amount.text);
    if (kopecks == null) return;

    final repository = ExpenseScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);

    final expense = Expense(
      id: widget.expense?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amountKopecks: kopecks,
      categoryName: _category.text,
      date: DateTime(_dateValue.year, _dateValue.month, _dateValue.day),
      method: _method,
      payee: _payee.text.trim(),
      comment: _comment.text.trim(),
      tripId: _tripId,
    );

    final editing = _isEditing;
    if (editing) {
      await repository.update(expense);
    } else {
      await repository.add(expense);
    }

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(editing ? 'Изменения сохранены' : 'Расход добавлен'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VelvetPage(
      title: _isEditing ? 'Изменить расход' : 'Новый расход',
      bottom: PrimaryButton(
        label: 'Сохранить',
        onPressed: _saving ? null : _save,
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VelvetTextField(
                label: 'Сумма, ₽ *',
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,9}([.,]\d{0,2})?'),
                  ),
                ],
                validator: (value) => parseAmountToKopecks(value ?? '') == null
                    ? 'Введите сумму больше нуля'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: VelvetTextField(
                      label: 'Категория *',
                      hint: 'Выбрать',
                      controller: _category,
                      readOnly: true,
                      onTap: _pickCategory,
                      suffixIcon: Icons.arrow_drop_down,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Выберите категорию'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: VelvetTextField(
                      label: 'Дата *',
                      controller: _date,
                      readOnly: true,
                      onTap: _pickDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              VelvetTextField(label: 'Получатель платежа', controller: _payee),
              const SizedBox(height: 12),
              VelvetTextField(label: 'Комментарий', controller: _comment),
              const SizedBox(height: 12),
              const Text('Способ оплаты *', style: AppText.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final method in kPaymentMethods)
                    VelvetChoiceChip(
                      label: method,
                      selected: method == _method,
                      onTap: () => setState(() => _method = method),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              VelvetTextField(
                label: 'Командировка · необязательно',
                hint: 'Без командировки',
                controller: _trip,
                readOnly: true,
                onTap: _pickTrip,
                suffixIcon: Icons.arrow_drop_down,
              ),
              const SizedBox(height: 16),
              VelvetCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Прикрепление чеков появится позже'),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.attach_file, color: AppColors.highlight),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Прикрепить чек', style: AppText.link),
                    ),
                    Icon(Icons.add, color: AppColors.secondary),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Фото с камеры или из галереи. Обязательные поля отмечены *.',
                style: AppText.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
