import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/demo_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_choice_chip.dart';
import '../widgets/velvet_page.dart';
import '../widgets/velvet_text_field.dart';

/// Экран «Новый расход». Форма рабочая, но сохранение пока демонстрационное.
class NewExpenseScreen extends StatefulWidget {
  const NewExpenseScreen({super.key});

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  static const _methods = ['Карта', 'Наличные', 'QR-код', 'Иной'];

  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _category = TextEditingController();
  final _date = TextEditingController();
  final _payee = TextEditingController();
  final _comment = TextEditingController();
  final _trip = TextEditingController();

  DateTime _dateValue = DateTime.now();
  String _method = _methods.first;

  @override
  void initState() {
    super.initState();
    _date.text = formatDate(_dateValue);
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
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final category in demoCategories)
              ListTile(
                leading: Icon(category.icon),
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

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Расход проверен. Сохранение подключим на следующем шаге'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return VelvetPage(
      title: 'Новый расход',
      bottom: PrimaryButton(label: 'Сохранить', onPressed: _save),
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
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.').trim(),
                  );
                  return (parsed == null || parsed <= 0)
                      ? 'Введите сумму больше нуля'
                      : null;
                },
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
                  for (final method in _methods)
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
                controller: _trip,
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
