import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/expense_repository.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/icon_badge.dart';
import '../widgets/primary_button.dart';
import '../widgets/velvet_page.dart';
import 'category_form_screen.dart';

/// Вкладка «Категории»: стандартные (только просмотр) и свои (можно менять).
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ExpenseScope.of(context);
    final custom = repo.customCategories;

    return VelvetPage(
      title: 'Категории',
      bottom: PrimaryButton(
        label: 'Добавить категорию',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CategoryFormScreen(),
            ),
          );
        },
      ),
      children: [
        Text(
          'Стандартные · ${kCategories.length} категорий',
          style: AppText.caption,
        ),
        const SizedBox(height: 8),
        for (final category in kCategories)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(category.icon, color: AppColors.highlight),
                const SizedBox(width: 16),
                Text(category.name, style: AppText.body),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const Text('Свои категории', style: AppText.caption),
        const SizedBox(height: 8),
        if (custom.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Своих категорий пока нет. Нажмите «Добавить категорию».',
              style: AppText.label,
            ),
          )
        else
          for (final category in custom)
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CategoryFormScreen(category: category),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    IconBadge(
                      icon: category.icon,
                      color: category.color,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name, style: AppText.body),
                          const SizedBox(height: 2),
                          Text(
                            _usage(repo.expenseCountForCategory(category.name)),
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.edit_outlined,
                      color: AppColors.highlight,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 12),
        const Text(
          'Стандартные категории изменить или удалить нельзя.',
          style: AppText.caption,
        ),
      ],
    );
  }

  static String _usage(int count) =>
      count == 0 ? 'Своя · пока нет расходов' : 'Своя · ${formatExpenseCount(count)}';
}
