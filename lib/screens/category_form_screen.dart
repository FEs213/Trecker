import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/icon_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_card.dart';
import '../widgets/velvet_page.dart';
import '../widgets/velvet_text_field.dart';

/// Экран «Своя категория»: название, значок и цвет. С [category] - изменение
/// (и удаление, если в категории нет расходов), без него - создание.
class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, this.category});

  final ExpenseCategory? category;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  String _iconKey = kIconOptions.keys.first;
  Color _color = kColorOptions.first;
  bool _saving = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    if (category != null) {
      _name.text = category.name;
      if (kIconOptions.containsKey(category.iconKey)) {
        _iconKey = category.iconKey;
      }
      _color = category.color;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repository = ExpenseScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);

    final category = ExpenseCategory(
      _name.text.trim(),
      kIconOptions[_iconKey] ?? Icons.category_outlined,
      id: widget.category?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      iconKey: _iconKey,
      color: _color,
    );

    final editing = _isEditing;
    if (editing) {
      await repository.updateCategory(category);
    } else {
      await repository.addCategory(category);
    }

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(editing ? 'Изменения сохранены' : 'Категория создана'),
      ),
    );
  }

  Future<void> _delete() async {
    final category = widget.category;
    if (category == null) return;

    final repository = ExpenseScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDeleteConfirm(
      context,
      title: 'Удалить категорию?',
      summary: '«${category.name}»',
      message: 'В категории нет расходов. Удаление нельзя отменить.',
    );
    if (!confirmed) return;

    final deleted = await repository.deleteCategory(category.id);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Категория удалена' : 'Категорию нельзя удалить',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = ExpenseScope.of(context);
    final original = widget.category;
    final usedCount =
        original == null ? 0 : repository.expenseCountForCategory(original.name);
    final previewName = _name.text.trim().isEmpty
        ? 'Название категории'
        : _name.text.trim();

    return VelvetPage(
      title: _isEditing ? 'Своя категория' : 'Новая категория',
      bottom: PrimaryButton(
        label: _isEditing ? 'Сохранить' : 'Создать',
        onPressed: _saving ? null : _save,
      ),
      children: [
        VelvetCard(
          child: Row(
            children: [
              IconBadge(
                icon: kIconOptions[_iconKey] ?? Icons.category_outlined,
                color: _color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      previewName,
                      style: AppText.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEditing
                          ? 'Своя категория · ${formatExpenseCount(usedCount)}'
                          : 'Своя категория',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: VelvetTextField(
            label: 'Название категории',
            hint: 'Например, Питомцы',
            controller: _name,
            onChanged: (_) => setState(() {}),
            validator: (value) {
              final name = (value ?? '').trim();
              if (name.isEmpty) return 'Введите название';
              if (name.length > 30) return 'Не длиннее 30 символов';
              if (repository.categoryNameTaken(
                name,
                exceptId: original?.id ?? '',
              )) {
                return 'Категория с таким названием уже есть';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text('Значок', style: AppText.section),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final entry in kIconOptions.entries)
              _IconChoice(
                icon: entry.value,
                selected: entry.key == _iconKey,
                onTap: () => setState(() => _iconKey = entry.key),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Цвет', style: AppText.section),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final color in kColorOptions)
              _ColorChoice(
                color: color,
                selected: color.toARGB32() == _color.toARGB32(),
                onTap: () => setState(() => _color = color),
              ),
          ],
        ),
        if (_isEditing) ...[
          const SizedBox(height: 24),
          VelvetCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Удалить категорию «${original?.name ?? ''}»?',
                  style: AppText.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  usedCount == 0
                      ? 'В категории нет расходов. Удаление нельзя отменить.'
                      : 'В категории ${formatExpenseCount(usedCount)}. '
                          'Чтобы удалить её, сначала смените категорию '
                          'у этих расходов.',
                  style: AppText.label,
                ),
                if (usedCount == 0) ...[
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Удалить категорию',
                    danger: true,
                    onPressed: _delete,
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Стандартные категории изменить или удалить нельзя.',
          style: AppText.caption,
        ),
      ],
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: selected ? AppColors.highlight : AppColors.cardBorder,
        width: selected ? 2 : 1,
      ),
    );
    return Material(
      color: selected ? AppColors.highlight20 : AppColors.fieldFill,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: selected ? AppColors.highlight : AppColors.primary80,
          ),
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: selected
              ? const Icon(Icons.check, color: AppColors.primaryInversion)
              : null,
        ),
      ),
    );
  }
}
